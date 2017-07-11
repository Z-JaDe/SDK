//
//  EmailManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 17/3/21.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation
import JDKit
import MessageUI

class MessageUIManager:ThirdManager {
    open static let shared = MessageUIManager()
    private override init() {}
}
extension MessageUIManager:MFMailComposeViewControllerDelegate {
    func canUseEmail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    // MARK: - 邮件分享
    func shareToEmail(_ shareModel:ShareModel) {
        guard self.canUseEmail() else {
            Alert.showPrompt(title: "邮箱分享", "无法使用邮箱分享")
            return
        }
        let picker = MFMailComposeViewController()
        picker.setSubject(shareModel.title)
        picker.setMessageBody(shareModel.text, isHTML: false)
        picker.mailComposeDelegate = self
        jd.currentNavC.presentVC(picker, animated: true)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if (result == .sent) {
            HUD.showPrompt("已经点击发送")
        }
        jd.visibleVC()?.dismissVC()
    }
}
extension MessageUIManager:MFMessageComposeViewControllerDelegate {
    func canUseMessage() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    // MARK: - 短信分享
    func shareToMessage(_ shareModel:ShareModel) {
        guard self.canUseMessage() else {
            Alert.showPrompt(title: "短信分享", "无法使用短信分享")
            return
        }
        let picker = MFMessageComposeViewController()
        picker.subject = shareModel.title
        picker.body = shareModel.text
        picker.messageComposeDelegate = self
        jd.currentNavC.presentVC(picker, animated: true)
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if (result == .sent) {
            HUD.showPrompt("已经点击发送")
        }
        jd.visibleVC()?.dismissVC()
    }
}
