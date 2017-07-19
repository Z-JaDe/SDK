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
    open var authType:ThirdAuthType!
    
    open func binding() {
        self.authType = .binding
        self.jumpAndAuth()
    }
    open func loginAndAuth() {
        self.authType = .login
        self.jumpAndAuth()
    }
    func jumpAndAuth() {
        
    }
    
    open var requestLoginClosure:(()->())?
    open var requestBindingClosure:(()->())?
    func request() {
        switch self.authType! {
        case .binding:
            self.requestToBinding()
        case .login:
            self.requestLogin()
        }
    }
    func requestLogin() {
        self.requestLoginClosure!()
    }
    func requestToBinding() {
        self.requestBindingClosure!()
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
