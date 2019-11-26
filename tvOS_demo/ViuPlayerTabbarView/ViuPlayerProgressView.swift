//
//  ViuPlayerProgressView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/22.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerProgressView: UIView {
    
    lazy var progressBar = UIProgressView()
    lazy var startTime = UILabel()
    lazy var endTime = UILabel()
    
    var startTimeString: String? {
        didSet {
            startTime.text = startTimeString
        }
    }
    
    var endTimeString: String? {
        didSet {
            endTime.text = "-" + (endTimeString ?? "00:00")
        }
    }
    
    var second = 5.0
    
    /// 初始化赋值
    /// - Parameter frame: 坐标
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    /// 初始化Xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        
        backgroundColor = .clear
        addSubviews()
    }
    
    private func addSubviews() {
        
        progressBar.progressViewStyle = .default
        progressBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7988548801)
        progressBar.trackTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2964201627)
        progressBar.progress = 0.0
        
        addSubview(progressBar)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        progressBar.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 10).isActive = true
        progressBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        
        let fiveMLater = Date().timeIntervalSinceNow
        
        startTime.text = ViuPlayerTabbarConfig.formatSecondsToString(fiveMLater)
        startTime.font = UIFont.boldSystemFont(ofSize: 30)
        startTime.textColor = .white
        addSubview(startTime)
        
        startTime.translatesAutoresizingMaskIntoConstraints = false
        startTime.leftAnchor.constraint(equalTo: progressBar.leftAnchor).isActive = true
        startTime.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 12).isActive = true
        startTime.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        endTime.text = ViuPlayerTabbarConfig.formatSecondsToString(fiveMLater)
        endTime.font = UIFont.boldSystemFont(ofSize: 30)
        endTime.textColor = .white
        addSubview(endTime)
        
        endTime.translatesAutoresizingMaskIntoConstraints = false
        endTime.rightAnchor.constraint(equalTo: progressBar.rightAnchor).isActive = true
        endTime.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 12).isActive = true
        endTime.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func timerStart() {
        if self.isHidden == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                self.hiddenProgress()
            }
        }
    }
    
    func hiddenProgress() {
        UIView.animate(withDuration: 0.25, animations: {
            self.isHidden = true
        })
    }
    
    func showProgress() {
        UIView.animate(withDuration: 0.25, animations: {
            self.isHidden = false
        })
    }
    
    deinit {
        print("ViuPlayerProgressView deinit")
    }
}
