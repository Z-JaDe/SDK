//
//  ThirdManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/21.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import ThirdSDK
public enum ThirdAuthType {
    case binding
    case login
}

open class ThirdManager:NSObject {
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
            self.requestLogin()
        }
    }
    func requestLogin() {
        self.requestLoginClosure!()
    }
    
    /// ZJaDe: 
    func rootVC() -> UIViewController {
        return UIApplication.shared.delegate!.window!!.rootViewController!
    }
}
extension ThirdManager {
    func request(_ urlStr:String,params:[String:Any]? = nil,completionHandler:@escaping ((NSDictionary?)->())) {
        let url:URL = URL(string: urlStr)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,error == nil else {
                completionHandler(nil)
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let object:NSDictionary = json as? NSDictionary {
                completionHandler(object)
            }else {
                completionHandler(nil)
            }
        }.resume()
        
    }
}
extension ThirdManager {
    open static func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var result = false
        if result == false {
            result = WXApi.handleOpen(url, delegate: WechatManager.shared)
        }
        if result == false && TencentOAuth.canHandleOpen(url) {
            result = TencentOAuth.handleOpen(url)
        }
        if result == false {
            result = WeiboSDK.handleOpen(url, delegate: WeiboManager.shared)
        }
        if result == false {
            if url.host == "safepay" || url.host == "platformapi" {
                AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                    AlipayManager().payCallBackConfig(resultDic)
                })
                result = true
            }
        }
        return result
    }
}
