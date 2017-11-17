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

public class EaseMobManager:ThirdManager {
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
                    logDebug("环信: bindDeviceToken成功")
                }
            }
        }
    }
    // MARK: - 登录
    func configObserver() {
        let login = NotificationCenter.default.rx.notification(.ReSetMyUserInfoComplete)
        Observable.concat([login])
            .subscribe(onNext:{[unowned self] (notification) in
                self.login()
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(.ChatLoginSuccessful)
            .subscribe(onNext:{[unowned self] (notification) in
                self.bindDeviceToken()
            }).disposed(by: self.disposeBag)
    }
}
extension EaseMobManager {
    func login() {
        let username = UserInfo.shared.personModel.hxUser
        let password = UserInfo.shared.personModel.hxCode.md5String
        func EMLogin() {
            let error = EMClient.shared().login(withUsername: username, password: password)
            if let error = error {
                logError("环信: 登录失败 -> code:\(error.code),errorDescription:\(error.errorDescription)")
            }else {
                logDebug("环信: 登录成功 -> username:\(username), password:\(password)")
                NotificationCenter.default.post(name: .ChatLoginSuccessful, object: nil)
            }
        }
        
        if EMClient.shared().isLoggedIn {
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
    func logout(_ closure:@escaping (Bool)->()) {
        Async.userInitiated {
            let error = EMClient.shared().logout(true)
            if let error = error {
                logError("环信: logout -> code:\(error.code),errorDescription:\(error.errorDescription)")
            }else {
                logDebug("环信: logout成功")
            }
            closure(error == nil)
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
    }
    public func didAutoLoginWithError(_ aError: EMError!) {
        logError("环信: 自动登录失败 -> code:\(aError.code),errorDescription:\(aError.errorDescription)")
    }
    public func didLoginFromOtherDevice() {
        logError("环信: 当前登录帐号在其它设备登录")
    }
    public func didRemovedFromServer() {
        logError("环信: 当前登录帐号已经被从服务器端删除")
    }
}
extension EaseMobManager {
    public func removeEmptyConversationsFromDB() {
        guard let conversations = EMClient.shared().chatManager.getAllConversations() as? [EMConversation] else {
            return
        }
        var needRemoveConversations:[EMConversation] = [EMConversation]()
        for conversation in conversations {
            if conversation.conversationId == serverName {
                continue
            }
            if conversation.latestMessage == nil || conversation.type == EMConversationTypeChatRoom {
                needRemoveConversations.append(conversation)
            }
            guard needRemoveConversations.count > 0 else {
                return
            }
            EMClient.shared().chatManager.deleteConversations(needRemoveConversations, isDeleteMessages: true, completion: { (error) in
                if let error = error {
                    logDebug("环信: 删除会话失败 code:\(error.code), errorDescription:\(error.errorDescription)")
                }else {
                    logDebug("环信: 删除会话成功")
                }
            })
        }
    }
}
