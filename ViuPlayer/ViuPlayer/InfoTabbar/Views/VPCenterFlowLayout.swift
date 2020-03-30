//
//  PVCenterFlowLayout.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/13.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

class VPCenterFlowLayout: UICollectionViewFlowLayout {
    
    /// 是否垂直滚动（默认为false）
    var isVerticalStyle = false
    var itemWidth:CGFloat = 100
    var itemHeight:CGFloat = 60
    
    /// 中间点
    private var midXOrY:CGFloat?
    
    //MARK: 重写方法
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
        if self.isVerticalStyle == false {
            self.scrollDirection = UICollectionView.ScrollDirection.horizontal
            //水平的情况下中间点为宽度的一半
            self.midXOrY = (self.collectionView?.frame.size.width)! / 2.0
            self.itemSize = CGSize.init(width: self.itemWidth, height:self.itemHeight)
            self.sectionInset = UIEdgeInsets.init(top: 0, left: ((self.collectionView?.frame.size.width)!-self.itemWidth) / 2, bottom: 0, right: ((self.collectionView?.frame.size.width)!-self.itemWidth) / 2)
        } else {
            self.scrollDirection = UICollectionView.ScrollDirection.vertical
            //垂直的情况下中间点为高度度的一半
            self.midXOrY = (self.collectionView?.frame.size.height)! / 2.0
            self.itemSize = CGSize.init(width: self.itemWidth, height: self.itemHeight)
            self.sectionInset = UIEdgeInsets.init(top: ((self.collectionView?.frame.size.height)!-self.itemHeight) / 2, left: 0, bottom: ((self.collectionView?.frame.size.height)!-self.itemHeight) / 2, right: 0)
        }
    }
}

