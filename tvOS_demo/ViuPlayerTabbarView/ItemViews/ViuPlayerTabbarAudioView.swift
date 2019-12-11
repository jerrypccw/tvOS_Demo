//
//  ViuPlayerTabbarAudioView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/12/10.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerTabbarAudioView: UIView {
    
    var model: TabbarAudioModel? {
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
        backgroundColor = .purple
        alpha = 0
    }
    
    /// 清除导航栏按钮
    private func removeSubtitleButton() {
        
    }
    
    private func setupSubtitleButton() {
               
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
}
