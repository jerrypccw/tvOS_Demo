//
//  ViuPlayerTabbarView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/12.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerTabbarView: UIView {
    
    let btnWidth = 200
    
    open var buttonModels : [ViuPlayerTabbarModel]? {
        willSet {
            removeCategoryButton()
        }
        didSet {
            setupCategoryButton()
        }
    }
    
    // 初始化赋值
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    // 初始化
    convenience init() {
        self.init(frame: CGRect.zero)
        self.frame = CGRect.init(x: 0, y: -200, width: windowsWidth, height: 200)
    }
    
    // 初始化Xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    func setupSubviews() {
        backgroundColor = .yellow
        
    }
    
    private func removeCategoryButton() {
        
    }
    
    private func setupCategoryButton() {
        
        for model: ViuPlayerTabbarModel in buttonModels ?? [] {
            print(model.buttonName)
            
            let btn = UIButton.init(type: .custom)
            btn.frame = CGRect.init(x: 0, y: 0, width: btnWidth, height: 120)
            btn.setTitle(model.buttonName, for: .normal)
            btn.backgroundColor = .orange
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 60)
            
        }
    }
    
}
