//
//  ViuPlayerTabbarView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/12.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerTabbarView: UIView {
    
    let viewHeight: Int = 380
    let viewWidth: Int = Int(UIScreen.main.bounds.width)
    
    let filletHeight: Int = 300
    let filletSpacing: Int = 80
    var filletWidth: Int {
        return viewWidth - filletSpacing * 2
    }
    let filletY: Int = 48
    let filletCornerRadius: CGFloat = 40
    let filletOtherHeight: CGFloat = 220
    
    let btnSpacing = 60
    let btnHeight = 88
    let btnWidth = 200
    let btnY = 12
    let btnFont: CGFloat = 36.0
    
    let lineX = 40
    let lineHeight = 1
    var lineY: Int {
        return 24 + btnHeight
    }
    var lineWidth: Int {
        return filletWidth - lineX * 2
    }
    
    // 设置圆角并承载布局视图的view
    private lazy var btnFilletView = UIView()
    
    // 设置button居中布局视图
    private lazy var btnBackgroundView = UIView()
    
    // tabbarModel 数组
    open var buttonModels : [ViuPlayerTabbarModel]? {
        willSet {
            removeCategoryButton()
        }
        didSet {
            setupCategoryButton()
        }
    }
    
    /// 初始化赋值
    /// - Parameter frame: 坐标
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    // 初始化
    convenience init() {
        self.init(frame: CGRect.zero)
        self.frame = CGRect.init(x: 0, y: -viewHeight, width: viewWidth, height: viewHeight)
    }
    
    // 初始化Xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    // 辅助视图初始化
    private func setupSubviews() {
        
        backgroundColor = .clear
        btnBackgroundView.backgroundColor = .clear
        
        addSubview(btnFilletView)
        
        btnFilletView.frame = CGRect.init(x: filletSpacing, y: filletY, width: filletWidth, height: filletHeight)
        btnFilletView.layer.masksToBounds = true
        btnFilletView.layer.cornerRadius = filletCornerRadius
        
        let visualEffectView = setupVisualEffectView()
        btnFilletView.addSubview(visualEffectView)
        
        let lineView = UIView()
        lineView.backgroundColor = .black
        lineView.frame = CGRect.init(x: lineX, y: lineY, width: lineWidth, height: lineHeight)
        btnFilletView.addSubview(lineView)
    }
        
    /// 清除导航栏按钮
    private func removeCategoryButton() {
        
        if btnBackgroundView.subviews.isEmpty == true {
            return
        }
        
        for btn in btnBackgroundView.subviews {
            btn.removeFromSuperview()
        }
        
        btnBackgroundView.removeFromSuperview()
    }
        
    /// 设置导航栏按钮
    private func setupCategoryButton() {
        
        btnFilletView.addSubview(btnBackgroundView)
        
        // 计算按钮的坐标设置
        buttonModels?.enumerated().forEach({ (offset, model) in
            
            let btn = UIButton.init(type: .custom)
            btn.setTitle(model.buttonName, for: .normal)
            btn.setTitle(model.buttonName, for: .focused)
            btn.setTitleColor(.lightGray, for: .normal)
            btn.setTitleColor(.black, for: .focused)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: btnFont)
            btn.tag = 100 + offset
            
            // 设置 masksToBounds 属性会触发离屏渲染，设置的阴影会失效
//            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = CGFloat(btnHeight / 2)
            
            btn.layer.shadowColor = UIColor.black.cgColor
            btn.layer.shadowOffset = CGSize.init(width: 5, height: 30)
            btn.layer.shadowOpacity = 0.5
            btn.layer.shadowRadius = 30.0
            
            let x = offset * (btnSpacing + btnWidth)
            
            var btnBackgroundX = 0
            if offset == 0 {
                btnBackgroundX = (filletWidth - btnWidth) / 2
            } else {
                btnBackgroundX = (filletWidth - x - btnWidth) / 2
            }
            
            btnBackgroundView.addSubview(btn)
            
            btn.frame = CGRect.init(x: x, y: btnY, width: btnWidth, height: btnHeight)
            btnBackgroundView.frame = CGRect.init(x: btnBackgroundX, y: 0, width: x + btnWidth, height: viewHeight)
        })
    }
    
    /// 添加毛玻璃效果
    private func setupVisualEffectView() -> UIVisualEffectView {
        /// 创建一个模糊效果
        let blurEffect = UIBlurEffect(style: .regular)
        /// 创建一个承载模糊效果的视图
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: 0, y: 0, width:filletWidth, height:filletHeight)
        return blurView
    }
    
    
    /// 更新焦点的回调方法
    /// - Parameters:
    ///   - context:focus 上下文
    ///   - coordinator: 焦点更新期间与焦点相关的动画的协调器
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        guard let button = context.nextFocusedView else {
            return
        }
        
        switch button.tag {
        case 100:
            print(button.tag)
            
            animateFilletHeightAction(h: CGFloat(filletHeight))
            break
        case 101:
            print(button.tag)
            
            animateFilletHeightAction(h: filletOtherHeight)
            break
        case 102:
            print(button.tag)
            
            break
        case 103:
            print(button.tag)
            
            break
        default:
            break
        }
    }
    
    func showTabbarView() {
        
        animateTabbarAction(y: 0.0)
    }
    
    func hiddenTabbarView() {
        
        animateTabbarAction(y: CGFloat(-viewHeight))
    }
    
    func animateTabbarAction(y: CGFloat) {
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            var frame = strongSelf.frame
            frame.origin.y = y
            strongSelf.frame = frame
        })
    }
    
    func animateFilletHeightAction(h: CGFloat) {
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            var frame = strongSelf.btnFilletView.frame
            frame.size.height = h
            strongSelf.btnFilletView.frame = frame
        })
    }
}
