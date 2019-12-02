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
    static let AnimationTime = 0.35
    // 零
    static let zero: CGFloat = 0.0
    // ViuPlayerTabbarView的高度
    static let viewHeight: CGFloat = 420
    // ViuPlayerTabbarView的宽度
    static let windowWidth: CGFloat = UIScreen.main.bounds.width
    // ViuPlayerProgressView的高度
    static let windowHeight: CGFloat = UIScreen.main.bounds.height
    
    // 圆角视图高度
    static let filletHeight: CGFloat = 340
    // 圆角视图间距
    static let filletSpacing: CGFloat = 80
    // 圆角视图宽度
    static var filletWidth: CGFloat {
        return windowWidth - filletSpacing * 2
    }
    // 圆角Y值
    static let filletY: CGFloat = 48
    // 圆角值
    static let filletCornerRadius: CGFloat = 40
    // 圆角视图除简介外的高度
    static let filletOtherHeight: CGFloat = 220
    
    // 按钮之间的间距
    static let btnSpacing: CGFloat = 30
    static let btnHeight: CGFloat = 80
    //    let btnWidth = 200
    static let btnY: CGFloat = 12
    static let btnFont: CGFloat = 36
    static let btnMinWidth: CGFloat = 128
    
    // 线
    static let lineX: CGFloat = 40
    static let lineHeight: CGFloat = 1
    static var lineY: CGFloat {
        return 24 + btnHeight
    }
    static var lineWidth: CGFloat {
        return filletWidth - lineX * 2
    }
    
    static let introductionSpacing: CGFloat = 200
    
    static let introductionHeight: CGFloat = 120
    
    static let subtitleHeight: CGFloat = 60
    
    
    
}

extension ViuPlayerTabbarConfig {
    
    static func getStringWidth(str: String, strFont: CGFloat, h: CGFloat) -> CGFloat {
        return getNormalStringSize(str: str,
                                   font: strFont,
                                   w: CGFloat.greatestFiniteMagnitude,
                                   h: h).width
    }
    
    
    static func getNormalStringSize(str: String? = nil, attriStr: NSMutableAttributedString? = nil, font: CGFloat, w: CGFloat, h: CGFloat) -> CGSize {
        if str != nil {
            let strSize = (str! as NSString).boundingRect(with: CGSize(width: w, height: h),
                                                          options: .usesLineFragmentOrigin,
                                                          attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)],
                                                          context: nil).size
            return strSize
        }
        
        if attriStr != nil {
            let strSize = attriStr!.boundingRect(with: CGSize(width: w, height: h), options: .usesLineFragmentOrigin, context: nil).size
            return strSize
        }
        
        return CGSize.zero
    }
}

extension Int{
    //++前缀:先自增再执行表达示
    static prefix func ++(num:inout Int) -> Int {
        //输入输出参数num
        num += 1
        //返回加1后的数值
        return num
    }
    //后缀++:先执行表达式后再自增
    static postfix func ++(num:inout Int) -> Int {
        //输入输出参数num
        let temp = num
        //num加1
        num += 1
        //返回加1前的数值
        return temp
    }
    //--前缀:先自减再执行表达示
    static prefix func --(num:inout Int) -> Int {
        //输入输出参数num
        num -= 1
        //返回减1后的数值
        return num
    }
    //后缀--:先执行表达式后再自减
    static postfix func --(num:inout Int) -> Int {
        //输入输出参数num
        let temp = num
        //num减1
        num -= 1
        //返回减1前的数值
        return temp
    }
}

func *(l: CGSize,r: CGFloat)-> CGSize {
  return CGSize(width: r*l.width, height: r*l.height)
}

func /( l : CGSize, r: CGSize) -> CGSize {
    return CGSize(width:l.width / r.width,height:     l.height / r.height)
}

func *(l: CGSize,r: CGSize)-> CGSize{
    return CGSize(width: l.width * r.width, height:   l.height * r.height)
}

func -( l : CGSize, r: CGSize) -> CGSize {
    return CGSize(width:l.width - r.width,height: l.height - r.height)
}

func -( l : CGPoint, r: CGPoint) -> CGPoint {
      return  CGPoint(x: l.x - r.x, y: l.y - r.y)
}

extension CGSize {
    var point: CGPoint {
       return CGPoint(x: self.width, y: self.height) }
}

extension CGPoint {
  
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return CGPoint(x: self.x / length(), y: self.y / length())
  }
  
  var angle: CGFloat {
    return atan2(y, x)
  }
}
