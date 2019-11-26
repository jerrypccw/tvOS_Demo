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
    
    weak open var jhPlayer : JHPlayer?
    open var controlViewDuration : TimeInterval = 5.0  /// default 5.0
    open fileprivate(set) var playerLayer : AVPlayerLayer?
    open fileprivate(set) var isTimeSliding : Bool = false
    open fileprivate(set) var isDisplayControl : Bool = true {
        didSet {
            if isDisplayControl != oldValue {
                delegate?.jhPlayerView(didDisplayControl: self)
            }
        }
    }
    open weak var delegate : JHPlayerViewDelegate?

    open var loadingIndicator = JHPlayerLoadingIndicator()
    open var timeLabel : UILabel = UILabel()
    
    fileprivate var timer : Timer = {
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
        
        var current = formatSecondsToString((jhPlayer?.currentDuration)!)
        if (jhPlayer?.totalDuration.isNaN)! {  // HLS
            current = "00:00"
        }
        if state == .readyToPlay && !isTimeSliding {
            timeLabel.text = "\(current + " / " +  (formatSecondsToString((jhPlayer?.totalDuration)!)))"
        }
    }
    
    /// buffer duration
    ///
    /// - Parameters:
    ///   - bufferedDuration: buffer duration
    ///   - totalDuration: total duratiom
    open func bufferedDidChange(_ bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
//        timeSlider.setProgress(Float(bufferedDuration / totalDuration), animated: true)
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
            timeLabel.text = "\(current + " / " +  (formatSecondsToString(totalDuration)))"
            //            timeSlider.value = Float(currentDuration / totalDuration)
        }
    }
    
    open func configurationUI() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        configurationBottomView()
        
    }
    
    open func reloadPlayerView() {
        playerLayer = AVPlayerLayer(player: nil)
//        timeSlider.setProgress(0, animated: false)
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
        } else {
            hiddenControlAnimation()
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
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view as? JHPlayerView != nil) {
            return true
        }
        return false
    }
}

// MARK: - Event
extension JHPlayerView {
    
    
    internal func panGestureHorizontal(_ velocityX: CGFloat) -> TimeInterval {
        displayControlView(true)
        isTimeSliding = true
        timer.invalidate()
        return TimeInterval.nan
    }
    
}

//MARK: - UI autoLayout
extension JHPlayerView {
    
    
    internal func configurationBottomView() {
        addSubview(bottomView)
        
        loadingIndicator.lineWidth = 1.0
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
    }
    
}
