//
//  BaiduMap.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/6.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import ThirdSDK
import Extension
public class SDKConfig {
    public static let shared:SDKConfig = SDKConfig()
    private init() {}
    
    public func register(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
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
        // MARK: - 环信
        #if DEBUG
            let apnsCertName = EaseMobAPNsDevelopment
            let enableConsoleLogger = true
        #else
            let apnsCertName = EaseMobAPNsPush
            let enableConsoleLogger = false
        #endif
        EaseSDKHelper.share().hyphenateApplication(application, didFinishLaunchingWithOptions: launchOptions, appkey: EaseMobAppkey, apnsCertName: apnsCertName, otherConfig: [kSDKConfigEnableConsoleLogger:enableConsoleLogger])
        EMClient.shared().add(EaseMobManager.shared, delegateQueue: nil)
        BadgeManager.shared.configObserver()
        EaseMobManager.shared.configObserver()
    }
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
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
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        EaseMobManager.shared.registerForRemoteNotifications(with: deviceToken)
    }
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logDebug("RegisterForRemoteNotificationsError->\(error)")
    }
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        EaseSDKHelper.share().hyphenateApplication(application, didReceiveRemoteNotification: userInfo)
    }
}
