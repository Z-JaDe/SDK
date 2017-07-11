//
//  ShareView.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 17/3/21.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import Foundation
import UIKit
import JDKit
open class ShareView:UIView {
    open static let shared = ShareView()
    private init() {
        super.init(frame: jd.screenBounds)
        self.rx.whenTouch { (view) in
            view.hide()
        }.addDisposableTo(disposeBag)
        
        self.addSubview(imgView)
        self.layer.addSublayer(self.blackLayer)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var shareManager:ShareManager?
    var isShow:Bool = false
    let maxColumn:Int = 4
    
    lazy var imgView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    lazy var blackLayer:CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        layer.opacity = 0.2
        return layer
    }()
}
extension ShareView {
    static func show(_ closure:(ShareManager)->()) {
        let shareView = self.shared
        shareView.shareManager = ShareManager()
        closure(shareView.shareManager!)
        
        let window = jd.rootWindow
        shareView.frame = window.bounds
        shareView.imgView.frame = shareView.bounds
        shareView.blackLayer.frame = shareView.bounds
        
        let blurredImage = window.toImage().blurImage()
        shareView.imgView.image = blurredImage
        
        
        window.addSubview(shareView)
        shareView.configItems()
        shareView.setNeedsLayout()
        shareView.layoutIfNeeded()
        
        shareView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            shareView.alpha = 1
        }
        shareView.updateItems(isShow: true)
    }
    func hide() {
        self.updateItems(isShow: false)
        UIView.animate(withDuration: 0.5, animations: { 
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
}

extension ShareView {
    func configItems() {
        guard let shareArray = self.shareManager?.shareArray else {
            return
        }
        let maxLineCount = shareArray.count + 1
        let space = self.width / (maxColumn.toCGFloat * 2)
        for (offset, _ ) in shareArray.enumerated() {
            let item = getItemView(index: offset)
            item.snp.remakeConstraints({ (maker) in
                if offset % maxColumn == 0 {//第一排
                    maker.centerX.equalTo(self.snp.left).offset(space)
                }else {
                    let lastView = getItemView(index: offset - 1)
                    maker.centerX.equalTo(lastView).offset(space*2)
                }
                if offset / maxColumn == 0 {//第一行
                    if self.isShow {
                        maker.top.equalTo(self.snp.bottom).offset(-100*maxLineCount - 50)
                    }else {
                        maker.top.equalTo(self.snp.bottom)
                    }
                }else {
                    let lastLineView = self.getItemView(index: offset - maxColumn)
                    maker.topSpace(lastLineView).offset(10)
                }
            })
        }
    }
    func updateItems(isShow:Bool) {
        guard let shareArray = self.shareManager?.shareArray else {
            return
        }
        self.isShow = isShow
        let maxLineCount = shareArray.count / maxColumn + 1
        for (offset, _ ) in shareArray.enumerated() {
            let item = getItemView(index: offset)
            let delay:TimeInterval = (offset % maxColumn).toDouble / (maxColumn.toDouble * 2)
            UIView.spring(duration: 0.5, animations: {
                if offset / self.maxColumn == 0 {
                    item.snp.updateConstraints({ (maker) in
                            if isShow {
                                maker.top.equalTo(self.snp.bottom).offset(-100 * maxLineCount - 50)
                            }else {
                                maker.top.equalTo(self.snp.bottom)
                            }
                    })
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
            }, delay:delay)
        }
    }
    func getItemView(index:Int) -> ShareItemView {
        var item:ShareItemView! = self.viewWithTag(index + 10) as? ShareItemView
        if (item == nil) {
            item = ShareItemView()
            item.tag = index + 10
            self.addSubview(item!)
            
            item.rx.whenTouch({[unowned self] (item) in
                self.clickShareItemView(index: index)
            }).addDisposableTo(item!.disposeBag)
        }
        let shareArray = self.shareManager!.shareArray
        let title = shareArray[index]
        item.label.text = title
        item.imageView.image = UIImage(named: "ShareImage.bundle/\(title)")
        return item
    }
    func clickShareItemView(index:Int) {
        guard let shareArray = self.shareManager?.shareArray else {
            return
        }
        self.shareManager?.share(shareArray[index])
        self.hide()
    }
}
class ShareItemView: UIView {
    lazy var label:UILabel = {
        let label = UILabel(color: Color.white, font: Font.h4)
        return label
    }()
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.left.greaterThanOrEqualToSuperview()
            maker.centerX.top.equalToSuperview()
        }
        label.snp.makeConstraints { (maker) in
            maker.left.greaterThanOrEqualToSuperview()
            maker.centerX.bottom.equalToSuperview()
            maker.topSpace(imageView).offset(8)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
