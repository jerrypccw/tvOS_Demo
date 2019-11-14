//
//  UIColor+Extension.swift
//  viu-apple-tv
//
//  Created by Allen on 2018/12/29.
//  Copyright © 2018 Allen. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    
    convenience init(hex: String, alpha: CGFloat = CGFloat(1.0)) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: alpha
        )
    }
    
    /// 系统主色调 FFBF00
    public static let VIU_SYSTEM = UIColor(hex: "FFBF00")
    /// 系统文本默认常规颜色 FFFFFF
    public static let VIU_TEXT_NORMAL = UIColor(hex: "FFFFFF")
    /// 系统文本默认高亮/选中颜色 FFBF00
    public static let VIU_TEXT_SELECTED = UIColor(hex: "FFBF00")
    /// 系统文本默认高亮/选中颜色（黑色） 333333
    public static let VIU_TEXT_SELECTED_BLACK = UIColor(hex: "333333")
    /// 系统UI默认背景颜色 1A1A1A
    public static let VIU_VIEW_BACKGROUND = UIColor(hex: "1A1A1A")
    /// 424242
    public static let VIU_BUTTON_BACKGROUND = UIColor(hex: "424242")
    /// 阴影颜色 000000
    public static let VIU_SHADOW = UIColor(hex: "000000")
    /// 河-卡片-背景色 2F2F2F
    public static let VIU_CELL_BACKGROUND = UIColor(hex: "2F2F2F")
    /// 河-卡片-副标题颜色 999999
    public static let VIU_CELL_TYPE_FONT = UIColor(hex: "999999")
    /// 搜索页-卡片-不合法-正文 和 副标题 666666
    public static let VIU_SEARCH_CELL_WRONGFUL_TITLE = UIColor(hex: "666666")
    /// 搜索页-卡片-不合法-蒙层提示 BBBBBB
    public static let VIU_SEARCH_CELL_WRONGFUL_TEXT = UIColor(hex: "BBBBBB")
    /// 详情页-顶部bannerView底色
    public static let VIU_DETAIL_MOVIE_BANNER_BG = UIColor(hex: "2A2A2A")
    /// 二维码登录页-QRCode获取失败提示字体颜色
    public static let VIU_QRCODE_LOGIN_FAILED_LABEL_TEXT = UIColor(hex: "CCCCCC")
    
    /// 播放器导航栏按钮普通状态
    public static let NAVI_TABBAR_NORMAL = UIColor(hex: "454545")
}
