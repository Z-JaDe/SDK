//
//  MessageManager+CreateMessage.swift
//  SDK
//
//  Created by 茶古电子商务 on 2017/12/6.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation
import Hyphenate
import ThirdSDK
extension MessageManager {
    public var messageNicknameKey:String {
        return "nickname"
    }
    public var messageImgUrlKey:String {
        return "imageUrl"
    }
    public typealias MessageExtType = [String:Any]
    public func textMessage(text:String,to:String,type:ConversationType,messageExt:MessageExtType = MessageExtType()) -> EMMessage {
        var messageExt = messageExt
        userInfoExt().forEach { (key,value) in
            messageExt[key] = value
        }
        return EaseSDKHelper.getTextMessage(text, to: to, messageType: type.EMChatType(), messageExt: messageExt)
    }
    public func imageMessage(image:UIImage,to:String,type:ConversationType) -> EMMessage {
        return EaseSDKHelper.getImageMessage(with: image, to: to, messageType: type.EMChatType(), messageExt: userInfoExt())
    }
    public func locationMessage(coordinate:CLLocationCoordinate2D,address:String,to:String,type:ConversationType) -> EMMessage {
        return EaseSDKHelper.getLocationMessage(withLatitude: coordinate.latitude, longitude: coordinate.longitude, address: address, to: to, messageType: type.EMChatType(), messageExt: userInfoExt())
    }
    func userInfoExt() -> MessageExtType {
        return [messageNicknameKey:UserInfo.shared.personModel.userInfo.nickname,
                messageImgUrlKey:UserInfo.shared.personModel.userInfo.uimg]
    }
}
