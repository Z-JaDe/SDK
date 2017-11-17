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
import ThirdSDK
import AppInfoData

public class EaseMobManager:ThirdManager {
    public static var shared:EaseMobManager = EaseMobManager()
    private override init() {
        super.init()
        configObserver()
    }
    // MARK: - 登录
    func configObserver() {
        let login = NotificationCenter.default.rx.notification(.ReSetMyUserInfoComplete)
        Observable.concat([login])
            .subscribe(onNext:{[unowned self] (notification) in
                self.login()
            }).disposed(by: disposeBag)
    }
}
extension EaseMobManager {
    func login() {
        let username = UserInfo.shared.personModel.hxUser
        let password = UserInfo.shared.personModel.hxCode.md5String
        if EMClient.shared().isLoggedIn {
            if EMClient.shared().currentUsername == username {
                logDebug("已经登录")
                return
            }else {
                self.logout()
            }
        }
        Async.userInitiated {
            let error = EMClient.shared().login(withUsername: username, password: password)
            if let error = error {
                logError("登录失败 --> code->\(error.code),errorDescription->\(error.errorDescription)")
            }else {
                logDebug("登录成功 --> username->\(username), password->\(password)")
                NotificationCenter.default.post(name: .ChatLoginSuccessful, object: nil)
            }
        }
    }
    func logout() {
        Async.userInitiated {
            let error = EMClient.shared().logout(true)
            if let error = error {
                logError("logout --> code->\(error.code),errorDescription->\(error.errorDescription)")
            }else {
                logDebug("logout成功")
            }
        }
    }
}
extension EaseMobManager {
    public func registerForRemoteNotifications(with deviceToken:Data) {
        func register() {
            EMClient.shared().bindDeviceToken(deviceToken)
            logDebug(deviceToken)
        }
        if EMClient.shared().isLoggedIn {
            register()
        }else {
            NotificationCenter.default.rx
                .notification(.ChatLoginSuccessful)
                .take(1)
                .subscribe(onNext:{ (notification) in
                    register()
                }).disposed(by: self.disposeBag)
        }
    }
}
extension EaseMobManager:EMClientDelegate {
    public func connectionStateDidChange(_ aConnectionState: EMConnectionState) {
        logDebug("didConnectionStateChanged -> \(aConnectionState==EMConnectionConnected ? "已连接":"未连接")")
    }
    public func didAutoLoginWithError(_ aError: EMError!) {
        logError("自动登录失败 --> code->\(aError.code),errorDescription->\(aError.errorDescription)")
    }
    public func didLoginFromOtherDevice() {
        logError("当前登录帐号在其它设备登录")
    }
    public func didRemovedFromServer() {
        logError("当前登录帐号已经被从服务器端删除")
    }
}
