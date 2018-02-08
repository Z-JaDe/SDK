//
//  ShareModel.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 17/3/21.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation

public class ShareModel:Codable {
    public var title:String = ""
    public var contents:String = ""
    public var logo:String = ""
    public var url:String = ""
    public lazy var text:String = {
        return "这个APP还不错你可以试试看，地址是\(self.url)\n\(self.contents)"
    }()
}
