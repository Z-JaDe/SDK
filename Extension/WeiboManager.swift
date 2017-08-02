//
//  WeiboManager.swift
//  ZiWoYou
//
//  Created by Z_JaDe on 2016/12/21.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import UIKit
import Alert
import AppInfoData
import ThirdSDK
import Extension
public class WeiboManager: ThirdManager {
    public static var shared:WeiboManager = WeiboManager()
    private override init(){}
    // MARK: - 登录
    open override func jumpAndAuth() {
        guard WeiboManager.canUseWeiboLogin() else {
            Alert.showPrompt(title: "微博登录", "不可以通过微博客户端登录，请检查您是否安装微博客户端")
            return
        }
        let request = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = WeiboRedirectURI
        request.scope = WeiboScope
        WeiboSDK.send(request)
    }
    
    // MARK: - 分享
    func shareToWeibo(_ shareModel:ShareModel) {
        guard WeiboManager.canUseWeiboShare() else {
            Alert.showPrompt(title: "微博分享", "不可以通过微博客户端进行分享，请检查您是否安装微博客户端")
            return
        }
        let req = getMessageToWeiboReq(shareModel)
        WeiboSDK.send(req)
    }
    // MARK: -
    override func requestLogin() {
        self.weiboRefreshToken {
            super.requestLogin()
        }
    }
}
extension WeiboManager {
    static func canUseWeiboShare() -> Bool {
        return WeiboSDK.isCanShareInWeiboAPP()
    }
    static func canUseWeiboLogin() -> Bool {
        return WeiboSDK.isCanSSOInWeiboApp()
    }
}
extension WeiboManager {
    func getMessageToWeiboReq(_ shareModel:ShareModel) -> WBSendMessageToWeiboRequest {
        let authRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        authRequest.scope = "all"
        
        let message = WBMessageObject()
        message.text = shareModel.text
        let webpage = WBWebpageObject()
        webpage.objectID = "identifier1"
        webpage.title = shareModel.title
        webpage.description = shareModel.intro
        webpage.thumbnailData = UIImage(named: "thumbImage")?.data()
        webpage.webpageUrl = shareModel.url
        message.mediaObject = webpage
        
        let request:WBSendMessageToWeiboRequest = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo: authRequest, access_token: nil) as! WBSendMessageToWeiboRequest
        return request
    }
}
extension WeiboManager {
    func weiboRefreshToken(_ callback:@escaping ()->()) {
        guard let expirationDate = Defaults[.wb_expirationDate] else {
            Alert.showConfirm(title: "微博登录", "微博登录出现问题，请重新获取授权", { (_) in
                self.jumpAndAuth()
            })
            return
        }
        guard expirationDate > Date(timeIntervalSinceNow: -3600) else {
            let hud = HUD.showMessage("获取微博登录参数中")
            _ = WBHttpRequest(forRenewAccessTokenWithRefreshToken: Defaults[.wb_refresh_token], queue: nil, withCompletionHandler: { (request, result, error) in
                hud.hide()
                guard error == nil else {
                    Alert.showConfirm(title: "微博登录", "微博登录失效，请重新获取授权", { (_) in
                        self.jumpAndAuth()
                    })
                    return
                }
                logDebug(result!)
            })
            return
        }
        callback()
    }
}
extension WeiboManager:WeiboSDKDelegate {
    open func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    open func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if let response = response as? WBAuthorizeResponse {
            // MARK: - 登录回调
            Defaults[.wb_userId] = response.userID
            Defaults[.wb_access_token] = response.accessToken
            Defaults[.wb_refresh_token] = response.refreshToken
            Defaults[.wb_expirationDate] = response.expirationDate
            self.request()
        }
    }
}
