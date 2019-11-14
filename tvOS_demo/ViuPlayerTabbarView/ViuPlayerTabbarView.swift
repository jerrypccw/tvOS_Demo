//
//  ViuPlayerTabbarView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/12.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerTabbarView: UIView {
    
    /// 焦点View
    var focusView: UIView?
    
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
    
    /// 初始化
    convenience init() {
        self.init(frame: CGRect.zero)
        self.frame = CGRect.init(x: ViuPlayerTabbarConfig.zero,
                                 y: -ViuPlayerTabbarConfig.viewHeight,
                                 width: ViuPlayerTabbarConfig.viewWidth,
                                 height: ViuPlayerTabbarConfig.viewHeight)
    }
    
    /// 初始化Xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    /// 辅助视图初始化
    private func setupSubviews() {
        
        backgroundColor = .clear
        btnBackgroundView.backgroundColor = .clear
        
        btnFilletView.frame = CGRect.init(x: ViuPlayerTabbarConfig.filletSpacing,
                                          y: ViuPlayerTabbarConfig.filletY,
                                          width: ViuPlayerTabbarConfig.filletWidth,
                                          height: ViuPlayerTabbarConfig.filletHeight)
        btnFilletView.layer.masksToBounds = true
        btnFilletView.layer.cornerRadius = ViuPlayerTabbarConfig.filletCornerRadius
        addSubview(btnFilletView)
        
        let visualEffectView = setupVisualEffectView()
        btnFilletView.addSubview(visualEffectView)
        
        let lineView = UIView()
        lineView.backgroundColor = .black
        lineView.frame = CGRect.init(x: ViuPlayerTabbarConfig.lineX,
                                     y: ViuPlayerTabbarConfig.lineY,
                                     width: ViuPlayerTabbarConfig.lineWidth,
                                     height: ViuPlayerTabbarConfig.lineHeight)
        
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
        
        let btnBackgroundImage = UIImage.init(imageLiteralResourceName: "navi_btn_background")
        
        // 计算按钮的坐标设置
        buttonModels?.enumerated().forEach({ (offset, model) in
            
            let btn = setupButton(name: model.buttonName, backgroundImage: btnBackgroundImage)
            btn.tag = 100 + offset
            
            let strWidth: CGFloat = getStringWidth(str: btn.currentTitle ?? "",
                                                   strFont: ViuPlayerTabbarConfig.btnFont,
                                                   h: ViuPlayerTabbarConfig.btnFont)
            let tmpWidth = strWidth + ViuPlayerTabbarConfig.btnSpacing
            
            var btnWidth = ViuPlayerTabbarConfig.zero
            if tmpWidth < ViuPlayerTabbarConfig.btnBackWidth {
                btnWidth = ViuPlayerTabbarConfig.btnBackWidth
            } else {
                btnWidth = tmpWidth
            }
            
            let x: CGFloat = CGFloat(offset) * (ViuPlayerTabbarConfig.btnSpacing + btnWidth)
            
            var btnBackgroundX: CGFloat = ViuPlayerTabbarConfig.zero
            if offset == Int(ViuPlayerTabbarConfig.zero){
                btnBackgroundX = (ViuPlayerTabbarConfig.filletWidth - btnWidth) / 2
            } else {
                btnBackgroundX = (ViuPlayerTabbarConfig.filletWidth - x - btnWidth) / 2
            }
            
            
            
            btnBackgroundView.addSubview(btn)
            
            btn.frame = CGRect.init(x: x,
                                    y: ViuPlayerTabbarConfig.btnY,
                                    width: btnWidth,
                                    height: ViuPlayerTabbarConfig.btnHeight)
            
            btnBackgroundView.frame = CGRect.init(x: btnBackgroundX,
                                                  y: ViuPlayerTabbarConfig.zero,
                                                  width: x + btnWidth,
                                                  height: ViuPlayerTabbarConfig.lineY)
        })
    }
    
    
    /// 自定义button
    /// - Parameters:
    ///   - name: 标题
    ///   - backgroundImage: 背景图片
    private func setupButton(name: String, backgroundImage: UIImage) -> UIButton {
        
        let btn = UIButton.init(type: .custom)
        btn.setTitle(name, for: .normal)
        btn.setTitle(name, for: .focused)
        btn.setTitleColor(UIColor.NAVI_TABBAR_NORMAL, for: .normal)
        btn.setTitleColor(.black, for: .focused)
        btn.setBackgroundImage(backgroundImage, for: .focused)
        btn.titleLabel?.lineBreakMode = .byTruncatingTail
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: ViuPlayerTabbarConfig.btnFont)
        
        // 设置 masksToBounds 及 clipsToBounds 属性为true会触发离屏渲染，设置的阴影会失效
        // btn.layer.masksToBounds = true
        // btn.clipsToBounds = true
        btn.layer.cornerRadius = CGFloat(ViuPlayerTabbarConfig.btnHeight / 2)
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize.init(width: 5, height: 30)
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 30.0
        
        return btn
    }
    
    /// 添加毛玻璃效果
    private func setupVisualEffectView() -> UIVisualEffectView {
        /// 创建一个模糊效果
        let blurEffect = UIBlurEffect(style: .regular)
        /// 创建一个承载模糊效果的视图
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: ViuPlayerTabbarConfig.zero,
                                y: ViuPlayerTabbarConfig.zero,
                                width: ViuPlayerTabbarConfig.filletWidth,
                                height: ViuPlayerTabbarConfig.filletHeight)
        return blurView
    }
    
    
    /// 动画效果
    /// - Parameter y: 设置视图的Y值
    private func animateTabbarAction(y: CGFloat) {
        
        UIView.animate(withDuration: ViuPlayerTabbarConfig.AnimationTime, animations: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            var frame = strongSelf.frame
            frame.origin.y = y
            strongSelf.frame = frame
            
        }) { [weak self] (completion) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.updateFocusView(focusView: strongSelf.btnBackgroundView.subviews.first)
        }
    }
    
    /// 动画效果
    /// - Parameter height: 设置视图的height值
    private func animateFilletHeightAction(height: CGFloat) {
        
        UIView.animate(withDuration: ViuPlayerTabbarConfig.AnimationTime, animations: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            var frame = strongSelf.btnFilletView.frame
            frame.size.height = height
            strongSelf.btnFilletView.frame = frame
        })
    }
    
    public func getStringWidth(str: String, strFont: CGFloat, h: CGFloat) -> CGFloat {
        return getNormalStringSize(str: str, font: strFont, w: CGFloat.greatestFiniteMagnitude, h: h).width
    }
    
    private func getNormalStringSize(str: String? = nil, attriStr: NSMutableAttributedString? = nil, font: CGFloat, w: CGFloat, h: CGFloat) -> CGSize {
        if str != nil {
            let strSize = (str! as NSString).boundingRect(with: CGSize(width: w, height: h), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)], context: nil).size
            return strSize
        }
        
        if attriStr != nil {
            let strSize = attriStr!.boundingRect(with: CGSize(width: w, height: h), options: .usesLineFragmentOrigin, context: nil).size
            return strSize
        }
        
        return CGSize.zero
    }
}

// MARK: public func
extension ViuPlayerTabbarView {
    
    public func showTabbarView() {
        
        animateTabbarAction(y: ViuPlayerTabbarConfig.zero)
    }
    
    public func hiddenTabbarView() {
        
        animateTabbarAction(y: CGFloat(-ViuPlayerTabbarConfig.viewHeight))
    }
}

// MARK: override func
extension ViuPlayerTabbarView {
    
    /// 重新定义focus view
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        var environments = [UIFocusEnvironment]()
        
        if focusView != nil {
            environments.append(focusView!)
        } else {
            environments = super.preferredFocusEnvironments
        }
        
        return environments
    }
    
    /// 更新focus view
    ///
    /// - Parameter focusView: focus view
    func updateFocusView(focusView: UIView?) {
        self.focusView = focusView
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
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
            
            animateFilletHeightAction(height: CGFloat(ViuPlayerTabbarConfig.filletHeight))
            break
        case 101:
            print(button.tag)
            
            animateFilletHeightAction(height: ViuPlayerTabbarConfig.filletOtherHeight)
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
}
