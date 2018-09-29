//
//  ComprehensiveView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import FSPagerView

@IBDesignable
class ComprehensiveView: CybexBaseView {
    
    @IBOutlet weak var bannerView: ETOHomeBannerView!
    @IBOutlet weak var announceView: AnnounceView!
    @IBOutlet weak var hotAssetsView: HotAssetsView!
    
    @IBOutlet weak var middleItemsView: ComprehensiveItemsView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topGainersView: UIView!
    
    enum Event:String {
        case ComprehensiveViewDidClicked
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        clearBgColor()
        self.bannerView.view_type = 1
        self.bannerView.pagerView.transformer = FSPagerViewTransformer(type: .linear)
        self.bannerView.pagerView.itemSize = CGSize(width: 334, height: self.bannerView.height)
        self.bannerView.pagerView.interitemSpacing = 10
    }
    
    func setupSubViewEvent() {
     
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ComprehensiveViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}