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
public enum MessageFromType:String {
    case common
    case server = "server"
    public init(_ from:String) {
        if let type = MessageFromType(rawValue:from) {
            self = type
        }else {
            self = .common
        }
    }
}

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
    
    public let didSendMessages:PublishSubject<[EMMessage]> = PublishSubject()
    
    public let didReceiveSeverMessage:PublishSubject<EMMessage> = PublishSubject()
    public let didReceiveCMDMessages:PublishSubject<[EMMessage]> = PublishSubject()
    public let didReceiveMessages:PublishSubject<[EMMessage]> = PublishSubject()
    
    func configObserver() {
        EaseMobManager.shared.loginedObserver()
            .subscribe(onNext:{[unowned self] (_) in
                self.hxUserLoginTimestamp = Date().timeIntervalSince1970 * 1000
        }).disposed(by: disposeBag)
    }
}
extension Observable where Element == [EMMessage] {
    public func sendMessages() -> Observable<(EMMessage,EMError?)> {
        return self.flatMap({ (messages) -> Observable<(EMMessage,EMError?)> in
            return Observable<(EMMessage,EMError?)>.create { (observer) -> Disposable in
                for message in messages {
                    EMClient.shared().chatManager.send(message, progress: nil, completion: { (message, error) in
                        guard let message = message else {
                            logError("环信: message应该为nil")
                            return
                        }
                        if let error = error {
                            HUD.showError(error.errorDescription)
                            logError("环信: 信息发送失败 code:\(error.code), errorDescription:\(error.errorDescription)")
                        }
                        observer.onNext((message,error))
                    })
                }
                MessageManager.shared.didSendMessages.onNext(messages)
                return Disposables.create()
            }
        })
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
        NotificationCenter.default.post(name: .GroupsListDidUpdate, object: nil)
    }
}
extension MessageManager:EMChatManagerDelegate {
    /// ZJaDe: 会话列表发生变化
    public func conversationListDidUpdate(_ aConversationList: [Any]!) {
        logDebug("ConversationListDidUpdate -> \(aConversationList)")
        NotificationCenter.default.post(name: .ConversationListDidUpdate, object: nil)
    }
    
    /// ZJaDe: 收到消息
    public func messagesDidReceive(_ aMessages: [Any]!) {
        logDebug("接收到\(aMessages.count)条消息")
        guard let messageArr = aMessages as? [EMMessage] else {
            return
        }
        didReceiveMessages.onNext(messageArr)
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
        messageArr.forEach{$0.isRead = true}
        didReceiveCMDMessages.onNext(messageArr)
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
extension MessageManager {
    
    func messageHandle(_ message:EMMessage) {
        switch MessageFromType(message.from) {
        case .common:
            break
        case .server:
            serverMessageHandle(message)
        }
        /// ZJaDe: 处理未在聊天界面的消息
        if message.conversationId != self.currentConversationId {
            BadgeManager.shared.vibrate()
            BadgeManager.shared.sendSetupUnreadMessageCountNotification()
        }
    }
    func serverMessageHandle(_ message:EMMessage) {
        self.didReceiveSeverMessage.onNext(message)
        
        let serverMessageTimestamp = TimeInterval(message.timestamp)
        /// ZJaDe: 有hxUserLoginTimestamp说明已经登录
        if let hxUserLoginTimestamp = self.hxUserLoginTimestamp,serverMessageTimestamp > hxUserLoginTimestamp {
            BadgeManager.shared.increaseServerBadge()
        }else {
            logError("hxUserLoginTimestamp:\(hxUserLoginTimestamp ?? -1),serverMessageTimestamp:\(serverMessageTimestamp)")
        }
    }
}

