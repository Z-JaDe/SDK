//
//  BaseMapViewController.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 16/12/6.
//  Copyright © 2016年 Z_JaDe. All rights reserved.
//

import UIKit
import JDKit
import RxSwift

open class BaseMapViewController: BaseViewController {
    open lazy var searchView:UIView = UIView()
    open lazy var searchTextField:SearchTextField = SearchTextField(textFieldType: .lightWhiteSearchBarWithCity)
    /// ZJaDe: 
    open var headerShadowView:UIView = {
        let view = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: jd.screenWidth, height: 106)
        gradientLayer.colors = [Color.darkBlack.cgColor,Color.clear.cgColor]
        gradientLayer.locations = [0,1]
        view.layer.addSublayer(gradientLayer)
        view.frame = CGRect(x: 0, y: 0, width: jd.screenWidth, height: 106)
        return view
    }()
    open lazy var mapVC:BaseMapScrollViewController = BaseMapScrollViewController()
    open var mapView:BMKMapView {
        return self.mapVC.mapView
    }
    open var currentLocation:BMKUserLocation?
    private var needShowMyLocation = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        addChildScrollVC(edgesToFill: true)
        /// ZJaDe: 不要梯度图
       // self.view.addSubview(self.headerShadowView)
        
        self.navBarAlpha = 0.9
        self.navTintColor = Color.black
        self.backButton.addShadowInWhiteView()
        self.configNavBarItem { (navItem) in
            navItem.leftBarButtonItem = self.backButton.barButtonItem()
            navItem.titleView = self.searchView
        }
        configSearchView()
        
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedToRequest()
        mapView.delegate = self
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.delegate = nil
    }
    open override func request(refresh: Bool) {
        BMKLocationManager().location().subscribe(onNext:{[unowned self] (userLocation) in
            self.currentLocation = userLocation
            self.updateData()
            if self.needShowMyLocation {
                self.needShowMyLocation = false
                self.mapVC.showMyLocation()
            }
            self.didUpdateLocation.onNext(userLocation)
        }).addDisposableTo(disposeBag)
    }
    open override func updateData() {
        self.mapView.updateLocationData(self.currentLocation)
    }
    // MARK: - BMKMapViewDelegate
    open var regionDidChange = PublishSubject<Void>()
    open var didUpdateLocation = PublishSubject<BMKUserLocation>()
}
extension BaseMapViewController {
    // MARK: searchView
    open func configSearchView() {
        searchTextField.text = "   目的地、景点、酒店、"
        searchView.addSubview(searchTextField)
        searchView.size = searchTextField.intrinsicContentSize
        searchTextField.edgesToView()
        _ = searchView.rx.whenTouch({ (view) in
            // TODO: 点击搜索框时
        })
        searchTextField.backgroundColor = Color.clear
    }
}
extension BaseMapViewController:AddChildScrollProtocol {
    open func createScrollVC(index: Int) -> BaseMapScrollViewController {
        return self.mapVC
    }
}
extension BaseMapViewController:BMKMapViewDelegate {
    open func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        
    }
    open func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        self.regionDidChange.onNext()
    }
}
