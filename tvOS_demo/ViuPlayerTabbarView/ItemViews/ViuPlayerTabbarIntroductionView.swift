//
//  ViuPlayerTabbarIntroductionView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/14.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerTabbarIntroductionView: UIView {
    
    lazy var imageView: UIImageView = UIImageView()
    lazy var titleLabel: UILabel = UILabel()
    lazy var descriptionLabel: CustomLabel = CustomLabel()
    lazy var playTimeLabel: UILabel = UILabel()
    
    var model: TabbarIntroductionModel? {
        didSet {
            titleLabel.text = model?.dramaTitle
            descriptionLabel.text = model?.dramaDescription
            playTimeLabel.text = "1小时40分"
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
    
    /// 辅助视图初始化
    private func setupSubviews() {
        
        imageView.image = UIImage.init(imageLiteralResourceName: "tmp")
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 30)
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.numberOfLines = 3
        descriptionLabel.verticalAlignment = .VerticalAlignmentTop
        
        playTimeLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(playTimeLabel)
        addSubview(descriptionLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 30).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        playTimeLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        playTimeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        playTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true
        playTimeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: playTimeLabel.bottomAnchor, constant: 12).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
            
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
