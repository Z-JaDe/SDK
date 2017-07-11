//
//  BaiduMap.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/6.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import JDKit

open class SDKConfig {
    open static func register() {
        let mapManager = BMKMapManager()
        let ret = mapManager.start(BapduMapAppKey, generalDelegate: nil)
        if ret == false {
            NSLog("百度地图 manager start failed!")
        }
        WXApi.registerApp(WechatAppid, withDescription: jd.appDisplayName)
        #if DEBUG
            WeiboSDK.enableDebugMode(true)
        #endif
        WeiboSDK.registerApp(WeiboAppKey)
    }
}
