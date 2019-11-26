//
//  JHPlayer.swift
//  JHPlayerView
//
//  Created by Jerry He on 2019/2/10.
//  Copyright © 2019年 jerry. All rights reserved.
//

import UIKit
import AVFoundation

/// 播放状态
///
/// - none//default:
/// - playing//播放:
/// - paused//暂停:
/// - playFinished//播放完成:
/// - error//异常:
public enum JHPlayerState: Int {
    case none               // default
    case playing            // 播放
    case paused             // 暂停
    case playFinished       // 播放完成
    case error              // 异常
}

/// 缓冲状态
///
/// - none//default:
/// - readyToPlay//准备播放:
/// - buffering//正在缓冲:
/// - stop//停止:
/// - bufferFinished//缓冲完成:
public enum JHPlayerBufferstate: Int {
    case none           // default
    case readyToPlay    // 准备播放
    case buffering      // 正在缓冲
    case stop           // 停止
    case bufferFinished // 缓冲完成
}

/// 视频承载层
///
/// - resize//拉伸匹配范围:
/// - resizeAspect//default:
/// - resizeAspectFill//通过缩放填满层的范围区域:
public enum JHVideoGravityMode: Int {
    case resize            // 拉伸匹配范围
    case resizeAspect      // default
    case resizeAspectFill  // 通过缩放填满层的范围区域
}

/// 后台播放
///
/// - suspend//禁止:
/// - autoPlayAndPaused//自动播放和暂停:
/// - proceed//继续进行:
public enum JHPlayerBackgroundMode: Int {
    case suspend                // 禁止
    case autoPlayAndPaused      // 自动播放和暂停
    case proceed                // 继续进行
}

public protocol JHPlayerDelegate: NSObjectProtocol {
    // play state
    func jhPlayer(_ player: JHPlayer, stateDidChange state: JHPlayerState)
    // playe Duration
    func jhPlayer(_ player: JHPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval)
    // buffer state
    func jhPlayer(_ player: JHPlayer, bufferStateDidChange state: JHPlayerBufferstate)
    // buffered Duration
    func jhPlayer(_ player: JHPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval)
    // play error
    func jhPlayer(_ player: JHPlayer, playerFailed error: JHPlayerError)
}

// MARK: - delegate methods optional
public extension JHPlayerDelegate {
    func jhPlayer(_ player: JHPlayer, stateDidChange state: JHPlayerState) {}
    func jhPlayer(_ player: JHPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {}
    func jhPlayer(_ player: JHPlayer, bufferStateDidChange state: JHPlayerBufferstate) {}
    func jhPlayer(_ player: JHPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {}
    func jhPlayer(_ player: JHPlayer, playerFailed error: JHPlayerError) {}
}


open class JHPlayer: NSObject {
    
    //
    weak var delegate : JHPlayerDelegate?    
    //
    var displayView : JHPlayerView
    var gravityMode : JHVideoGravityMode = .resizeAspect
    var backgroundMode : JHPlayerBackgroundMode = .autoPlayAndPaused
    var bufferInterval : TimeInterval = 2.0
    //
    private var timeObserver: Any?
    //
    open fileprivate(set) var mediaFormat : JHPlayerMediaFormat
    open fileprivate(set) var totalDuration : TimeInterval = 0.0
    open fileprivate(set) var currentDuration : TimeInterval = 0.0
    open fileprivate(set) var buffering : Bool = false
    open fileprivate(set) var playerAsset : AVURLAsset?
    open fileprivate(set) var contentURL : URL?
    open fileprivate(set) var error : JHPlayerError
    
    fileprivate var seeking : Bool = false
//    fileprivate var resourceLoaderManager = VGPlayerResourceLoaderManager()
    
    //
    open fileprivate(set) var player : AVPlayer? {
        willSet{
            removePlayerObservers()
        }
        didSet {
            addPlayerObservers()
        }
    }
    
    open fileprivate(set) var playerItem : AVPlayerItem? {
        willSet {
            removePlayerItemObservers()
            removePlayerNotifations()
        }
        didSet {
            addPlayerItemObservers()
            addPlayerNotifications()
        }
    }
    
    open var state: JHPlayerState = .none {
        didSet {
            if state != oldValue {
                self.displayView.playStateDidChange(state)
                self.delegate?.jhPlayer(self, stateDidChange: state)
            }
        }
    }
    
    open var bufferState : JHPlayerBufferstate = .none {
        didSet {
            if bufferState != oldValue {
                self.displayView.bufferStateDidChange(bufferState)
                self.delegate?.jhPlayer(self, bufferStateDidChange: bufferState)
            }
        }
    }
    
    //MARK:- life cycle
    public init(URL: URL?, playerView: JHPlayerView?) {
        mediaFormat = JHPlayerUtils.decoderVideoFormat(URL)
        contentURL = URL
        error = JHPlayerError()
        if let view = playerView {
            displayView = view
        } else {
            displayView = JHPlayerView()
        }
        super.init()
        if contentURL != nil {
            configurationPlayer(contentURL!)
        }
    }
    
    public convenience init(URL: URL) {
        self.init(URL: URL, playerView: nil)
    }
    
    public convenience init(playerView: JHPlayerView) {
        self.init(URL: nil, playerView: playerView)
    }
    
    public override convenience init() {
        self.init(URL: nil, playerView: nil)
    }
    
    deinit {
        removePlayerNotifations()
        cleanPlayer()
        displayView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func configurationPlayer(_ URL: URL) {
        self.displayView.setjhPlayer(jhPlayer: self)
        self.playerAsset = AVURLAsset(url: URL, options: .none)
        if URL.absoluteString.hasPrefix("file:///") {
            let keys = ["tracks", "playable"];
            playerItem = AVPlayerItem(asset: playerAsset!, automaticallyLoadedAssetKeys: keys)
        } else {
            playerItem = playerItem(URL)
        }
        player = AVPlayer(playerItem: playerItem)
        displayView.reloadPlayerView()
    }
    
    open func playerItem(_ url: URL) -> AVPlayerItem {
        let urlAsset = AVURLAsset(url: url, options: nil)
        let playerItem = AVPlayerItem(asset: urlAsset)
        if #available(iOS 9.0, *) {
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        }
        return playerItem
    }
    
    // time KVO
    internal func addPlayerObservers() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] time in
            guard let strongSelf = self else { return }
            if let currentTime = strongSelf.player?.currentTime().seconds,
                let totalDuration = strongSelf.player?.currentItem?.duration.seconds {
                strongSelf.currentDuration = currentTime
                strongSelf.delegate?.jhPlayer(strongSelf, playerDurationDidChange: currentTime, totalDuration: totalDuration)
                strongSelf.displayView.playerDurationDidChange(currentTime, totalDuration: totalDuration)
            }
        })
    }
    internal func removePlayerObservers() {
        player?.removeTimeObserver(timeObserver!)
    }
}

//MARK: - public
extension JHPlayer {
    
    open func replaceVideo(_ URL: URL) {
        reloadPlayer()
        mediaFormat = JHPlayerUtils.decoderVideoFormat(URL)
        contentURL = URL
        configurationPlayer(URL)
    }
    
    open func reloadPlayer() {
        seeking = false
        totalDuration = 0.0
        currentDuration = 0.0
        error = JHPlayerError()
        state = .none
        buffering = false
        bufferState = .none
        cleanPlayer()
    }
    
    open func cleanPlayer() {
        player?.pause()
        player?.cancelPendingPrerolls()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerAsset?.cancelLoading()
        playerAsset = nil
        playerItem?.cancelPendingSeeks()
        playerItem = nil
    }
    
    open func play() {
        if contentURL == nil { return }
        player?.play()
        state = .playing
        displayView.play()
    }
    
    open func pause() {
        guard state == .paused else {
            player?.pause()
            state = .paused
            displayView.pause()
            return
        }
    }
    
    open func seekTime(_ time: TimeInterval) {
        seekTime(time, completion: nil)
    }
    
    open func seekTime(_ time: TimeInterval, completion: ((Bool) -> Swift.Void)?) {
        if time.isNaN || playerItem?.status != .readyToPlay {
            if completion != nil {
                completion!(false)
            }
            return
        }
        
        DispatchQueue.main.async { [weak self]  in
            guard let strongSelf = self else { return }
            strongSelf.seeking = true
            strongSelf.startPlayerBuffering()
            strongSelf.playerItem?.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: Int32(NSEC_PER_SEC)), completionHandler: { (finished) in
                DispatchQueue.main.async {
                    strongSelf.seeking = false
                    strongSelf.stopPlayerBuffering()
                    strongSelf.play()
                    if completion != nil {
                        completion!(finished)
                    }
                }
            })
        }
    }
    
}

//MARK: - private
extension JHPlayer {
    
    internal func startPlayerBuffering() {
        pause()
        bufferState = .buffering
        buffering = true
    }
    
    internal func stopPlayerBuffering() {
        bufferState = .stop
        buffering = false
    }
    
    internal func collectPlayerErrorLogEvent() {
        error.playerItemErrorLogEvent = playerItem?.errorLog()?.events
        error.error = playerItem?.error
        error.extendedLogData = playerItem?.errorLog()?.extendedLogData()
        error.extendedLogDataStringEncoding = playerItem?.errorLog()?.extendedLogDataStringEncoding
    }
}

//MARK: - Notifation Selector & KVO
private var playerItemContext = 0

extension JHPlayer {
    
    internal func addPlayerItemObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: options, context: &playerItemContext)
    }
    
    internal func addPlayerNotifications() {
        NotificationCenter.default.addObserver(self, selector: .playerItemDidPlayToEndTime, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationWillEnterForeground, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationDidEnterBackground, name:UIApplication.didEnterBackgroundNotification , object: nil)
    }
    
    internal func removePlayerItemObservers() {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty))
    }
    
    internal func removePlayerNotifations() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc internal func playerItemDidPlayToEnd(_ notification: Notification) {
        if state != .playFinished {
            state = .playFinished
        }
        
    }
    
    @objc internal func applicationWillEnterForeground(_ notification: Notification) {
        
        if let playerLayer = displayView.playerLayer  {
            playerLayer.player = player
        }
        
        switch self.backgroundMode {
        case .suspend:
            pause()
        case .autoPlayAndPaused:
            play()
        case .proceed:
            break
        }
    }
    
    @objc internal func applicationDidEnterBackground(_ notification: Notification) {
        
        if let playerLayer = displayView.playerLayer  {
            playerLayer.player = nil
        }
        
        switch self.backgroundMode {
        case .suspend:
            pause()
        case .autoPlayAndPaused:
            pause()
        case .proceed:
            play()
            break
        }
    }
}

// MARK: - Selecter
extension Selector {
    static let playerItemDidPlayToEndTime = #selector(JHPlayer.playerItemDidPlayToEnd(_:))
    static let applicationWillEnterForeground = #selector(JHPlayer.applicationWillEnterForeground(_:))
    static let applicationDidEnterBackground = #selector(JHPlayer.applicationDidEnterBackground(_:))
}

extension JHPlayer {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (context == &playerItemContext) {
            
            if keyPath == #keyPath(AVPlayerItem.status) {
                let status: AVPlayerItem.Status
                if let statusNumber = change?[.newKey] as? NSNumber {
                    status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
                } else {
                    status = .unknown
                }
                
                switch status {
                case .unknown:
                    startPlayerBuffering()
                case .readyToPlay:
                    bufferState = .readyToPlay
                case .failed:
                    state = .error
                    collectPlayerErrorLogEvent()
                    stopPlayerBuffering()
                    delegate?.jhPlayer(self, playerFailed: error)
                    displayView.playFailed(error)
                default:
                    break
                }
                
            } else if keyPath == #keyPath(AVPlayerItem.playbackBufferEmpty){
                
                if let playbackBufferEmpty = change?[.newKey] as? Bool {
                    if playbackBufferEmpty {
                        startPlayerBuffering()
                    }
                }
            } else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
                // 计算缓冲
                
                let loadedTimeRanges = player?.currentItem?.loadedTimeRanges
                if let bufferTimeRange = loadedTimeRanges?.first?.timeRangeValue {
                    let star = bufferTimeRange.start.seconds         // The start time of the time range.
                    let duration = bufferTimeRange.duration.seconds  // The duration of the time range.
                    let bufferTime = star + duration
                    
                    if let itemDuration = playerItem?.duration.seconds {
                        delegate?.jhPlayer(self, bufferedDidChange: bufferTime, totalDuration: itemDuration)
                        displayView.bufferedDidChange(bufferTime, totalDuration: itemDuration)
                        totalDuration = itemDuration
                        if itemDuration == bufferTime {
                            bufferState = .bufferFinished
                        }
                        
                    }
                    if let currentTime = playerItem?.currentTime().seconds{
                        if (bufferTime - currentTime) >= bufferInterval && state != .paused {
                            play()
                        }
                        
                        if (bufferTime - currentTime) < bufferInterval {
                            bufferState = .buffering
                            buffering = true
                        } else {
                            buffering = false
                            bufferState = .readyToPlay
                        }
                    }
                    
                } else {
                    play()
                }
            }
            
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
