//
//  WXOAuthManager.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/21.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import Alert
import AlipaySDK
import Basic
private var alipayPayKey:UInt8 = 0

open class AlipayManager:ThirdManager {
    open static let shared = AlipayManager()
    private override init() {}
}
extension AlipayManager {
    open func requestToPay(_ orderStr:String,_ callback: @escaping (Bool)->()) {
        setAssociatedObject(&alipayPayKey, callback)
        AlipaySDK.defaultService().payOrder(orderStr, fromScheme: PaiBaoTangScheme) { (resultDict) in
            self.payCallBackConfig(resultDict)
        }
    }
    open func payCallBackConfig(_ resultDict:[AnyHashable:Any]?) {
        if let callback:(Bool)->() = associatedObject(&alipayPayKey) {
            
            if let resultDict = resultDict,let memo = resultDict["memo"] as? String {
                if resultDict["resultStatus"] as? String == "9000" {
                    callback(true)
                    HUDManager.showSuccess(memo)
                }else {
                    callback(false)
                    HUDManager.showError(memo)
                }
            }else {
                HUDManager.showError("支付宝支付失败，未知错误")
                callback(false)
            }
            
            let _callback:((Bool)->())? = nil
            setAssociatedObject(&alipayPayKey, _callback)
        }
    }
}
