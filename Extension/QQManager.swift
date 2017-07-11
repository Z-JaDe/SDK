//
//  QQManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/21.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import JDKit

open class QQManager:ThirdManager {
    open static let shared = QQManager()
    private override init() {
        super.init()
        self.tencentOAuth.openSDKWebViewQQShareEnable()
    }
    // MARK: -
    open lazy var tencentOAuth:TencentOAuth = {
        let tencentOAuth = TencentOAuth(appId: TencentAppid, andDelegate: self)!
        return tencentOAuth
    }()
    func canUseQQShare() -> Bool {
        return TencentOAuth.iphoneQQInstalled()
    }
    func canUseQQLogin() -> Bool {
        return TencentOAuth.iphoneQQSupportSSOLogin()
    }
    func canUseQzoneShare() -> Bool {
        return canUseQQShare() || TencentOAuth.iphoneQZoneInstalled()
    }
    
    open override func jumpAndAuth() {
        guard self.canUseQQLogin() else {
            Alert.showPrompt(title: "QQ登录", "请安装QQ客户端")
            return
        }
        let permissions = [kOPEN_PERMISSION_GET_USER_INFO,
                           kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                           kOPEN_PERMISSION_ADD_ONE_BLOG,
                           kOPEN_PERMISSION_ADD_SHARE,
                           kOPEN_PERMISSION_ADD_TOPIC,
                           kOPEN_PERMISSION_CHECK_PAGE_FANS,
                           kOPEN_PERMISSION_GET_INFO,
                           kOPEN_PERMISSION_GET_OTHER_INFO,
                           kOPEN_PERMISSION_LIST_ALBUM,
                           kOPEN_PERMISSION_UPLOAD_PIC,
                           kOPEN_PERMISSION_GET_VIP_INFO,
                           kOPEN_PERMISSION_GET_VIP_RICH_INFO]
        self.tencentOAuth.authorize(permissions)
    }
    // MARK: - 分享

    func shareToQQ(_ shareModel:ShareModel) {
        guard self.canUseQQShare() else {
            Alert.showPrompt(title: "QQ分享", "请安装QQ客户端")
            return
        }
        let req = getMessageToQQReq(shareModel)
        let sent = QQApiInterface.send(req)
        self.handleSendResult(sendResult: sent)
    }
    func shareToQzone(_ shareModel:ShareModel) {
        guard self.canUseQzoneShare() else {
            Alert.showPrompt(title: "QQ空间分享", "请安装QQ客户端或者QZone客户端")
            return
        }
        let req = getMessageToQQReq(shareModel)
        let sent = QQApiInterface.sendReq(toQZone:req)
        self.handleSendResult(sendResult: sent)
    }
    func getMessageToQQReq(_ shareModel:ShareModel) -> SendMessageToQQReq {
        let newsObj:QQApiNewsObject = QQApiNewsObject.object(with: URL(string: shareModel.url), title: shareModel.title, description: shareModel.intro, previewImageURL: URL(string: shareModel.logo)) as! QQApiNewsObject
        return SendMessageToQQReq(content: newsObj)
    }
    func handleSendResult(sendResult:QQApiSendResultCode) {
        switch sendResult {
        case EQQAPIAPPNOTREGISTED:
            HUD.showPrompt("App未注册")
        case EQQAPIMESSAGECONTENTINVALID,EQQAPIMESSAGECONTENTNULL,EQQAPIMESSAGETYPEINVALID:
            HUD.showPrompt("发送参数错误")
        case EQQAPIQQNOTINSTALLED:
            HUD.showPrompt("未安装手Q")
        case EQQAPIQQNOTSUPPORTAPI:
            HUD.showPrompt("API接口不支持")
        case EQQAPISENDFAILD:
            HUD.showPrompt("发送失败")
        case EQQAPIQZONENOTSUPPORTTEXT:
            HUD.showPrompt("空间分享不支持纯文本分享，请使用图文分享")
        case EQQAPIQZONENOTSUPPORTIMAGE:
            HUD.showPrompt("空间分享不支持纯图片分享，请使用图文分享")
        default:
            break
        }
    }
    // MARK: -
    open override func requestLogin(needRefreshToken:Bool = true,onlyRequest:Bool = false) {
        self.qqRefreshToken {
            LoginModel.requestToLogin(loginType: .qqLogin, onlyRequest: onlyRequest)
        }
    }
    fileprivate func requestToBinding() {
        LoginModel.requestToBindingQQ()
    }
    // MARK: -
}
extension QQManager {
    fileprivate func qqRefreshToken(_ callback:@escaping ()->()) {
        guard let expirationDate = Defaults[.qq_expirationDate] else {
            Alert.showChoice(title: "QQ登录", "QQ登录出现问题，请重新获取授权", {
                self.jumpAndAuth()
            })
            return
        }
        guard expirationDate > Date(timeIntervalSinceNow: -3600) else {
            Alert.showChoice(title: "QQ登录", "QQ登录失效，请重新获取授权", {
                self.jumpAndAuth()
            })
            return
        }
        callback()
    }
}

extension QQManager:TencentSessionDelegate {
    open func tencentDidLogin() {
        guard let accessToken = self.tencentOAuth.accessToken,accessToken.length > 0 else {
            return
        }
        Defaults[.qq_access_token] = self.tencentOAuth.accessToken
        Defaults[.qq_openId] = self.tencentOAuth.openId
        Defaults[.qq_expirationDate] = self.tencentOAuth.expirationDate
        switch self.authType! {
        case .binding:
            self.requestToBinding()
        case .login:
            self.requestLogin()
        }
    }
    open func tencentDidNotLogin(_ cancelled: Bool) {
        
    }
    open func tencentDidNotNetWork() {
        
    }
}
