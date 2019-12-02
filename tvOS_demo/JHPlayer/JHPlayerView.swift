//
//  JHPlayerView.swift
//  JHPlayerView
//
//  Created by Jerry He on 2019/2/10.
//  Copyright © 2019年 jerry. All rights reserved.
//

import UIKit
import MediaPlayer

public protocol JHPlayerViewDelegate: NSObjectProtocol {
    /// Fullscreen
    ///
    /// - Parameters:
    ///   - playerView: player view
    ///   - fullscreen: Whether full screen
    func jhPlayerView(_ playerView: JHPlayerView, willFullscreen isFullscreen: Bool)
    
    /// Close play view
    ///
    /// - Parameter playerView: player view
    func jhPlayerView(didTappedClose playerView: JHPlayerView)
    
    /// Displaye control
    ///
    /// - Parameter playerView: playerView
    func jhPlayerView(didDisplayControl playerView: JHPlayerView)
    
}

// MARK: - delegate methods optional
public extension JHPlayerViewDelegate {
    
    func jhPlayerView(_ playerView: JHPlayerView, willFullscreen fullscreen: Bool){}
    
    func jhPlayerView(didTappedClose playerView: JHPlayerView) {}
    
    func jhPlayerView(didDisplayControl playerView: JHPlayerView) {}
}

public enum JHPlayerViewPanGestureDirection: Int {
    case vertical
    case horizontal
}

open class JHPlayerView: UIView {

    /// 焦点View
    var focusView: UIView?
    // 播放器导航栏
    let viuPlayerTabbar = ViuPlayerTabbarView()
    // 播放器进度条
    let viuProgressView = ViuPlayerProgressView()
    
    weak open var jhPlayer : JHPlayer?
    open var controlViewDuration : TimeInterval = 5.0  /// default 5.0
    open fileprivate(set) var playerLayer : AVPlayerLayer?
    open fileprivate(set) var isTimeSliding : Bool = false
    open var isDisplayControl : Bool = true {
        didSet {
            if isDisplayControl != oldValue {
                delegate?.jhPlayerView(didDisplayControl: self)
            }
        }
    }
    open weak var delegate : JHPlayerViewDelegate?
    open var panGestureDirection : JHPlayerViewPanGestureDirection = .horizontal
    open var loadingIndicator = JHPlayerLoadingIndicator()
    open var tabbarSwipeUp = UISwipeGestureRecognizer()
    open var tabbarSwipeDown = UISwipeGestureRecognizer()
    
    open var timer : Timer = {
        let time = Timer()
        return time
    }()
    
    fileprivate weak var parentView : UIView?
    fileprivate var viewFrame = CGRect()
    
    // bottom view
    open var bottomView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    
    //MARK:- life cycle
    public override init(frame: CGRect) {
        self.playerLayer = AVPlayerLayer(player: nil)
        super.init(frame: frame)
        configurationUI()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer.invalidate()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
        
        print("JHPlayerView deinit")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateDisplayerView(frame: bounds)
    }
    
    func setjhPlayer(jhPlayer: JHPlayer) {
        self.jhPlayer = jhPlayer
    }
    
    open func reloadPlayerLayer() {
        playerLayer = AVPlayerLayer(player: self.jhPlayer?.player)
        layer.insertSublayer(self.playerLayer!, at: 0)
        updateDisplayerView(frame: self.bounds)
        reloadGravity()
    }
    
    /// play state did change
    ///
    /// - Parameter state: state
    open func playStateDidChange(_ state: JHPlayerState) {
        if state == .playing || state == .playFinished {
            setupTimer()
        }
        if state == .playFinished {
            loadingIndicator.isHidden = true
        }
    }
    /// buffer state change
    ///
    /// - Parameter state: buffer state
    open func bufferStateDidChange(_ state: JHPlayerBufferstate) {
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
        print(Float(bufferedDuration / totalDuration))
        viuProgressView.progressBar.setProgress(Float(bufferedDuration / totalDuration), animated: true)
    }
    
    /// player diration
    ///
    /// - Parameters:
    ///   - currentDuration: current duration
    ///   - totalDuration: total duration
    open func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        var current = formatSecondsToString(currentDuration)
        if totalDuration.isNaN {  // HLS
            current = "00:00"
        }
        if !isTimeSliding {
            viuProgressView.startTimeString = current
            viuProgressView.endTimeString = formatSecondsToString(totalDuration - currentDuration)
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
        
        viuPlayerTabbar.buttonModels = [model, model2, model3]
        
        let name = "JHThumbnailsGeneratedNotification"
        NotificationCenter.default.addObserver(self, selector: #selector(buildScrubber(noti:)), name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    @objc func buildScrubber(noti: Notification) {
        
        let array:[JHThumbnail] = noti.object as! [JHThumbnail]
        
        array.enumerated().forEach { (offset, object) in
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
    open func displayControlView(_ isDisplay:Bool) {
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
extension JHPlayerView {
    
    open func updateDisplayerView(frame: CGRect) {
        playerLayer?.frame = frame
    }
    
    open func reloadGravity() {
        if jhPlayer != nil {
            switch jhPlayer!.gravityMode {
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
    open func playFailed(_ error: JHPlayerError) {
        // error
    }
    
    public func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN{
            return "00:00"
        }
        let interval = Int(seconds)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let min = interval / 60
        return String(format: "%02d:%02d", min, sec)
    }
    
    public func showTabbar() {
        viuPlayerTabbar.showTabbarView()
    }
    
    public func hiddenTabbar() {
        viuPlayerTabbar.hiddenTabbarView()
    }
}

// MARK: - private
extension JHPlayerView {
    
    internal func play() {
        
    }
    
    internal func pause() {
        
    }
    
    internal func displayControlAnimation() {
        bottomView.isHidden = false
        isDisplayControl = true
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 1
        }) { (completion) in
            self.setupTimer()
        }
    }
    internal func hiddenControlAnimation() {
        timer.invalidate()
        isDisplayControl = false
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 0
            
        }) { (completion) in
            self.bottomView.isHidden = true
            
        }
    }
    internal func setupTimer() {
        timer.invalidate()
        timer = Timer.jhPlayer_scheduledTimerWithTimeInterval(self.controlViewDuration, block: {  [weak self]  in
            guard let strongSelf = self else { return }
            strongSelf.displayControlView(false)
            }, repeats: false)
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension JHPlayerView: UIGestureRecognizerDelegate {

    
}

// MARK: - focus view
extension JHPlayerView {

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

//MARK: - UI autoLayout
extension JHPlayerView {
    
    internal func configurationBottomView() {
        addSubview(bottomView)
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        bottomView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        loadingIndicator.lineWidth = 1.0
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
    }
    
    internal func configurationViuProgressView() {
    
        bottomView.addSubview(viuProgressView)
        
        viuProgressView.translatesAutoresizingMaskIntoConstraints = false
        viuProgressView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 100).isActive = true
        viuProgressView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -100).isActive = true
        viuProgressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        viuProgressView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
}
