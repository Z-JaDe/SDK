 //
//  BMKLocationManager.swift
//  PaiBaoTang
//
//  Created by 茶古电子商务 on 2017/10/11.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation

import PermissionScope
import RxSwift
import ThirdSDK
import Alert
import AppInfoData

public class BMKLocationManager:NSObject {
    public let shared:BMKLocationManager = BMKLocationManager()
    private override init() {
        super.init()
    }
    fileprivate var observeObjectCount:Int = 0
    // MARK: 反编码 坐标转地址
    public lazy var geoCodeSearch = BMKGeoCodeSearch()
    fileprivate lazy var reverseGeoCodeSubject = ReplaySubject<AddressComponentModel>.create(bufferSize: 1)
    // MARK: 定位
    public lazy var locationService = BMKLocationService()
    fileprivate lazy var locationSubject = ReplaySubject<BMKUserLocation>.create(bufferSize: 1)
    
}
// MARK: - 反编码 坐标转地址
public extension BMKLocationManager {
    public func locationAndReverseGeoCode() -> Observable<AddressComponentModel> {
        return self.getLocation().flatMap {[unowned self] (userLocation) -> Observable<AddressComponentModel> in
            let coordinate = userLocation.location.coordinate
            
            return self.reverseGeoCode(coordinate).filter({ (model) -> Bool in
                guard let modelCoordinate = model.coordinate else {
                    return false
                }
                return modelCoordinate.latitude == coordinate.latitude && modelCoordinate.longitude == coordinate.longitude
            })
        }
    }
    public func reverseGeoCode(_ coordinate:CLLocationCoordinate2D) -> Observable<AddressComponentModel> {
        self.beginSearch(coordinate)
        return self.reverseGeoCodeSubject.retry(3).take(1).do( onDispose: {
            self.endSearch()
        })
    }
    fileprivate func beginSearch(_ coordinate:CLLocationCoordinate2D) {
        self.geoCodeSearch.delegate = self
        let result = BMKReverseGeoCodeOption()
        result.reverseGeoPoint = coordinate
        if self.geoCodeSearch.reverseGeoCode(result) == false {
            self.reverseGeoCodeSubject.onError(NSError(domain: "反geo检索失败", code: -1, userInfo: nil))
            logDebug("反geo检索发送失败")
        }
    }
    public func endSearch() {
//        geoCodeSearch.delegate = nil
    }
}
// MARK: - 反编码 坐标转地址 BMKGeoCodeSearchDelegate
extension BMKLocationManager:BMKGeoCodeSearchDelegate {
    /// ZJaDe: 地址信息搜索结果
    public func onGetGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        
    }
    /// ZJaDe: 返回反地理编码搜索结果
    public func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        guard let result = result else {
            return
        }
        if result.address != nil, result.address.count > 0 {
            var addressModel = AddressComponentModel()
            addressModel.province = result.addressDetail.province
            addressModel.city = result.addressDetail.city
            addressModel.area = result.addressDetail.district
            addressModel.address = result.addressDetail.streetName + result.addressDetail.streetNumber
            addressModel.coordinate = result.location
            self.reverseGeoCodeSubject.onNext(addressModel)
        }else if (error != BMK_SEARCH_NO_ERROR) {
            HUD.showError("反编码错误->\(error)")
        }
    }
}
// MARK: - 定位
extension BMKLocationManager {
    public func getLocation() -> Observable<BMKUserLocation> {
        return self.beginLocation().take(1)
    }
    // MARK: 开启定位同时验证
    public func beginLocation() -> Observable<BMKUserLocation> {
        self.checkCanLocation {
            self.startUserLocationService()
        }
        return self.locationSubject.retry(3).do(onDispose: {
            self.endLocation()
        })
    }
    // MARK: 只请求定位，不提示错误
    public func getLocationIfCan() -> Observable<BMKUserLocation> {
        return self.onlyLocation().take(1)
    }
    public func onlyLocation() -> Observable<BMKUserLocation> {
        self.startUserLocationService()
        return self.locationSubject.retry(3).do(onDispose: {
            self.endLocation()
        })
    }
    // MARK: 停止定位
    public func endLocation() {
        if self.observeObjectCount > 1 {
            self.observeObjectCount -= 1
        }else {
            self.observeObjectCount = 0
            self.stopUserLocationService()
        }
    }
    // MARK: -
    fileprivate func startUserLocationService() {
        self.observeObjectCount += 1
        if self.locationService.delegate == nil {
            self.locationService.delegate = self
            self.locationService.startUserLocationService()
        }
    }
    fileprivate func stopUserLocationService() {
        self.locationService.stopUserLocationService()
        self.locationService.delegate = nil
        
    }
    fileprivate func checkCanLocation(_ closure:@escaping ()->()) {
        let pscope = PermissionScope()
        pscope.addPermission(LocationWhileInUsePermission(), message: "如果拒绝将无法使用定位功能")
        pscope.bodyLabel.text = "在您定位之前，app需要获取\r\niPhone的定位权限"
        pscope.show({ (finished, results) in
            closure()
        }, cancelled: {(results) in
        })
    }
    // MARK: 更新定位
    fileprivate func updateLocation(_ userLocation:BMKUserLocation) {
        if userLocation.location != nil {
            self.locationSubject.onNext(userLocation)
        }
    }
}
// MARK: - 定位 BMKLocationServiceDelegate
extension BMKLocationManager:BMKLocationServiceDelegate {
    public func willStartLocatingUser() {
        logInfo("开始定位")
    }
    public func didStopLocatingUser() {
        logInfo("停止定位")
    }
    
    public func didUpdate(_ userLocation: BMKUserLocation!) {
        updateLocation(userLocation)
    }
    public func didUpdateUserHeading(_ userLocation: BMKUserLocation!) {
        updateLocation(userLocation)
    }
    public func didFailToLocateUserWithError(_ error: Error!) {
        HUD.showError("定位出现位置错误")
        self.locationSubject.onError(error)
    }
}
