//
//  EmailManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 17/3/21.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation
import MessageUI
import Extension
class MessageUIManager:ThirdManager {
    // MARK: - 邮件分享
    func shareToEmail(_ shareModel:ShareModel) {
        guard MessageUIManager.canUseEmail() else {
            Alert.showPrompt(title: "邮箱分享", "无法使用邮箱分享")
            return
        }
        let picker = MFMailComposeViewController()
        picker.setSubject(shareModel.title)
        picker.setMessageBody(shareModel.text, isHTML: false)
        picker.mailComposeDelegate = self
        rootVC().presentVC(picker, animated: true)
    }
    // MARK: - 短信分享
    func shareToMessage(_ shareModel:ShareModel) {
        guard MessageUIManager.canUseMessage() else {
            Alert.showPrompt(title: "短信分享", "无法使用短信分享")
            return
        }
        let picker = MFMessageComposeViewController()
        picker.subject = shareModel.title
        picker.body = shareModel.text
        picker.messageComposeDelegate = self
        rootVC().presentVC(picker, animated: true)
    }

}
extension MessageUIManager {
    static func canUseEmail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    static func canUseMessage() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
}
extension MessageUIManager:MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if (result == .sent) {
            HUD.showPrompt("已经点击发送")
        }
        controller.dismissVC()
    }
}
extension MessageUIManager:MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if (result == .sent) {
            HUD.showPrompt("已经点击发送")
        }
        controller.dismissVC()
    }
}
