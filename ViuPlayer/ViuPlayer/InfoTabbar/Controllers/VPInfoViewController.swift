//
//  PVInfoViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/12.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

class VPInfoViewController: UIViewController {
    
    let mainView = UIView()
    
    lazy var imageView: UIImageView = UIImageView()
    lazy var titleLabel: UILabel = UILabel()
    lazy var descriptionLabel: VPCustomLabel = VPCustomLabel()
    lazy var playTimeLabel: UILabel = UILabel()
    
    var model: VPIntroductionModel? {
        didSet {
            guard let m = model else {
                return
            }
            titleLabel.text = m.dramaTitle
            descriptionLabel.text = m.dramaDescription
            playTimeLabel.text = "1小时40分"
            title = "简介"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 1720, height: 360)        
        setupSubviews()        
    }
    
    /// 辅助视图初始化
    private func setupSubviews() {
        
        view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 280).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        mainView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
        
        mainView.addSubview(imageView)
        mainView.addSubview(titleLabel)
        mainView.addSubview(descriptionLabel)
        mainView.addSubview(playTimeLabel)
        
        imageView.image = UIImage.init(imageLiteralResourceName: "tmp")
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 30)
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.numberOfLines = 3
        descriptionLabel.verticalAlignment = .top
        
        playTimeLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 30).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        playTimeLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        playTimeLabel.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        playTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true
        playTimeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: playTimeLabel.bottomAnchor, constant: 12).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true        
    }
}
