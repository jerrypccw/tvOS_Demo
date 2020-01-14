//
//  ViuPlayerProgressView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/22.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerProgressView: UIView {

    let progressBar = UIProgressView()
    let startTime = UILabel()
    let endTime = UILabel()
    let progressLine = UIView()
    let progressLineByUser = UIView()
    let thumbnailImgView = UIImageView()
    let thumbnailTime = UILabel()
    let fastForward = UIButton.init(type: .custom)
    let backBtn = UIButton.init(type: .custom)

    var duration = TimeInterval.zero

    var startTimeString: String? {
        didSet {
            self.startTime.text = self.startTimeString
        }
    }

    var endTimeString: String? {
        didSet {
            endTime.text = "-" + (endTimeString ?? "00:00")
        }
    }
    
    /// 用户选中快进的时间
    var seekTime: TimeInterval {
        get {
            let percent = progressLineByUser.frame.origin.x / frame.size.width
            var time = TimeInterval(percent) * duration
            if time > duration {
                time = duration
            }
            return time
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
        // 进度条
        progressBar.progressViewStyle = .default
        progressBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7988548801)
        progressBar.trackTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2964201627)
        progressBar.progress = 0.0

        addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        progressBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 10).isActive = true
        progressBar.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        
        // 当前进度
        progressLine.backgroundColor = .purple
        progressBar.addSubview(progressLine)
        progressLine.frame = CGRect(x: 0, y: 0, width: 2, height: 10)
        
        // 用户调整的进度
        progressLineByUser.backgroundColor = .purple
        addSubview(progressLineByUser)

        // 当前时间
        startTime.text = "00:00"
        startTime.font = UIFont.boldSystemFont(ofSize: 30)
        startTime.textColor = .white

        addSubview(startTime)
        startTime.translatesAutoresizingMaskIntoConstraints = false
//        startTime.leftAnchor.constraint(equalTo: progressBar.leftAnchor).isActive = true
        startTime.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 12).isActive = true
        startTime.heightAnchor.constraint(equalToConstant: 30).isActive = true
        startTime.leftAnchor.constraint(greaterThanOrEqualTo: progressBar.leftAnchor).isActive = true
        startTime.rightAnchor.constraint(lessThanOrEqualTo: progressBar.rightAnchor).isActive = true
        let stCenterCon = startTime.centerXAnchor.constraint(equalTo: progressLine.centerXAnchor)
        stCenterCon.priority = .defaultLow
        stCenterCon.isActive = true
        
        // 快进与后退
        fastForward.setTitle("快进", for: .normal)
        fastForward.setTitleColor(.white, for: .normal)
        fastForward.titleLabel!.font = UIFont.boldSystemFont(ofSize: 30)
        fastForward.isHidden = true
        
        addSubview(fastForward)
        fastForward.translatesAutoresizingMaskIntoConstraints = false
        fastForward.centerYAnchor.constraint(equalTo: startTime.centerYAnchor).isActive = true
        fastForward.leftAnchor.constraint(equalTo: startTime.rightAnchor, constant: 12).isActive = true
        fastForward.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        backBtn.setTitle("后退", for: .normal)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.titleLabel!.font = UIFont.boldSystemFont(ofSize: 30)
        backBtn.isHidden = true
        
        addSubview(backBtn)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.centerYAnchor.constraint(equalTo: startTime.centerYAnchor).isActive = true
        backBtn.rightAnchor.constraint(equalTo: startTime.leftAnchor, constant: -12).isActive = true
        backBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // 总时间
        endTime.text = "00:00"
        endTime.font = UIFont.boldSystemFont(ofSize: 30)
        endTime.textColor = .white
       
        addSubview(endTime)
        endTime.translatesAutoresizingMaskIntoConstraints = false
        endTime.rightAnchor.constraint(equalTo: progressBar.rightAnchor).isActive = true
        endTime.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 12).isActive = true
        endTime.heightAnchor.constraint(equalToConstant: 30).isActive = true

        // 预览图
        thumbnailImgView.backgroundColor = .clear
        addSubview(thumbnailImgView)
        thumbnailImgView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImgView.leftAnchor.constraint(greaterThanOrEqualTo: progressBar.leftAnchor).isActive = true
        thumbnailImgView.rightAnchor.constraint(lessThanOrEqualTo: progressBar.rightAnchor).isActive = true
        thumbnailImgView.bottomAnchor.constraint(equalTo: progressLineByUser.topAnchor).isActive = true
        thumbnailImgView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        thumbnailImgView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        let thuCenterCon = thumbnailImgView.centerXAnchor.constraint(equalTo: progressLineByUser.centerXAnchor)
        thuCenterCon.priority = .defaultLow
        thuCenterCon.isActive = true

        // 预览图时间
        thumbnailTime.text = "00:00"
        thumbnailTime.font = UIFont.boldSystemFont(ofSize: 30)
        thumbnailTime.textColor = .white
        thumbnailTime.textAlignment = .center
        thumbnailImgView.addSubview(thumbnailTime)
        thumbnailTime.translatesAutoresizingMaskIntoConstraints = false
        thumbnailTime.leftAnchor.constraint(equalTo: thumbnailImgView.leftAnchor).isActive = true
        thumbnailTime.rightAnchor.constraint(equalTo: thumbnailImgView.rightAnchor).isActive = true
        thumbnailTime.bottomAnchor.constraint(equalTo: thumbnailImgView.bottomAnchor).isActive = true

        hiddenThumbnail()
    }

    /// 设置播放进度条
    func setPorgressLineX(percent: CGFloat) {
        var offset = progressBar.frame.width * percent
        if offset.isNaN {
            offset = 0
        }
        progressLine.frame = CGRect(x: offset, y: 0, width: 2, height: 10)
        // 设置预览图起始位置
        let paraFrame = progressBar.convert(progressLine.frame, to: self)
        progressLineByUser.frame = CGRect(x: paraFrame.origin.x, y: paraFrame.origin.y - progressLine.frame.size.height, width: paraFrame.size.width, height: 20)
    }

    /// 显示预览图
    func showThumbnail(duration: TimeInterval) {
        self.duration = duration

        progressLineByUser.isHidden = false
        thumbnailImgView.isHidden = false
        thumbnailTime.isHidden = false
        
        setThumbnailTime()
    }

    /// 隐藏预览图
    func hiddenThumbnail() {
        progressLineByUser.isHidden = true
        thumbnailImgView.isHidden = true
        thumbnailTime.isHidden = true

        // 设置预览图起始位置
        let paraFrame = convert(progressLine.frame, to: self)
        progressLineByUser.frame = CGRect(x: paraFrame.origin.x, y: paraFrame.origin.y, width: paraFrame.size.width, height: 20)
    }

    /// 滑动进度条
    func setPorgressLineByUser(offset: CGFloat) {
        var newFrame = progressLineByUser.frame.offsetBy(dx: offset, dy: 0)
        if newFrame.origin.x < 0 {
            newFrame = CGRect(x: 0, y: newFrame.origin.y, width: newFrame.size.width, height: newFrame.size.height)
        } else if newFrame.origin.x > frame.size.width {
            newFrame = CGRect(x: frame.size.width, y: newFrame.origin.y, width: newFrame.size.width, height: newFrame.size.height)
        }
        progressLineByUser.frame = newFrame

        setThumbnailTime()
    }

    /// 计算播放器跳转的时间
    func setThumbnailTime() {
        thumbnailTime.text = seekTime.formatToString()
    }
    
    func showFastForword() {
        backBtn.isHidden = true
        fastForward.isHidden = false
    }
    
    func showBackLabel() {
        backBtn.isHidden = false
        fastForward.isHidden = true
    }
    
    func hiddenFastForwordAndBack() {
        backBtn.isHidden = true
        fastForward.isHidden = true
    }

    deinit {
        print("ViuPlayerProgressView deinit")
    }
}
