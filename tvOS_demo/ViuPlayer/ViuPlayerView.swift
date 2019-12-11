//
//  JHPlayerView.swift
//  JHPlayerView
//
//  Created by Jerry He on 2019/2/10.
//  Copyright © 2019年 jerry. All rights reserved.
//

import MediaPlayer
import UIKit

public protocol ViuPlayerViewDelegate: NSObjectProtocol {
    /// Fullscreen
    ///
    /// - Parameters:
    ///   - playerView: player view
    ///   - fullscreen: Whether full screen
    func viuPlayerView(_ playerView: ViuPlayerView, willFullscreen isFullscreen: Bool)
    
    /// Close play view
    ///
    /// - Parameter playerView: player view
    func viuPlayerView(didTappedClose playerView: ViuPlayerView)
    
    /// Displaye control
    ///
    /// - Parameter playerView: playerView
    func viuPlayerView(didDisplayControl playerView: ViuPlayerView)
}

// MARK: - delegate methods optional

public extension ViuPlayerViewDelegate {
    func viuPlayerView(_ playerView: ViuPlayerView, willFullscreen fullscreen: Bool) {}
    
    func viuPlayerView(didTappedClose playerView: ViuPlayerView) {}
    
    func viuPlayerView(didDisplayControl playerView: ViuPlayerView) {}
}

public enum ViuPlayerViewPanGestureDirection: Int {
    case vertical
    case horizontal
}

open class ViuPlayerView: UIView {
    /// 焦点View
    var focusView: UIView?
    // 播放器导航栏
    let viuPlayerTabbar = ViuPlayerTabbarView()
    // 播放器进度条
    let viuProgressView = ViuPlayerProgressView()
    
    open weak var viuPlayer: ViuPlayer?
    open var controlViewDuration: TimeInterval = 5.0 /// default 5.0
    open fileprivate(set) var playerLayer: AVPlayerLayer?
    open fileprivate(set) var isTimeSliding: Bool = false
    open var isDisplayControl: Bool = true {
        didSet {
            if isDisplayControl != oldValue {
                delegate?.viuPlayerView(didDisplayControl: self)
            }
        }
    }
    
    open weak var delegate: ViuPlayerViewDelegate?
    open var panGestureDirection: ViuPlayerViewPanGestureDirection = .horizontal
    open var loadingIndicator = ViuPlayerLoadingIndicator()
    open var tabbarSwipeUp = UISwipeGestureRecognizer()
    open var tabbarSwipeDown = UISwipeGestureRecognizer()
    
    open var timer: Timer = {
        let time = Timer()
        return time
    }()
    
    fileprivate weak var parentView: UIView?
    fileprivate var viewFrame = CGRect()
    
    // bottom view
    open var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.isHidden = true
        return view
    }()
    
    // MARK: - life cycle
    
    public override init(frame: CGRect) {
        playerLayer = AVPlayerLayer(player: nil)
        super.init(frame: frame)
        configurationUI()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer.invalidate()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
        
        print("ViuPlayerView deinit")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateDisplayerView(frame: bounds)
    }
    
    func setViuPlayer(viuPlayer: ViuPlayer) {
        self.viuPlayer = viuPlayer
    }
    
    open func reloadPlayerLayer() {
        playerLayer = AVPlayerLayer(player: viuPlayer?.player)
        layer.insertSublayer(playerLayer!, at: 0)
        updateDisplayerView(frame: bounds)
        reloadGravity()
    }
    
    /// play state did change
    ///
    /// - Parameter state: state
    open func playStateDidChange(_ state: ViuPlayerState) {
        if state == .playing || state == .playFinished {
            setupTimer()
            loadingIndicator.isHidden = true
        }    
    }
    
    /// buffer state change
    ///
    /// - Parameter state: buffer state
    open func bufferStateDidChange(_ state: ViuPlayerBufferstate) {
        if state == .buffering {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
        }
        
        //        var current = formatSecondsToString((jhPlayer?.currentDuration)!)
        //        if (jhPlayer?.totalDuration.isNaN)! {  // HLS
        //            current = "00:00"
        //        }
        //        if state == .readyToPlay && !isTimeSliding {
        //
        //        }
    }
    
    /// buffer duration
    ///
    /// - Parameters:
    ///   - bufferedDuration: buffer duration
    ///   - totalDuration: total duratiom
    open func bufferedDidChange(_ bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
        //        timeSlider.setProgress(Float(bufferedDuration / totalDuration), animated: true)
        //        print(Float(bufferedDuration / totalDuration))
        viuProgressView.progressBar.setProgress(Float(bufferedDuration / totalDuration), animated: true)
    }
    
    /// player diration
    ///
    /// - Parameters:
    ///   - currentDuration: current duration
    ///   - totalDuration: total duration
    open func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        var current = currentDuration.formatToString()
        if totalDuration.isNaN { // HLS
            current = "00:00"
        }
        if !isTimeSliding {
            viuProgressView.startTimeString = current
            viuProgressView.endTimeString = (totalDuration - currentDuration).formatToString()
            viuProgressView.setPorgressLineX(percent: CGFloat(currentDuration / totalDuration))
        }
    }
    
    open func configurationUI() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        addSubview(viuPlayerTabbar)
        configurationBottomView()
        configurationViuProgressView()
        
        let model = TabbarIntroductionModel()
        model.buttonName = "简介"
        model.imageUrl = ""
        model.dramaTitle = "第15集 测试的播放器"
        model.dramaDescription = "测试的播放器导航栏的简介 测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介"
        
        let model2 = TabbarCustomModel()
        model2.buttonName = "字幕"
        model2.customs += ["开", "关"]
        
        let model3 = TabbarSubtitleModel()
        model3.buttonName = "语言"
        model3.subtitles += ["中文", "英文"]
        
        let model4 = TabbarAudioModel()
        model4.buttonName = "音轨"
        model4.languages = ["英语"]
        
        viuPlayerTabbar.buttonModels = [model, model2, model3, model4]
        
        let name = "ViuThumbnailsGeneratedNotification"
        NotificationCenter.default.addObserver(self, selector: #selector(buildScrubber(noti:)), name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    @objc func buildScrubber(noti: Notification) {
        let array: [ViuThumbnail] = noti.object as! [ViuThumbnail]
        
        array.enumerated().forEach { _, object in
            print("array \(String(describing: object.image))")
        }
        
    }
    
    open func reloadPlayerView() {
        playerLayer = AVPlayerLayer(player: nil)
        viuProgressView.progressBar.setProgress(0, animated: false)
        isTimeSliding = false
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        reloadPlayerLayer()
    }
    
    /// control view display
    ///
    /// - Parameter display: is display
    open func displayControlView(_ isDisplay: Bool) {
        if isDisplay {
            displayControlAnimation()
            //            updateFocusView(focusView: bottomView)
        } else {
            hiddenControlAnimation()
            //            updateFocusView(focusView: nil)
        }
    }
}

// MARK: - public

extension ViuPlayerView {
    open func updateDisplayerView(frame: CGRect) {
        playerLayer?.frame = frame
    }
    
    open func reloadGravity() {
        if viuPlayer != nil {
            switch viuPlayer!.gravityMode {
            case .resize:
                playerLayer?.videoGravity = .resize
            case .resizeAspect:
                playerLayer?.videoGravity = .resizeAspect
            case .resizeAspectFill:
                playerLayer?.videoGravity = .resizeAspectFill
            }
        }
    }
    
    /// play failed
    ///
    /// - Parameter error: error
    open func playFailed(_ error: ViuPlayerError) {
        // error
    }
    
    public func showTabbar() {
        viuPlayerTabbar.showTabbarView()
    }
    
    public func hiddenTabbar() {
        viuPlayerTabbar.hiddenTabbarView()
    }
}

// MARK: - private

extension ViuPlayerView {
    internal func play() {
    }
    
    internal func pause() {
    }
    
    internal func displayControlAnimation() {
        isDisplayControl = true
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 1
        }) { _ in
            self.bottomView.isHidden = false
            
            // 如果是暂停状态下，出现进度条，就显示预览图
            if self.viuPlayer?.state == .paused {
                self.viuProgressView.showThumbnail(duration: self.viuPlayer?.totalDuration ?? TimeInterval.zero)
            }
        }
    }
    
    internal func hiddenControlAnimation() {
        timer.invalidate()
        isDisplayControl = false
        // 隐藏预览图
        viuProgressView.hiddenThumbnail()
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 0
        }) { _ in
            self.bottomView.isHidden = true
        }
    }
    
    internal func setupTimer() {
        timer.invalidate()
        timer = Timer.viuPlayer_scheduledTimerWithTimeInterval(controlViewDuration, block: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.displayControlView(false)
            }, repeats: false)
    }
}

// MARK: - UIGestureRecognizerDelegate
//extension ViuPlayerView: UIGestureRecognizerDelegate {
//}

// MARK: - focus view

extension ViuPlayerView {
    
    //    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    //        super.hitTest(point, with: event)
    //
    //        print("hitTest \(point)")
    //        return nil
    //    }
    /// 重新定义focus view
    //    override open var preferredFocusEnvironments: [UIFocusEnvironment] {
    //        var environments = [UIFocusEnvironment]()
    //
    //        if focusView != nil {
    //            environments.append(focusView!)
    //        } else {
    //            environments = super.preferredFocusEnvironments
    //        }
    //        return environments
    //    }
    //
    //    /// 更新focus view
    //    ///
    //    /// - Parameter focusView: focus view
    //    func updateFocusView(focusView: UIView?) {
    //        self.focusView = focusView
    //        setNeedsFocusUpdate()
    //        updateFocusIfNeeded()
    //    }
}

// MARK: - UI autoLayout

extension ViuPlayerView {
    internal func configurationBottomView() {
        addSubview(bottomView)
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        loadingIndicator.lineWidth = 1.0
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 30).isActive = true        
    }
    
    internal func configurationViuProgressView() {
        bottomView.addSubview(viuProgressView)
        
        viuProgressView.translatesAutoresizingMaskIntoConstraints = false
        viuProgressView.leftAnchor.constraint(equalTo: leftAnchor, constant: 100).isActive = true
        viuProgressView.rightAnchor.constraint(equalTo: rightAnchor, constant: -100).isActive = true
        viuProgressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        viuProgressView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
}
