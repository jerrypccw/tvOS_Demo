//
//  ViuPlayerTabbarConfiguration.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/14.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit
import Foundation

class ViuPlayerTabbarConfig {
    
    // 动画时间
    static let AnimationTime = 0.25
    // 零
    static let zero: CGFloat = 0.0
    // ViuPlayerTabbarView的高度
    static let viewHeight: CGFloat = 380
    // ViuPlayerTabbarView的宽度
    static let viewWidth: CGFloat = UIScreen.main.bounds.width
    
    // 圆角视图高度
    static let filletHeight: CGFloat = 300
    // 圆角视图间距
    static let filletSpacing: CGFloat = 80
    // 圆角视图宽度
    static var filletWidth: CGFloat {
        return viewWidth - filletSpacing * 2
    }
    // 圆角Y值
    static let filletY: CGFloat = 48
    // 圆角值
    static let filletCornerRadius: CGFloat = 40
    // 圆角视图除简介外的高度
    static let filletOtherHeight: CGFloat = 220
    
    // 按钮之间的间距
    static let btnSpacing: CGFloat = 60
    static let btnHeight: CGFloat = 80
    //    let btnWidth = 200
    static let btnY: CGFloat = 12
    static let btnFont: CGFloat = 36
    static let btnBackWidth: CGFloat = 144
    
    // 线
    static let lineX: CGFloat = 40
    static let lineHeight: CGFloat = 1
    static var lineY: CGFloat {
        return 24 + btnHeight
    }
    static var lineWidth: CGFloat {
        return filletWidth - lineX * 2
    }
    
}
