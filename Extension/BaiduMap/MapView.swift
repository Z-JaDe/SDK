//
//  MapView.swift
//  SDK
//
//  Created by 茶古电子商务 on 2017/10/12.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import UIKit
import ThirdSDK
import RxSwift
public class MapView: BMKMapView {
    public var didUpdateLocation = PublishSubject<BMKUserLocation>()
    public var currentLocation:BMKUserLocation? {
        didSet {
            if let currentLocation = self.currentLocation {
                self.didUpdateLocation.onNext(currentLocation)
            }
        }
    }
    
    
    // MARK: - BMKMapViewDelegate
    public var regionDidChange = PublishSubject<Void>()

    public func configMapViewWhenAppear() {
        self.delegate = self
    }
    public func configMapViewWhenDisAppear() {
        self.delegate = nil
    }
    
    public func showMyLocation() {
        self.userTrackingMode = BMKUserTrackingModeFollowWithHeading
    }
    public func updateMyLocationData() {
        self.updateLocationData(self.currentLocation)
    }
}

extension MapView:BMKMapViewDelegate {
    public func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        
    }
    public func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        self.regionDidChange.onNext(())
    }
}
