//
//  BaiduMap.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/6.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import WeiboSDK
import Basic
open class SDKConfig {
    open static func register() {
        WXApi.registerApp(WechatAppid)
        #if DEBUG
            WeiboSDK.enableDebugMode(true)
        #endif
        WeiboSDK.registerApp(WeiboAppKey)
    }
}
