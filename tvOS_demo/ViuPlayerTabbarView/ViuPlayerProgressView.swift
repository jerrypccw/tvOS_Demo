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

    var duration = TimeInterval.zero

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

//    var second = 5.0

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
        progressBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        progressBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 10).isActive = true
        progressBar.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true

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
        progressBar.addSubview(progressLine)
        progressLine.frame = CGRect(x: 0, y: 0, width: 2, height: 10)

        progressLineByUser.backgroundColor = .purple
        addSubview(progressLineByUser)

        thumbnailImgView.backgroundColor = .purple
        addSubview(thumbnailImgView)
        thumbnailImgView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImgView.leftAnchor.constraint(greaterThanOrEqualTo: progressBar.leftAnchor).isActive = true
        thumbnailImgView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        thumbnailImgView.bottomAnchor.constraint(equalTo: progressLineByUser.topAnchor).isActive = true
        thumbnailImgView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        thumbnailImgView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        let centerCon = thumbnailImgView.centerXAnchor.constraint(equalTo: progressLineByUser.centerXAnchor)
        centerCon.priority = .defaultLow
        centerCon.isActive = true

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
        let paraFrame = progressLine.convert(progressLine.frame, to: self)
        progressLineByUser.frame = CGRect(x: paraFrame.origin.x, y: paraFrame.origin.y - progressLine.frame.size.height, width: paraFrame.size.width, height: 20)
    }

    /// 显示预览图
    func showThumbnail(duration: TimeInterval) {
        self.duration = duration

        setThumbnailTime()

        progressLineByUser.isHidden = false
        thumbnailImgView.isHidden = false
    }

    /// 隐藏预览图
    func hiddenThumbnail() {
        progressLineByUser.isHidden = true
        thumbnailImgView.isHidden = true

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
        let percent = progressLineByUser.frame.origin.x / frame.size.width
        var time = TimeInterval(percent) * duration
        if time > duration {
            time = duration
        }
        thumbnailTime.text = time.formatToString()
    }

    deinit {
        print("ViuPlayerProgressView deinit")
    }
}
