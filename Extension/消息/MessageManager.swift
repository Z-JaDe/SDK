//
//  MessageManager.swift
//  SDK
//
//  Created by 茶古电子商务 on 2017/11/16.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import UIKit
import Hyphenate
import RxCocoa
import RxSwift
public let serverName:String = "server"
public let messagesKey:String = "messages"
public let messageKey:String = "message"

public class MessageManager: ThirdManager {
    public static var shared:MessageManager = MessageManager()
    private override init() {
        super.init()
        registerNotifications()
    }
    deinit {
        unregisterNotifications()
    }
    public var currentConversationId:String?
    var hxUserLoginTimestamp:TimeInterval?
    
    func configObserver() {
        NotificationCenter.default.rx.notification(.ChatLoginSuccessful).subscribe(onNext:{[unowned self] (notification) in
            self.hxUserLoginTimestamp = Date().timeIntervalSince1970 * 1000
        }).disposed(by: disposeBag)
    }
}
extension MessageManager {
    func registerNotifications() {
        unregisterNotifications()
        EMClient.shared().chatManager.add(self, delegateQueue: nil)
        EMClient.shared().groupManager.add(self, delegateQueue: nil)
    }
    func unregisterNotifications() {
        EMClient.shared().chatManager.remove(self)
        EMClient.shared().groupManager.removeDelegate(self)
    }
}
extension MessageManager:EMGroupManagerDelegate {
    public func groupListDidUpdate(_ aGroupList: [Any]!) {
        NotificationCenter.default.post(name: .GroupListDidUpdate, object: nil)
    }
}
extension MessageManager:EMChatManagerDelegate {
    /// ZJaDe: 会话列表发生变化
    public func conversationListDidUpdate(_ aConversationList: [Any]!) {
        NotificationCenter.default.post(name: .ConversationListDidUpdate, object: nil)
    }
    /// ZJaDe: 收到消息
    public func messagesDidReceive(_ aMessages: [Any]!) {
        logDebug("接收到\(aMessages.count)条消息")
        guard let messageArr = aMessages as? [EMMessage] else {
            return
        }
        NotificationCenter.default.post(name: .DidReceiveMessages, object: nil, userInfo: [messagesKey:messageArr])
        for message in messageArr {
            messageHandle(message)
        }
        logMessageArr(messageArr)
    }
    /// ZJaDe: 收到Cmd消息
    public func cmdMessagesDidReceive(_ aCmdMessages: [Any]!) {
        logDebug("接收到\(aCmdMessages.count)条透传消息")
        guard let messageArr = aCmdMessages as? [EMMessage] else {
            return
        }
        NotificationCenter.default.post(name: .DidReceiveCMDMessages, object: nil, userInfo: [messagesKey:messageArr])
        logMessageArr(messageArr)
    }
    
    func logMessageArr(_ messages:[EMMessage]) {
        #if DEBUG
            for message in messages {
                var dict = [String:Any]()
                dict["messageId"] = message.messageId
                dict["conversationId"] = message.conversationId
                dict["from"] = message.from
                dict["to"] = message.to
                dict["status"] = message.status
                dict["isRead"] = message.isRead
                dict["ext"] = message.ext
                if let body = message.body as? EMCmdMessageBody {
                    dict["cmd_text"] = body.action
                }
                if let body = message.body as? EMTextMessageBody {
                    dict["text"] = body.text
                }
                logDebug("\(dict)")
            }
        #endif
    }
}
extension DefaultsKeys {
    static let latestServerMessageTimestamp = DefaultsKey<TimeInterval>("latestServerMessageTimestamp")
}
extension MessageManager {
    public var latestServerMessageTimestamp:TimeInterval {
        get {return Defaults[.latestServerMessageTimestamp]}
        set {Defaults[.latestServerMessageTimestamp] = newValue}
    }
    
    func messageHandle(_ message:EMMessage) {
        serverMessageHandle(message)
        /// ZJaDe: 处理未在聊天界面的消息
        if message.conversationId == self.currentConversationId {
            BadgeManager.shared.vibrate()
            BadgeManager.shared.sendSetupUnreadMessageCountNotification()
        }
    }
    func serverMessageHandle(_ message:EMMessage) {
        guard message.from == serverName else {
            return
        }
        NotificationCenter.default.post(name: .DidReceiveSeverMessages, object: nil, userInfo: [messageKey:message])
        
        self.latestServerMessageTimestamp = TimeInterval(message.timestamp)
        /// ZJaDe: 有hxUserLoginTimestamp说明已经登录
        if let hxUserLoginTimestamp = self.hxUserLoginTimestamp,self.latestServerMessageTimestamp > hxUserLoginTimestamp {
            BadgeManager.shared.increaseServerBadge()
        }else {
            logError("hxUserLoginTimestamp:\(hxUserLoginTimestamp ?? -1),latestMessageTimestamp:\(latestServerMessageTimestamp)")
        }
    }
}

