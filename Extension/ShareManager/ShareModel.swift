//
//  ShareModel.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 17/3/21.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation

open class ShareModel {
    open var title:String = ""
    open var intro:String = ""
    open var logo:String = ""
    open var url:String = ""
    open lazy var text:String = {
        return "这个APP还不错你可以试试看，地址是\(self.url)\n\(self.intro)"
    }()
}
