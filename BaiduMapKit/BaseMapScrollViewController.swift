//
//  BaseMapScrollViewController.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/6.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import UIKit
import JDKit
import RxSwift

open class BaseMapScrollViewController: ScrollViewController {
    lazy private(set) var mapView = BMKMapView()
    lazy private(set) var positionIndicator:Button = {
        let button = Button(image: UIImage(named: "ic_map_positionIndicator"))
        self.configPositionIndicator(button)
        return button
    }()
    lazy private(set) var zoomView:MapZoomView = {
        let zoomView = MapZoomView()
        self.configMapZoomView(zoomView)
        return zoomView
    }()
    open override func loadView() {
        self.view = self.mapView
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        configMapView()
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.viewWillAppear()
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.viewWillDisappear()
    }
    
    
    open var whenShowMyLocation = PublishSubject<Void>()
    open func showMyLocation() {
        self.mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading
        self.whenShowMyLocation.onNext()
    }
}
extension BaseMapScrollViewController {
    open func configMapView() {
        self.mapView.showsUserLocation = true
        self.mapView.zoomLevel = 19
    }
    open func configPositionIndicator(_ positionIndicator:Button) {
        positionIndicator.rx.touchUpInside({[unowned self] (button) in
            self.showMyLocation()
        })
    }
    open func configMapZoomView(_ zoomView:MapZoomView) {
        self.mapView.maxZoomLevel = zoomView.maxZoomLevel
        self.mapView.minZoomLevel = zoomView.minZoomLevel
        zoomView.zoomIn.rx.touchUpInside({[unowned self,unowned zoomView] (button) in
            if self.mapView.zoomLevel < zoomView.maxZoomLevel {
                self.mapView.zoomIn()
            }else {
                button.shake()
                zoomView.shake()
                Alert.showPrompt("已经放大到最大级别！")
            }
        })
        zoomView.zoomOut.rx.touchUpInside {[unowned self,unowned zoomView] (button) in
            if self.mapView.zoomLevel > zoomView.minZoomLevel {
                self.mapView.zoomOut()
            }else {
                button.shake()
                zoomView.shake()
                Alert.showPrompt("已经缩小到最小级别！")
            }
        }
    }
}
open class MapZoomView: CustomIBView {
    /// ZJaDe: 放大
    open let zoomIn:Button = {
        let button = Button(image: UIImage(named: "ic_map_加号"), isTemplate: true)
        button.tintColor = Color.gray
        button.addBorderBottom(padding:5)
        return button
    }()
    /// ZJaDe: 缩小
    open let zoomOut:Button = {
        let button = Button(image: UIImage(named: "ic_map_减号"), isTemplate: true)
        button.tintColor = Color.gray
        return button
    }()
    open let minZoomLevel:Float = 3
    open let maxZoomLevel:Float = 21
    
    open override func configInit() {
        super.configInit()
        self.backgroundColor = Color.white.alpha(0.8)
        self.cornerRadius = 5
        self.addShadow()
        self.addSubview(self.zoomIn)
        self.addSubview(self.zoomOut)
        self.zoomIn.snp.makeConstraints { (maker) in
            maker.left.centerX.top.equalToSuperview()
        }
        self.zoomOut.snp.makeConstraints { (maker) in
            maker.left.centerX.bottom.equalToSuperview()
            maker.topSpace(self.zoomIn)
            maker.height.equalTo(self.zoomIn)
        }
    }
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 37.5, height: 88)
    }
}
