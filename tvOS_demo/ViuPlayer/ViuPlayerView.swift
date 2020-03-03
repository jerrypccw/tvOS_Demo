//
//  JHPlayerView.swift
//  JHPlayerView
//
//  Created by Jerry He on 2019/2/10.
//  Copyright © 2019年 jerry. All rights reserved.
//

import MediaPlayer
import UIKit

open class ViuPlayerView: UIView {
    /// 焦点View
    var focusView: UIView?
    // 播放器导航栏
    let viuPlayerTabbar = ViuPlayerTabbarView()
    // 播放器进度条
    let viuProgressView = ViuPlayerProgressView()
    
    open weak var viuPlayer: ViuPlayer?
    open var controlViewDuration: TimeInterval = 6.0 /// default 5.0
    open var displayDuration: TimeInterval = 0.5
    open fileprivate(set) var playerLayer: AVPlayerLayer?
    open var isDisplayControl: Bool = true {
        didSet {
            if isDisplayControl != oldValue {
                
            }
        }
    }
    
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
    open var shadowView: UIView = {
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
            loadingIndicator.stopAnimating()
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
    }
    
    /// buffer duration
    ///
    /// - Parameters:
    ///   - bufferedDuration: buffer duration
    ///   - totalDuration: total duratiom
    open func bufferedDidChange(_ bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
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

        viuProgressView.setPorgressLineX(percent: CGFloat(currentDuration / totalDuration))
        viuProgressView.startTimeString = current
        viuProgressView.endTimeString = (totalDuration - currentDuration).formatToString()
    }
    
    open func configurationUI() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        addSubview(viuPlayerTabbar)
        configurationShadowView()
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
        model3.subtitles += ["中文", "英文", "印度文", "日文", "韩文", "法文", "意大利文", "西班牙文", "繁体中文"]
        
//        model3.subtitles += ["中文", "英文"]
        
        let model4 = TabbarAudioModel()
        model4.buttonName = "音轨"
        model4.languages = ["英语"]
        
        viuPlayerTabbar.buttonModels = [model, model2, model3, model4]
        
    }
    
    open func reloadPlayerView() {
        playerLayer = AVPlayerLayer(player: nil)
        viuProgressView.progressBar.setProgress(0, animated: false)
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        reloadPlayerLayer()
    }

    open func displayControlView(_ isDisplay: Bool) {
        if isDisplay {
            displayControlAnimation()
        } else {
            hiddenControlAnimation()
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

    open func playFailed(_ error: ViuPlayerError) {
        // error
    }
    
    public func showTabbar() {
        viuPlayerTabbar.showTabbarView()
        displayControlView(false)
    }
    
    public func hiddenTabbar() {
        viuPlayerTabbar.hiddenTabbarView()
    }
}

// MARK: - private

extension ViuPlayerView {
    
    internal func displayControlAnimation() {
        isDisplayControl = true
        UIView.animate(withDuration: displayDuration, animations: { [weak self] in            
            guard let strongSelf = self else { return }
            strongSelf.viuProgressView.alpha = 1
            strongSelf.viuProgressView.isHidden = false
        })
    }
    
    internal func hiddenControlAnimation() {
        timer.invalidate()
        isDisplayControl = false
        UIView.animate(withDuration: displayDuration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viuProgressView.alpha = 0
            strongSelf.viuProgressView.isHidden = true
        })
    }
    
    internal func displayShadowView() {
        isDisplayControl = true
        UIView.animate(withDuration: displayDuration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.shadowView.alpha = 1
            strongSelf.shadowView.isHidden = false
        })
    }
    
    internal func hiddenShadowView() {
        UIView.animate(withDuration: displayDuration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.shadowView.alpha = 0
            strongSelf.shadowView.isHidden = true
        })
    }    
    
    internal func setupTimer() {
        timer.invalidate()
        timer = Timer.viuPlayer_scheduledTimerWithTimeInterval(controlViewDuration, block: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.displayControlView(false)
            }, repeats: false)
    }
}

// MARK: - UI autoLayout
extension ViuPlayerView {
    internal func configurationShadowView() {
        addSubview(shadowView)
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        shadowView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        shadowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        loadingIndicator.lineWidth = 4.0
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 80).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    internal func configurationViuProgressView() {
        
        viuProgressView.isHidden = true
        addSubview(viuProgressView)
        viuProgressView.translatesAutoresizingMaskIntoConstraints = false
        viuProgressView.leftAnchor.constraint(equalTo: leftAnchor, constant: 100).isActive = true
        viuProgressView.rightAnchor.constraint(equalTo: rightAnchor, constant: -100).isActive = true
        viuProgressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        viuProgressView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
}
