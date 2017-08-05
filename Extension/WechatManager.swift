//
//  WXOAuthManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/21.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import Alert
import AppInfoData
import Extension
import Alamofire
import ThirdSDK

private var weChatPayKey:UInt8 = 0

open class WechatPayReqModel {
    public var appid:String?
    public var partnerid:String?
    public var prepayid:String?
    public var package:String?
    public var noncestr:String?
    public var timestamp:UInt32 = 0
    public var sign:String?
}

public class WechatManager:ThirdManager {
    public static var shared:WechatManager = WechatManager()
    private override init(){}
    // MARK: - 登录
    open override func jumpAndAuth() {
        guard WechatManager.canUseWeChat() else {
            Alert.showPrompt(title: "微信登录", "请检查是否已经安装微信客户端")
            return
        }
        let req = SendAuthReq()
        req.scope = WechatAuthScope
        /// ZJaDe: -[SendAuthReq setOpenId:]: unrecognized selector sent to instance 0x17064b19
//        req.openId = Defaults[.wx_openId]
        WXApi.sendAuthReq(req, viewController: rootVC(), delegate: self)
    }
    // MARK: - 支付
    open func requestToPay(_ payReqModel:WechatPayReqModel,_ callback:(Bool)->()) {
        setAssociatedObject(&weChatPayKey, callback)
        guard WechatManager.canUseWeChat() else {
            Alert.showPrompt(title: "微信支付", "请检查是否已经安装微信客户端")
            self.payCallBackConfig(isSuccessful: false)
            return
        }
        let request = PayReq()
        request.partnerId = payReqModel.partnerid
        request.prepayId = payReqModel.prepayid
        request.package = payReqModel.package
        request.nonceStr = payReqModel.noncestr
        request.timeStamp = payReqModel.timestamp
        request.sign = payReqModel.sign
        let result = WXApi.send(request)
        if result == false {
            self.payCallBackConfig(isSuccessful: false)
        }
    }
    // MARK: - 分享
    func shareToWeChat(_ shareModel:ShareModel) {
        guard WechatManager.canUseWeChat() else {
            Alert.showPrompt(title: "微信分享", "请安装微信客户端")
            return
        }
        let req = getMessageToWXReq(shareModel)
        req.scene = Int32(WXSceneSession.rawValue)
        let result:Bool = WXApi.send(req)
        HUD.showPrompt(result ? "微信分享成功" : "微信分享失败")
    }
    // MARK: -
    override func requestLogin() {
        self.wechatRefreshToken {
            super.requestLogin()
        }
    }
}
extension WechatManager {
    static func canUseWeChat() -> Bool {
        return WXApi.isWXAppInstalled() && WXApi.isWXAppSupport()
    }
}
extension WechatManager {
    func getMessageToWXReq(_ shareModel:ShareModel) -> SendMessageToWXReq {
        let message = WXMediaMessage();
        message.title = shareModel.title;
        message.description = shareModel.intro;
        message.setThumbImage(UIImage(named: "ic_thumbImage"))
        
        let webpageObject = WXWebpageObject()
        webpageObject.webpageUrl = shareModel.url
        message.mediaObject = webpageObject
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        return req
    }
    func shareToWeChatTimeline(_ shareModel:ShareModel) {
        guard WechatManager.canUseWeChat() else {
            Alert.showPrompt(title: "微信朋友圈分享", "请安装微信客户端")
            return
        }
        let req = getMessageToWXReq(shareModel)
        req.scene = Int32(WXSceneTimeline.rawValue)
        let result = WXApi.send(req)
        HUD.showPrompt(result ? "微信朋友圈分享成功" : "微信朋友圈分享失败")
    }
}
extension WechatManager {
    fileprivate func wechatAccessToken(_ resp:SendAuthResp) {
        guard resp.errCode == 0 else {
            return
        }
        let hud = HUD.showMessage("获取微信登录参数中")
        let urlStr = "https://api.weixin.qq.com/sns/oauth2/access_token"
        var params = [String:Any]()
        params["code"] = resp.code
        params["grant_type"] = "authorization_code"
        params["secret"] = WechatAppSecret
        params["appid"] = WechatAppid
        Alamofire.request(urlStr, method: .post, parameters: params).responseJSON { (response) in
            hud.hide()
            guard let dict = response.result.value as? NSDictionary, dict[errcode_key] == nil else {
                Alert.showConfirm(title: "微信登录", "获取微信登录参数出错，请重新获取授权", {(_) in
                    self.jumpAndAuth()
                })
                return
            }
            Defaults[.wx_access_token] = dict[access_token_key] as? String ?? ""
            Defaults[.wx_refresh_token] = dict[refresh_token_key] as? String ?? ""
            Defaults[.wx_openId] = dict[openId_key] as? String ?? ""
            self.request()
        }
    }
    fileprivate func wechatRefreshToken(_ callback:@escaping ()->()) {
        let hud = HUD.showMessage("刷新微信登录参数中")
        let urlStr = "https://api.weixin.qq.com/sns/oauth2/refresh_token"
        var params = [String:Any]()
        params["appid"] = WechatAppid
        params["grant_type"] = refresh_token_key
        params[refresh_token_key] = Defaults[.wx_refresh_token]
        Alamofire.request(urlStr, method: .post, parameters: params).responseJSON { (response) in
            hud.hide()
            guard let dict = response.result.value as? NSDictionary,dict[errcode_key] == nil,dict[refresh_token_key] != nil else {
                Alert.showConfirm(title: "微信登录", "微信登录失效，请重新获取授权", {(_) in
                    self.jumpAndAuth()
                })
                return
            }
            Defaults[.wx_access_token] = dict[access_token_key] as? String ?? ""
            callback()
        }
    }
}
extension WechatManager:WXApiDelegate {
    // MARK: - delegate
    open func onResp(_ resp: BaseResp!) {
        if let resp = resp as? SendAuthResp {
            // MARK: - 登录回调
            self.wechatAccessToken(resp)
        }else if let resp = resp as? PayResp {
            switch WXErrCode(resp.errCode) {
            case WXSuccess:
                HUD.showSuccess("支付成功")
                self.payCallBackConfig(isSuccessful: true)
            case WXErrCodeUserCancel:
                HUD.showSuccess("取消支付")
                self.payCallBackConfig(isSuccessful: false)
            default:
                HUD.showSuccess("支付失败")
                self.payCallBackConfig(isSuccessful: false)
            }
        }
    }
    open func payCallBackConfig(isSuccessful:Bool) {
        if let callback:(Bool)->() = associatedObject(&weChatPayKey) {
            callback(isSuccessful)
            let _callback:((Bool)->())? = nil
            setAssociatedObject(&weChatPayKey, _callback)
        }
    }
}
