//
//  AddressComponentModel.swift
//  ZiWoYou
//
//  Created by Z_JaDe on 2017/1/17.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//
    
import Foundation
import CoreLocation
import Alert

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
    
    public func checkParams() -> Bool {
        guard self.coordinate != nil else {
            HUD.showPrompt("请点击进行定位")
            return false
        }
        guard self.province.count > 0 else {
            HUD.showPrompt("定位没有转换成地址，请重新尝试")
            return false
        }
        return true
    }
    public func catchParams() -> [String:Any] {
        var params = [String : Any]()
        if let coordinate = self.coordinate {
            params["latitude"] = coordinate.latitude
            params["longitude"] = coordinate.longitude
        }else {
            params["latitude"] = ""
            params["longitude"] = ""
        }
        params["province"] = self.province
        params["city"] = self.city
        params["area"] = self.area
        params["address"] = self.address
        return params
    }
}
