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
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .clear
        view.axis = .horizontal;
        view.distribution = .fillEqually;
        view.spacing = ViuPlayerTabbarConfig.btnSpacing;
        view.alignment = .center;
        return view
    }()
    
    var timer: Timer = {
        let time = Timer()
        return time
    }()
    
    let controlViewDuration: TimeInterval = 0.35
    
    // 简介
    private lazy var introductionView = ViuPlayerTabbarIntroductionView()
    
    // 字幕语言
    private lazy var subtitleView = ViuPlayerTabbarSubtitleView()
    
    // 双字幕
    private lazy var customView = ViuPlayerTabbarCustomView()
    
    // 音频
    private lazy var audioView = ViuPlayerTabbarAudioView()
    
    // tabbarModel 数组
    open var buttonModels : [ViuPlayerTabbarModel]? {
        willSet {
            removeCategoryButton()
        }
        didSet {
            setupCategoryButton()
        }
    }
    
    
    /// 只读属性，是否显示
    private(set) var isTabbarShow: Bool = false
    
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
                                 width: ViuPlayerTabbarConfig.windowWidth,
                                 height: ViuPlayerTabbarConfig.viewHeight)
    }
    
    /// 初始化Xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    deinit {
        timer.invalidate()
        print("ViuPlayerTabbarView deinit")
    }
    
    /// 辅助视图初始化
    private func setupSubviews() {
        
        backgroundColor = .clear
        
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
        
        
        let introductionViewWidth = btnFilletView.frame.width -
            ViuPlayerTabbarConfig.introductionSpacing * 2
        let lineViewBottom = lineView.frame.maxY + 20
        
        // introductionView
        introductionView.frame = CGRect.init(x: ViuPlayerTabbarConfig.introductionSpacing,
                                             y:lineViewBottom,
                                             width: introductionViewWidth,
                                             height: ViuPlayerTabbarConfig.introductionHeight)
        
        // subtitleView
        subtitleView.frame = CGRect.init(x: ViuPlayerTabbarConfig.introductionSpacing,
                                         y: lineViewBottom,
                                         width: introductionViewWidth,
                                         height: ViuPlayerTabbarConfig.subtitleHeight)
        
        // customView
        customView.frame = CGRect.init(x: ViuPlayerTabbarConfig.introductionSpacing,
                                       y: lineViewBottom,
                                       width: introductionViewWidth,
                                       height: ViuPlayerTabbarConfig.subtitleHeight)
        
        // audioView
        audioView.frame = CGRect.init(x: ViuPlayerTabbarConfig.introductionSpacing,
                                      y: lineViewBottom,
                                      width: introductionViewWidth,
                                      height: ViuPlayerTabbarConfig.subtitleHeight)
    
    }

    
    /// 清除导航栏按钮
    private func removeCategoryButton() {
        
        if stackView.subviews.isEmpty == true {
            return
        }
        
        for btn in stackView.subviews {
            btn.removeFromSuperview()
        }
        
        stackView.removeFromSuperview()
    }
    
    /// 设置导航栏按钮
    private func setupCategoryButton() {
        
        btnFilletView.addSubview(stackView)
        
        let btnBackgroundImage = UIImage.init(imageLiteralResourceName: "navi_btn_background")
        
        // 记录循环中按钮的上一次宽度
        var record: CGFloat = 0.0
        
        // 计算按钮的坐标设置
        buttonModels?.enumerated().forEach({ (offset, model) in
            
            if model.buttonName.isEmpty == true {
                return
            }
            
            let btn = setupButton(name: model.buttonName, backgroundImage: btnBackgroundImage)
            
            let strWidth: CGFloat = ViuPlayerTabbarConfig.getStringWidth(str: btn.currentTitle ?? "", strFont: ViuPlayerTabbarConfig.btnFont, h: ViuPlayerTabbarConfig.btnFont)
            
            let tmpWidth = ViuPlayerTabbarConfig.btnSpacing + strWidth
            
            var btnWidth = ViuPlayerTabbarConfig.zero
            if tmpWidth < ViuPlayerTabbarConfig.btnMinWidth {
                btnWidth = ViuPlayerTabbarConfig.btnMinWidth
            } else {
                btnWidth = tmpWidth
            }
            
            let x: CGFloat = CGFloat(offset) * (ViuPlayerTabbarConfig.btnSpacing + btnWidth) + record
            record = ViuPlayerTabbarConfig.btnSpacing + btnWidth
            
            let btnBackgroundX: CGFloat = (ViuPlayerTabbarConfig.filletWidth - btnWidth - x) / 2
            
            if model .isKind(of: TabbarIntroductionModel.self) {
                introductionView.model = model as? TabbarIntroductionModel
                btnFilletView.addSubview(introductionView)
                stackView.addArrangedSubview(btn)
                btn.tag = 100
                
            } else if model .isKind(of: TabbarSubtitleModel.self) {
                subtitleView.model = model as? TabbarSubtitleModel
                btnFilletView.addSubview(subtitleView)
                stackView.addArrangedSubview(btn)
                btn.tag = 102

            } else if model .isKind(of: TabbarCustomModel.self) {
                customView.model = model as? TabbarCustomModel
                btnFilletView.addSubview(customView)
                stackView.addArrangedSubview(btn)
                btn.tag = 101

            } else if model .isKind(of: TabbarAudioModel.self) {
                audioView.model = model as? TabbarAudioModel
                btnFilletView.addSubview(audioView)
                stackView.addArrangedSubview(btn)
                btn.tag = 103
            }
            
            btn.frame = CGRect.init(x: 0,
                                    y: ViuPlayerTabbarConfig.btnY,
                                    width: btnWidth,
                                    height: ViuPlayerTabbarConfig.btnHeight)
            
            stackView.frame = CGRect.init(x: btnBackgroundX,
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
        let blurEffect = UIBlurEffect(style: .light)
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
        
        UIView.animate(withDuration: ViuPlayerTabbarConfig.AnimationTime, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
             
            guard let strongSelf = self else {
                return
            }
            
            var frame = strongSelf.frame
            frame.origin.y = y
            strongSelf.frame = frame
            
        })
//        { [weak self] (completion) in
//            guard let strongSelf = self else {
//                return
//            }
//
//            strongSelf.updateFocusView(focusView: strongSelf.stackView.subviews.first)
//        }
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
    
    private func setupTimer(btn: UIButton) {
        timer.invalidate()
        timer = Timer.viuPlayer_scheduledTimerWithTimeInterval(controlViewDuration, block: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.didUpdateFocusTabbarButton(button: btn)
            }, repeats: false)
    }
}

// MARK: public func
extension ViuPlayerTabbarView {
    
    public func showTabbarView() {
        animateTabbarAction(y: ViuPlayerTabbarConfig.zero)
        isTabbarShow = true
        updateFocusView(focusView: stackView.subviews.first)
    }
    
    public func hiddenTabbarView() {
        animateTabbarAction(y: CGFloat(-ViuPlayerTabbarConfig.viewHeight))
        isTabbarShow = false
        updateFocusView(focusView: nil)
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
        
        setupTimer(btn: button as! UIButton)
    }
    
    func didUpdateFocusTabbarButton(button: UIButton) {
        
        switch button.tag {
        case 100:
            print(button.tag)
            
            animateFilletHeightAction(height: CGFloat(ViuPlayerTabbarConfig.filletHeight))
            
            introductionView.showView()
            subtitleView.hiddenView()
            customView.hiddenView()
            audioView.hiddenView()
            
            break
        case 101:
            print(button.tag)
            
            animateFilletHeightAction(height: ViuPlayerTabbarConfig.filletOtherHeight)
            
            introductionView.hiddenView()
            subtitleView.hiddenView()
            customView.showView()
            audioView.hiddenView()
            break
        case 102:
            print(button.tag)
            
            animateFilletHeightAction(height: ViuPlayerTabbarConfig.filletOtherHeight)
            
            subtitleView.showView()
            customView.hiddenView()
            introductionView.hiddenView()
            audioView.hiddenView()
            break
        case 103:
            print(button.tag)
            
            animateFilletHeightAction(height: CGFloat(ViuPlayerTabbarConfig.filletHeight))
            
            subtitleView.hiddenView()
            customView.hiddenView()
            introductionView.hiddenView()
            audioView.showView()
            break
        default:
            break
        }
    }
}
