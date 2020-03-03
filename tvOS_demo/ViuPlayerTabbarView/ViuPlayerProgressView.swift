//
//  ViuPlayerProgressView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/22.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerProgressView: UIView {
    
    /// 焦点View
    var focusView: UIView?

    lazy var progressBar: UIProgressView = {
        let pro = UIProgressView()
        pro.progressViewStyle = .default
        pro.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7988548801)
        pro.trackTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2964201627)
        pro.progress = 0.0
        return pro
    }()
    
    lazy var progressLine: UIView = {
        let line = UIView()
        line.backgroundColor = .purple
        return line
    }()
    
    lazy var progressLineByUser: UIView = {
        let lineUser = UIView()
        lineUser.backgroundColor = .purple
        return lineUser
    }()
    
    lazy var startTime: UILabel = {
        let sTime = UILabel()
        sTime.text = "00:00"
        sTime.font = UIFont.boldSystemFont(ofSize: 30)
        sTime.textColor = .white
        return sTime
    }()
    
    lazy var endTime: UILabel = {
        let eTime = UILabel()
        eTime.text = "00:00"
        eTime.font = UIFont.boldSystemFont(ofSize: 30)
        eTime.textColor = .white
        return eTime
    }()

    lazy var thumbnailImgView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        return iv
    }()
    
    lazy var thumbnailTime: UILabel = {
        let t = UILabel()
        t.text = "00:00"
        t.font = UIFont.boldSystemFont(ofSize: 30)
        t.textColor = .white
        t.textAlignment = .center
        return t
    }()
        
//    lazy var fastForward: UIButton = {
//        let f = UIButton.init(type: .custom)
//        f.setTitle("快进", for: .normal)
//        f.setTitle("快进", for: .focused)
//        f.setTitleColor(.white, for: .normal)
//        f.setTitleColor(.blue, for: .focused)
//        f.titleLabel!.font = UIFont.boldSystemFont(ofSize: 30)
//        f.addTarget(self, action: #selector(fastForwardAction), for:.primaryActionTriggered)
//        f.isHidden = true
//        return f
//    }()
//
//    lazy var backBtn: UIButton = {
//        let b = UIButton.init(type: .custom)
//        b.setTitle("后退", for: .normal)
//        b.setTitle("后退", for: .focused)
//        b.setTitleColor(.white, for: .normal)
//        b.setTitleColor(.blue, for: .focused)
//        b.titleLabel!.font = UIFont.boldSystemFont(ofSize: 30)
//        b.isHidden = true
//        return b
//    }()
    
    // 快进
    lazy var rightActionIndicator: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage.init(named: "forward-10")
        return iv
    }()
    
    // 后退
    lazy var leftActionIndicator: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage.init(named: "rewind-10")
        return iv
    }()
    
    
    // 快进buffer加载
    lazy var bufferingIndicator: UIActivityIndicatorView = {
        if #available(tvOS 13.0, *) {
            let av = UIActivityIndicatorView.init(style: .medium)
            av.stopAnimating()
            av.color = .white
            return av
        } else {
            let av = UIActivityIndicatorView.init(style: .white)
            av.stopAnimating()
            av.color = .white
            return av
        }
    }()

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
        addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        progressBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 10).isActive = true
        progressBar.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        
        // 当前进度
        progressBar.addSubview(progressLine)
        progressLine.frame = CGRect(x: 0, y: 0, width: 2, height: 10)
        
        // 用户调整的进度
        addSubview(progressLineByUser)

        // 当前时间
        addSubview(startTime)
        startTime.translatesAutoresizingMaskIntoConstraints = false
        startTime.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 10).isActive = true
        startTime.heightAnchor.constraint(equalToConstant: 30).isActive = true
        startTime.leftAnchor.constraint(greaterThanOrEqualTo: progressBar.leftAnchor).isActive = true
        startTime.rightAnchor.constraint(lessThanOrEqualTo: progressBar.rightAnchor).isActive = true
        let stCenterCon = startTime.centerXAnchor.constraint(equalTo: progressLine.centerXAnchor)
        stCenterCon.priority = .defaultLow
        stCenterCon.isActive = true
        
        // 快进与后退
        addSubview(rightActionIndicator)
        rightActionIndicator.translatesAutoresizingMaskIntoConstraints = false
        rightActionIndicator.centerYAnchor.constraint(equalTo: startTime.centerYAnchor).isActive = true
        rightActionIndicator.leftAnchor.constraint(equalTo: startTime.rightAnchor, constant: 20).isActive = true
        rightActionIndicator.heightAnchor.constraint(equalToConstant: 30).isActive = true
        rightActionIndicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(leftActionIndicator)
        leftActionIndicator.translatesAutoresizingMaskIntoConstraints = false
        leftActionIndicator.centerYAnchor.constraint(equalTo: startTime.centerYAnchor).isActive = true
        leftActionIndicator.rightAnchor.constraint(equalTo: startTime.leftAnchor, constant: -20).isActive = true
        leftActionIndicator.heightAnchor.constraint(equalToConstant: 30).isActive = true
        leftActionIndicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        // 总时间
        addSubview(endTime)
        endTime.translatesAutoresizingMaskIntoConstraints = false
        endTime.rightAnchor.constraint(equalTo: progressBar.rightAnchor).isActive = true
        endTime.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 10).isActive = true
        endTime.heightAnchor.constraint(equalToConstant: 30).isActive = true

        // 预览图
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
        thumbnailImgView.addSubview(thumbnailTime)
        thumbnailTime.translatesAutoresizingMaskIntoConstraints = false
        thumbnailTime.leftAnchor.constraint(equalTo: thumbnailImgView.leftAnchor).isActive = true
        thumbnailTime.rightAnchor.constraint(equalTo: thumbnailImgView.rightAnchor).isActive = true
        thumbnailTime.bottomAnchor.constraint(equalTo: thumbnailImgView.bottomAnchor).isActive = true

        hiddenThumbnail()
        setBufferingIndicatorLayout()
    }
    
    private func setBufferingIndicatorLayout() {
        
        addSubview(bufferingIndicator)
        bufferingIndicator.translatesAutoresizingMaskIntoConstraints = false
        bufferingIndicator.leadingAnchor.constraint(equalTo: startTime.trailingAnchor, constant: 26).isActive = true
        bufferingIndicator.centerYAnchor.constraint(equalTo: startTime.centerYAnchor).isActive = true
        bufferingIndicator.widthAnchor.constraint(equalToConstant: 8).isActive = true
        bufferingIndicator.heightAnchor.constraint(equalToConstant: 8).isActive = true
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
        progressLineByUser.frame = CGRect(x: paraFrame.origin.x, y: paraFrame.origin.y - progressLine.frame.size.height, width: paraFrame.size.width, height: 24)
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
    
    func showRightActionIndicator() {
        if bufferingIndicator.isAnimating {
            rightActionIndicator.isHidden = true
        } else {
            rightActionIndicator.isHidden = false
        }
        leftActionIndicator.isHidden = true
        
    }
    
    func showLeftActionIndicator() {
        leftActionIndicator.isHidden = false
        rightActionIndicator.isHidden = true
    }
    
    func hiddenFastForwordAndRewind() {
        leftActionIndicator.isHidden = true
        rightActionIndicator.isHidden = true
        rightActionIndicator.image = UIImage.init(named: "forward-10")
    }
    
    deinit {
        print("ViuPlayerProgressView deinit")
    }
}

extension ViuPlayerProgressView {
    
    override var canBecomeFocused: Bool {
         return true
    }
        
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
        
        
    }
}
