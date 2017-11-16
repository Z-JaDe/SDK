//
//  WXOAuthManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/21.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import ThirdSDK

public class AlipayManager:ThirdManager {
    fileprivate var payCallback:((Bool)->())?
    
    open func requestToPay(_ orderStr:String,_ callback: @escaping (Bool)->()) {
        self.payCallback = callback
        AlipaySDK.defaultService().payOrder(orderStr, fromScheme: PaiBaoTangScheme) { (resultDict) in
            self.payCallBackConfig(resultDict)
        }
    }
}
extension AlipayManager {
    func payCallBackConfig(_ resultDict:[AnyHashable:Any]?) {
        if let callback:(Bool)->() = self.payCallback {
            
            if let resultDict = resultDict,let memo = resultDict["memo"] as? String {
                if resultDict["resultStatus"] as? String == "9000" {
                    callback(true)
                    HUD.showSuccess(memo)
                }else {
                    callback(false)
                    HUD.showError(memo)
                }
            }else {
                HUD.showError("支付宝支付失败，未知错误")
                callback(false)
            }
            
            self.payCallback = nil
        }
    }
}
