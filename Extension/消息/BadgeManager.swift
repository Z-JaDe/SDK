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
class BadgeManager: ThirdManager {
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
        // TODO:
    }
}
