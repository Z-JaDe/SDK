//
//  ThirdLoginManager.swift
//  SDK
//
//  Created by 茶古电子商务 on 2017/11/16.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import UIKit
public enum ThirdAuthType {
    case binding
    case login
}

open class ThirdLoginManager: ThirdManager {
    var authType:ThirdAuthType!
    // MARK: - 跳转第三方app并请求绑定
    public func jumpBinding(_ bindingRequestClosure:@escaping ()->()) {
        self.requestBindingClosure = bindingRequestClosure
        self.authType = .binding
        self.jumpAndAuth()
    }
    // MARK: - 跳转第三方app并请求登录
    public func jumpLoginAndAuth(_ loginRequestClosure:@escaping ()->()) {
        self.requestLoginClosure = loginRequestClosure
        self.authType = .login
        self.jumpAndAuth()
    }
    /// ZJaDe: 请求登录并检查参数有效期
    public func requestLoginAndRefreshParams(_ loginRequestClosure:@escaping ()->()) {
        self.requestLoginClosure = loginRequestClosure
        self.authType = .login
        self.requestLogin()
    }
    /// ZJaDe: 子类继承跳转第三方app逻辑
    func jumpAndAuth() {
        
    }
    /// ZJaDe: 存储登录和绑定的请求闭包
    var requestLoginClosure:(()->())?
    var requestBindingClosure:(()->())?
    /// ZJaDe: 子类直接调用
    func request() {
        switch self.authType! {
        case .binding:
            self.requestBindingClosure!()
        case .login:
            self.requestLoginClosure!()
        }
    }
    /// ZJaDe: 请求登录并检查参数有效期 --子类继承
    func requestLogin() {
        self.requestLoginClosure!()
    }
}
