//
//  ShareView.swift
//  ZiWoYou
//
//  Created by 茶古电子商务 on 17/3/21.
//  Copyright © 2017年 Z_JaDe. All rights reserved.
//

import UIKit
import AppInfoData
import Extension
open class ShareView:UIView {
    open static let shared = ShareView()
    private init() {
        super.init(frame: jd.screenBounds)
        self.tapGesture.addTarget(self, action: #selector(whenTouchView))
        
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
    @objc func whenTouchView() {
        self.hide()
    }
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
        shareView.setNeedsLayout()
        shareView.layoutIfNeeded()
        
        shareView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            shareView.alpha = 1
        }
        shareView.updateItemsVerticalLayout(isShow: true)
    }
    func hide() {
        self.updateItemsVerticalLayout(isShow: false)
        UIView.animate(withDuration: 0.5, animations: { 
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
}

extension ShareView {
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let shareArray = self.shareManager?.shareArray else {
            return
        }
        let maxLineCount:Int = shareArray.count + 1
        
        for (offset, _ ) in shareArray.enumerated() {
            let item = getItemView(index: offset)
            item.sizeToFit()
            layoutItemHorizontal(offset: offset, item: item)
            layoutItemVertical(offset: offset, item: item, maxLineCount: maxLineCount)
        }
    }
    func updateItemsVerticalLayout(isShow:Bool) {
        guard let shareArray = self.shareManager?.shareArray else {
            return
        }
        self.isShow = isShow
        let maxLineCount = shareArray.count / maxColumn + 1
        for (offset, _ ) in shareArray.enumerated() {
            let item = getItemView(index: offset)
            let delay:TimeInterval = (offset % maxColumn).toDouble / (maxColumn.toDouble * 2)
            UIView.animate(withDuration: 0.5, delay: delay, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                self.layoutItemVertical(offset: offset, item: item, maxLineCount: maxLineCount)
            }, completion: nil)
        }
    }
    // MARK: - layout item
    func layoutItemHorizontal(offset:Int,item:UIView) {
        let horizontalSpace:CGFloat = self.width / (maxColumn.toCGFloat * 2)
        if offset % maxColumn == 0 {//第一排
            item.centerX = horizontalSpace
        }else {
            let lastView = getItemView(index: offset - 1)
            item.centerX = lastView.centerX + horizontalSpace * 2
        }
    }
    func layoutItemVertical(offset:Int,item:UIView,maxLineCount:Int) {
        let verticalSpace:CGFloat = 10
        if offset / maxColumn == 0 {//第一行
            if self.isShow {
                item.top = self.height - (item.height + verticalSpace) * CGFloat(maxLineCount) + 50
            }else {
                item.top = self.height
            }
        }else {
            let lastLineView = self.getItemView(index: offset - maxColumn)
            item.top = lastLineView.bottom + 10
        }
    }
    // MARK: - 获取item
    func getItemView(index:Int) -> ShareItemView {
        var item:ShareItemView! = self.viewWithTag(index + 10) as? ShareItemView
        if (item == nil) {
            item = ShareItemView()
            item.tag = index + 10
            self.addSubview(item!)
            item.tapGesture.addTarget(self, action: #selector(clickShareItemView(tap:)))
        }
        let shareArray = self.shareManager!.shareArray
        let title = shareArray[index]
        item.label.text = title
        item.imageView.image = UIImage(named: "ShareImage.bundle/\(title)")
        return item
    }
    // MARK: - 点击item
    @objc func clickShareItemView(tap:UITapGestureRecognizer) {
        let index = tap.view!.tag - 10
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
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.sizeToFit()
        label.sizeToFit()
        imageView.origin = CGPoint.zero
        label.centerX = imageView.center.x
        label.top = imageView.bottom + 8
    }
}
