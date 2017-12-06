//
//  ConversationType.swift
//  PaiBaoTang
//
//  Created by 茶古电子商务 on 2017/11/21.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation

public enum ConversationType {
    case chat
    case groupChat
    
    public init?(conversation:EMConversation) {
        switch conversation.type {
        case EMConversationTypeChat:
            self = .chat
        case EMConversationTypeGroupChat,EMConversationTypeChatRoom:
            self = .groupChat
        default:
            return nil
        }
    }
    public func EMChatType() -> EMChatType {
        switch self {
        case .chat:
            return EMChatTypeChat
        case .groupChat:
            return EMChatTypeGroupChat
        }
    }
    public func EMConversationType() -> EMConversationType {
        switch self {
        case .chat:
            return EMConversationTypeChat
        case .groupChat:
            return EMConversationTypeGroupChat
        }
    }
}
