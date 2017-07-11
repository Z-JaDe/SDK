//
//  ThirdManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/21.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation

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
    open func jumpAndAuth() {
        
    }
    
    open func requestLogin(needRefreshToken:Bool,onlyRequest:Bool) {
        
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
                    AlipayManager.shared.payCallBackConfig(resultDic)
                })
                result = true
            }
        }
        return result
    }
}
