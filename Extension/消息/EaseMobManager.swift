//
//  EaseMobManager.swift
//  SDK
//
//  Created by 茶古电子商务 on 2017/11/16.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Extension
import Hyphenate
import AppInfoData

public enum ChatState {
    case offLine
    case autoLoginError
    case loginError
    case logout
    case connectionStateChanged(EMConnectionState)
    case logined
    
    func isLogined() -> Bool {
        switch self {
        case .logined:
            return true
        default:
            return false
        }
    }
}
public class EaseMobManager:ThirdManager {
    public let chatState:PublishSubject<ChatState> = PublishSubject()
    
    public static var shared:EaseMobManager = EaseMobManager()
    private override init() {
        super.init()
    }
    var deviceToken:Data? {
        didSet {
            if EMClient.shared().isLoggedIn {
                bindDeviceToken()
            }
        }
    }
    func bindDeviceToken() {
        if let deviceToken = deviceToken {
            Async.userInitiated{
                let error = EMClient.shared().bindDeviceToken(deviceToken)
                if let error = error {
                    logError("环信: bindDeviceToken失败 -> code:\(error.code),errorDescription:\(error.errorDescription)")
                }else {
                    logInfo("环信: bindDeviceToken成功")
                }
            }
        }
    }
    // MARK: - 登录
    func configObserver() {
        self.loginedObserver()
            .subscribe(onNext:{[unowned self] (_) in
                self.bindDeviceToken()
            }).disposed(by: self.disposeBag)
    }
}
extension EaseMobManager {
    public func loginedObserver() -> Observable<()> {
        return self.chatState
            .filter{$0.isLogined()}
            .map{_ in ()}
            .share()
    }
}
extension EaseMobManager {
    public var isLogined:Bool {
        return EMClient.shared().isLoggedIn
    }
    public func login() {
        let username = UserInfo.shared.personModel.hxUser
        let password = UserInfo.shared.personModel.hxCode.md5String
        func EMLogin() {
            let error = EMClient.shared().login(withUsername: username, password: password)
            if let error = error {
                logError("环信: 登录失败 -> code:\(error.code),errorDescription:\(error.errorDescription)")
                self.chatState.onNext(.loginError)
            }else {
                logInfo("环信: 登录成功 -> username:\(username), password:\(password)")
                self.chatState.onNext(.logined)
//                EMClient.shared().options.isAutoLogin = true
                EMClient.shared().options.enableDeliveryAck = true
            }
        }
        
        if isLogined {
            if EMClient.shared().currentUsername == username {
                logDebug("环信: 已经登录 -> username:\(username)")
                return
            }else {
                self.logout { (_) in
                    EMLogin()
                }
            }
        }else {
            Async.userInitiated {
                EMLogin()
            }
        }
    }
    public func logout(_ closure:((Bool)->())? = nil) {
        Async.userInitiated {
            let error = EMClient.shared().logout(true)
            if let error = error {
                logError("环信: logout -> code:\(error.code),errorDescription:\(error.errorDescription)")
            }else {
                self.chatState.onNext(.logout)
                logInfo("环信: logout成功")
            }
            closure?(error == nil)
        }
    }
}
extension EaseMobManager {
    public func registerForRemoteNotifications(with deviceToken:Data) {
        self.deviceToken = deviceToken
    }
}
extension EaseMobManager:EMClientDelegate {
    public func connectionStateDidChange(_ aConnectionState: EMConnectionState) {
        logDebug("环信: didConnectionStateChanged -> \(aConnectionState==EMConnectionConnected ? "已连接":"未连接")")
        self.chatState.onNext(.connectionStateChanged(aConnectionState))
    }
    public func didAutoLoginWithError(_ aError: EMError!) {
        logError("环信: 自动登录失败 -> code:\(aError?.code ?? EMErrorGeneral)),errorDescription:\(aError?.errorDescription ?? "未知")")
        self.chatState.onNext(.autoLoginError)
    }
    public func didLoginFromOtherDevice() {
        logError("环信: 当前登录帐号在其它设备登录")
        self.chatState.onNext(.offLine)
    }
    public func didRemovedFromServer() {
        logError("环信: 当前登录帐号已经被从服务器端删除")
        self.chatState.onNext(.offLine)
    }
}
extension EaseMobManager {
    public func removeConversationFromDB(conversationId:String,_ closure:@escaping ()->()) {
        EMClient.shared().chatManager.deleteConversation(conversationId, isDeleteMessages: true) { (conversationId, error) in
            if let error = error {
                logError("环信: 删除会话失败 code:\(error.code), errorDescription:\(error.errorDescription)")
            }else {
                logInfo("环信: 删除会话成功")
            }
            closure()
        }
    }
    public func removeEmptyConversationsFromDB(_ closure:@escaping ()->()) {
        guard let conversations = EMClient.shared().chatManager.getAllConversations() as? [EMConversation] else {
            closure()
            return
        }
        var needRemoveConversations:[EMConversation] = [EMConversation]()
        for conversation in conversations {
            if conversation.latestMessage == nil || conversation.type == EMConversationTypeChatRoom {
                needRemoveConversations.append(conversation)
            }
        }
        guard needRemoveConversations.count > 0 else {
            closure()
            return
        }
        EMClient.shared().chatManager.deleteConversations(needRemoveConversations, isDeleteMessages: true, completion: { (error) in
            if let error = error {
                logError("环信: 删除会话数组失败 code:\(error.code), errorDescription:\(error.errorDescription)")
            }else {
                logInfo("环信: 删除会话数组成功")
            }
            closure()
        })
    }
}
