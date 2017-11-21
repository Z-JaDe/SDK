//
//  BadgeManager.swift
//  SDK
//
//  Created by 茶古电子商务 on 2017/11/16.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import AudioToolbox
import Hyphenate

public class BadgeManager: ThirdManager {
    public static var shared:BadgeManager = BadgeManager()
    private override init() {
        super.init()
    }
    // MARK: - 进入后台时更新,点击聊天列表cell时更新
    func configObserver() {
        let didEnterBack = NotificationCenter.default.rx.notification(.UIApplicationDidEnterBackground)
        let setupCount = NotificationCenter.default.rx.notification(.SetupUnreadMessageCount)
        Observable.concat([didEnterBack,setupCount])
            .subscribe(onNext:{[unowned self] (notification) in
                self.updateAllBadge()
            }).disposed(by: disposeBag)
    }
    func updateAllBadge() {
        let totalBadge = self.totalBadge
        UIApplication.shared.applicationIconBadgeNumber = totalBadge
    }
    
    public func sendSetupUnreadMessageCountNotification() {
        NotificationCenter.default.post(name: .SetupUnreadMessageCount, object: nil)
    }
}
extension BadgeManager {
    /// ZJaDe: 震动、响音
    func remindAndVibrate() {
        AudioServicesPlaySystemSound(1007)
        vibrate()
    }
    /// ZJaDe: 震动
    func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
extension BadgeManager {
    public func formatBadge(_ badge:Int?) -> String? {
        if let badge = badge, badge > 0 {
            return badge > 999 ? "999+" : "\(badge)"
        }
        return nil
    }
    public func totalBadgeStr() -> String? {
        return self.formatBadge(self.totalBadge)
    }
}
extension DefaultsKeys {
    static let serverBadge = DefaultsKey<Int>("serverBadge")
}
extension BadgeManager {
    public var serverBadge:Int {
        get {return Defaults[.serverBadge]}
        set {
            Defaults[.serverBadge] = newValue > 0 ? newValue : 0
            sendSetupUnreadMessageCountNotification()
        }
    }
    func resetServerBadge(_ badge:Int) {
        if badge > self.serverBadge {
            self.remindAndVibrate()
        }
        self.serverBadge = badge
    }
    func reduceServerBadge() {
        self.serverBadge -= 1
    }
    func increaseServerBadge() {
        self.vibrate()
        self.serverBadge += 1
    }
}
extension BadgeManager {
    var messageBadge:Int {
        var total:Int = 0
        guard let conversations = EMClient.shared().chatManager.getAllConversations() as? [EMConversation] else {
            return total
        }
        for conversation in conversations {
            if conversation.conversationId == serverName {
                continue
            }
            total += Int(conversation.unreadMessagesCount)
        }
        return total
    }
    public var totalBadge:Int {
        return self.serverBadge + self.messageBadge
    }
}

