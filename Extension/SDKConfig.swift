//
//  BaiduMap.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/6.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import ThirdSDK
import AppInfoData
open class SDKConfig {
    open static func register() {
        let mapManager = BMKMapManager()
        let ret = mapManager.start(BaiduMapAppkey, generalDelegate: nil)
        if ret == false {
            logError("百度地图 manager start failed!")
        }
        
        if !WechatAppid.isEmpty {
            WXApi.registerApp(WechatAppid)
        }
        #if DEBUG
            WeiboSDK.enableDebugMode(true)
        #endif
        if !WeiboAppKey.isEmpty {
            WeiboSDK.registerApp(WeiboAppKey)
        }
    }
}
