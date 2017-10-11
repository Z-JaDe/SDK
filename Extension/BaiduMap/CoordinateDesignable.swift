//
//  CoordinateDesignable.swift
//  PaiBaoTang
//
//  Created by 茶古电子商务 on 17/2/16.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation
import CoreLocation

public protocol CoordinateDesignable {
    var latitude:CLLocationDegrees? {get set}
    var longitude:CLLocationDegrees? {get set}
    var coordinate:CLLocationCoordinate2D? {get set}
}
extension CoordinateDesignable {
    public var coordinate:CLLocationCoordinate2D? {
        get {
            if let latitude = latitude, let longitude = longitude {
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }else {
                return nil
            }
        }
        set {
            latitude = newValue?.latitude
            longitude = newValue?.longitude
        }
    }
}
