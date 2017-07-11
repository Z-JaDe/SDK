//
//  DefaultsKeys+SDK.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/21.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import Foundation
import JDKit

public let openId_key:String = "openid"
public let access_token_key:String = "access_token"
public let refresh_token_key:String = "refresh_token"

public let errcode_key:String = "errcode"
public let errmsg_key:String = "errmsg"


public extension DefaultsKeys {
    // MARK: - wechat
    public static let wx_refresh_token = DefaultsKey<String?>("wx_refresh_token")
    public static let wx_access_token = DefaultsKey<String?>("wx_access_token")
    public static let wx_openId = DefaultsKey<String?>("wx_openId")
    
    // MARK: - QQ
    public static let qq_access_token = DefaultsKey<String?>("qq_access_token")
    public static let qq_openId = DefaultsKey<String?>("qq_openId")
    public static let qq_expirationDate = DefaultsKey<Date?>("qq_expirationDate")
    
    // MARK: - weibo
    public static let wb_refresh_token = DefaultsKey<String?>("wb_refresh_token")
    public static let wb_access_token = DefaultsKey<String?>("wb_access_token")
    public static let wb_userId = DefaultsKey<String?>("wb_userId")
    public static let wb_expirationDate = DefaultsKey<Date?>("wb_expirationDate")
    
}
