//
//  ViuPlayerTabbarLanguageView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/17.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerTabbarSubtitleView: UIView {
    
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
    
    var model: TabbarSubtitleModel? {
        willSet {
            removeSubtitleButton()
        }
        didSet {
            setupSubtitleButton()
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
        
    }
    
    /// 初始化Xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        backgroundColor = .clear
        
        alpha = 0
    }
    
   func showView() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
            [weak self] in
            self?.alpha = 1
        })
    }
    
    func hiddenView() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
            [weak self] in
            self?.alpha = 0
        })
    }
    
    /// 清除导航栏按钮
    private func removeSubtitleButton() {
        
        if stackView.subviews.isEmpty == true {
            return
        }
        
        for btn in stackView.subviews {
            btn.removeFromSuperview()
        }
        
        stackView.removeFromSuperview()
    }
    
    private func setupSubtitleButton() {
        
        let btns: Array<String> = model?.subtitles ?? []
        
        if btns.count == 1 { return }
        
        addSubview(stackView)
        
        // 记录循环中按钮的上一次宽度
        var record: CGFloat = 0.0
        
        btns.enumerated().forEach { (offset, title) in
            
            let btn = UIButton.init(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.black, for: .normal)
            btn.setTitle(title, for: .focused)
            btn.setTitleColor(.white, for: .focused)
            
            let strWidth: CGFloat = ViuPlayerTabbarConfig.getStringWidth(str: title , strFont: ViuPlayerTabbarConfig.btnFont, h: ViuPlayerTabbarConfig.btnFont)
            
            let btnWidth = strWidth + ViuPlayerTabbarConfig.btnSpacing
            
            let x: CGFloat = CGFloat(offset) * (ViuPlayerTabbarConfig.btnSpacing + btnWidth) + record
            
            record = btnWidth + ViuPlayerTabbarConfig.btnSpacing
            
            let btnBackgroundX = (frame.size.width - x - btnWidth) / 2
            
            stackView.addArrangedSubview(btn)
            
            btn.frame = CGRect.init(x: 0,
                                    y: ViuPlayerTabbarConfig.zero,
                                    width: btnWidth,
                                    height: ViuPlayerTabbarConfig.btnHeight)
            
            stackView.frame = CGRect.init(x: btnBackgroundX,
                                                  y: ViuPlayerTabbarConfig.zero,
                                                  width: x + btnWidth,
                                                  height: frame.size.height)
        }
    }    
}
