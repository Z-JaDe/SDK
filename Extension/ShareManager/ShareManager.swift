//
//  ShareManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 17/3/21.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation
import Extension
public enum ShareItem:String,Equatable {
    case QQ好友
    case QQ空间
    case 微信好友
    case 微信朋友圈
//    case 新浪微博
    case Email
    case 短信
    case 复制链接
    
    public func image() -> UIImage {
        return UIImage(named: "ShareImage.bundle/\(self.rawValue)", in: Bundle(for: ShareManager.self), compatibleWith: nil)!
    }
}
public class ShareManager {
    public init() {}
    public var shareModel:ShareModel?
    public lazy var shareArray:[ShareItem] = {
        var array = [ShareItem]()
        if QQManager.canUseQQShare() {
            array.append(.QQ好友)
            array.append(.QQ空间)
        }else if QQManager.canUseQzoneShare() {
            array.append(.QQ空间)
        }
        if WechatManager.canUseWeChat() {
            array.append(.微信好友)
            array.append(.微信朋友圈)
        }
//        if WeiboManager.canUseWeiboShare() {
//            array.append(.新浪微博)
//        }
        if MessageUIManager.canUseEmail() {
            array.append(.Email)
        }
        if MessageUIManager.canUseMessage() {
            array.append(.短信)
        }
        array.append(.复制链接)
        return array
    }()
}
extension ShareManager {
    public func share(_ item:ShareItem) {
        switch item {
        case .QQ好友:
            self.shareToQQ()
        case .QQ空间:
            self.shareToQzone()
        case .微信好友:
            self.shareToWeChat()
        case .微信朋友圈:
            self.shareToWeChatTimeline()
//        case .新浪微博:
//            self.shareToWeibo()
        case .Email:
            self.shareToEmail()
        case .短信:
            self.shareToMessage()
        case .复制链接:
            self.shareToPasteboard()
        }
    }
    
    func shareToQQ() {
        guard let shareModel = shareModel else {
            return
        }
        QQManager.shared.shareToQQ(shareModel)
    }
    func shareToQzone() {
        guard let shareModel = shareModel else {
            return
        }
        QQManager.shared.shareToQzone(shareModel)
    }
    func shareToWeChat() {
        guard let shareModel = shareModel else {
            return
        }
        WechatManager.shared.shareToWeChat(shareModel)
    }
    func shareToWeChatTimeline() {
        guard let shareModel = shareModel else {
            return
        }
        WechatManager.shared.shareToWeChatTimeline(shareModel)
    }
    func shareToWeibo() {
        guard let shareModel = shareModel else {
            return
        }
        WeiboManager.shared.shareToWeibo(shareModel)
    }
    func shareToEmail() {
        guard let shareModel = shareModel else {
            return
        }
        MessageUIManager().shareToEmail(shareModel)
    }
    func shareToMessage() {
        guard let shareModel = shareModel else {
            return
        }
        MessageUIManager().shareToMessage(shareModel)
    }
    func shareToPasteboard() {
        guard let shareModel = shareModel else {
            return
        }
        jd.copy(shareModel.text)
        HUD.showPrompt("已拷贝")
    }
}
