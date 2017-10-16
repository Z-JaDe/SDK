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
import Extension
import AppInfoData
import Alert
public class MapView: BMKMapView,InitMethodProtocol {
    public var didUpdateLocation = PublishSubject<BMKUserLocation>()
    public var currentLocation:BMKUserLocation? {
        didSet {
            if let currentLocation = self.currentLocation {
                self.didUpdateLocation.onNext(currentLocation)
            }
        }
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configInit()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configInit() {
        self.showsUserLocation = true
        self.zoomLevel = 19
        self.mapType = BMKMapTypeStandard
    }
    
    // MARK: -
    public var regionDidChange = PublishSubject<Void>()

    public func configMapViewWhenAppear() {
        self.delegate = self
        self.viewWillAppear()
    }
    public func configMapViewWhenDisAppear() {
        self.delegate = nil
        self.viewWillDisappear()
    }
    
    public func showMyLocation() {
        self.userTrackingMode = BMKUserTrackingModeFollowWithHeading
    }
    public func updateMyLocationData() {
        self.updateLocationData(self.currentLocation)
    }
    // MARK: - poi
    lazy var poiSearcher:BMKPoiSearch = BMKPoiSearch()
    lazy var poiSearcherOption:BMKCitySearchOption = BMKCitySearchOption()
    var hud:HUD?
    public lazy var poiSearchSubject:PublishSubject<[BMKPoiInfo]> = PublishSubject()
    // MARK: -
    public func setRegion(with coordinate:CLLocationCoordinate2D) {
        self.setRegion(BMKCoordinateRegionMake(coordinate, BMKCoordinateSpanMake(0.001625, 0.004705)), animated: true)
    }
}

extension MapView:BMKMapViewDelegate {
    public func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        
    }
    public func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        self.regionDidChange.onNext(())
    }
}
extension MapView:BMKPoiSearchDelegate {
    public func poiSearch(_ city:String,_ searchText:String) {
        self.poiSearcherOption.city = city
        self.poiSearcherOption.keyword = searchText
        self.poiSearcher.delegate = self
        let flag = self.poiSearcher.poiSearch(inCity: self.poiSearcherOption)
        let prompt:String = "周边检索发送\(flag ? "成功" : "失败")"
        HUD.showPrompt(prompt)
        logDebug(prompt)
        if flag {
            hud = HUD.showMessage("检索中")
        }
    }
    public func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
        hud?.hide()
        guard errorCode == BMK_SEARCH_NO_ERROR else {
            return
        }
        switch errorCode {
        case BMK_SEARCH_NO_ERROR:
            self.poiSearchSubject.onNext(poiResult.poiInfoList as! [BMKPoiInfo])
        case BMK_SEARCH_AMBIGUOUS_KEYWORD:
            //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
            // result.citycancel;
            HUD.showError("起始点有歧义")
        default:
            HUD.showError("抱歉，未找到结果")
        }
    }
}
