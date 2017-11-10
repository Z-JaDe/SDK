//
//  AddressComponentModel.swift
//  ZiWoYou
//
//  Created by Z_JaDe on 2017/1/17.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//
    
import Foundation
import CoreLocation

public class AddressComponentModel:CoordinateDesignable {
    public var sematicDescription:String?
    public var businessCircle:String?
    public var province:String = ""
    public var city:String = ""
    public var area:String = ""
    public var address:String = ""
    
    public var latitude:CLLocationDegrees?
    public var longitude:CLLocationDegrees?
    
    public func detailAddress() -> String {
        return self.provinceAddress() + self.address
    }
    public func provinceAddress() -> String {
        return self.province + self.city + self.area
    }
    public func areaAddress() -> String {
        return self.area + self.address
    }
}
