//
//  RequestLocationProtocol.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 17/2/6.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation
import RxSwift
import JDKit

protocol RequestLocationProtocol:ObjDisposeBagProtocol {
    var coordinate:CLLocationCoordinate2D? {get set}
    var coordinateChanged:PublishSubject<CLLocationCoordinate2D> {get set}
    func requestCoordinate(alertError:Bool)
}
extension RequestLocationProtocol where Self:BaseViewController {
    func requestCoordinate(alertError:Bool = false) {
        let observe:Observable<BMKUserLocation>
        if alertError {
            observe = BMKLocationManager().getLocation()
        }else {
            observe = BMKLocationManager().getLocationIfCan()
        }
        observe.subscribe(onNext:{[unowned self] (userLocation) in
            let coordinate = userLocation.location.coordinate
            self.coordinate = coordinate
            self.coordinateChanged.onNext(coordinate)
        }).addDisposableTo(disposeBag)
    }
}
private var coordinateKey:UInt8 = 0
private var coordinateChangedKey:UInt8 = 0
extension BaseViewController {
    var coordinate:CLLocationCoordinate2D? {
        get{return associatedObject(&coordinateKey)}
        set{setAssociatedObject(&coordinateKey, newValue)}
    }
    var coordinateChanged:PublishSubject<CLLocationCoordinate2D> {
        get{return associatedObject(&coordinateChangedKey, createIfNeed: {PublishSubject<CLLocationCoordinate2D>()})}
        set{setAssociatedObject(&coordinateChangedKey, newValue)}
    }
}

