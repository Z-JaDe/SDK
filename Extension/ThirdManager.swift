//
//  ThirdManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/21.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import RxSwift

open class ThirdManager:NSObject {
    let disposeBag:DisposeBag = DisposeBag()
    /// ZJaDe: 
    func rootVC() -> UIViewController {
        return UIApplication.shared.delegate!.window!!.rootViewController!
    }
}

