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
    lazy var progressLine = UIView()
    
    var progress: Float? {
        didSet {
            guard let p = progress else {
                return
            }
           updateStartTimeFrame(p)
        }
    }
    
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
        
        startTime.text = "00:00"
        startTime.font = UIFont.boldSystemFont(ofSize: 30)
        startTime.textColor = .white
        
        addSubview(startTime)
        startTime.translatesAutoresizingMaskIntoConstraints = false
        startTime.leftAnchor.constraint(equalTo: progressBar.leftAnchor).isActive = true
        startTime.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 12).isActive = true
        startTime.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        endTime.text = "00:00"
        endTime.font = UIFont.boldSystemFont(ofSize: 30)
        endTime.textColor = .white
       
        addSubview(endTime)
        endTime.translatesAutoresizingMaskIntoConstraints = false
        endTime.rightAnchor.constraint(equalTo: progressBar.rightAnchor).isActive = true
        endTime.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 12).isActive = true
        endTime.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        progressLine.backgroundColor = .purple
        addSubview(progressLine)
        progressLine.translatesAutoresizingMaskIntoConstraints = false
        progressLine.leftAnchor.constraint(equalTo: progressBar.leftAnchor).isActive = true      
        progressLine.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor).isActive = true
        progressLine.heightAnchor.constraint(equalToConstant: 10).isActive = true
        progressLine.widthAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    private func updateStartTimeFrame(_ progress: Float) {
        
        UIView.animate(withDuration: 0.25) {
            let pro = max(0.0, min(progress, 1.0))
            let x = self.progressBar.bounds.size.width * CGFloat(pro)
            self.progressLine.transform = CGAffineTransform.init(translationX: x, y: 0.0)
            let startTimeCenterX = self.startTime.frame.size.width / 2
            if x > startTimeCenterX {
                self.startTime.transform = CGAffineTransform.init(translationX: x - startTimeCenterX, y: 0.0)
            }
        }
    }
    
    func pauseStatusAction() {

    }
    
    func normalStatusAction() {

    }
    
    deinit {
        print("ViuPlayerProgressView deinit")
    }
}
