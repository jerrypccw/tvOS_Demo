//
//  JHPlayer.swift
//  JHPlayerView
//
//  Created by Jerry He on 2019/2/10.
//  Copyright © 2019年 jerry. All rights reserved.
//

import AVFoundation
import UIKit

/// 播放状态
///
/// - none//default:
/// - playing//播放:
/// - paused//暂停:
/// - playFinished//播放完成:
/// - error//异常:
public enum ViuPlayerState: Int {
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
public enum ViuPlayerBufferstate: Int {
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
public enum ViuVideoGravityMode: Int {
    case resize            // 拉伸匹配范围
    case resizeAspect      // default
    case resizeAspectFill  // 通过缩放填满层的范围区域
}

/// 后台播放
///
/// - suspend//禁止:
/// - autoPlayAndPaused//自动播放和暂停:
/// - proceed//继续进行:
public enum ViuPlayerBackgroundMode: Int {
    case suspend                // 禁止
    case autoPlayAndPaused      // 自动播放和暂停
    case proceed                // 继续进行
}

public protocol ViuPlayerDelegate: NSObjectProtocol {
    // play state
    func viuPlayer(_ player: ViuPlayer, stateDidChange state: ViuPlayerState)
    // playe Duration
    func viuPlayer(_ player: ViuPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval)
    // buffer state
    func viuPlayer(_ player: ViuPlayer, bufferStateDidChange state: ViuPlayerBufferstate)
    // buffered Duration
    func viuPlayer(_ player: ViuPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval)
    // play error
    func viuPlayer(_ player: ViuPlayer, playerFailed error: ViuPlayerError)
}

// MARK: - delegate methods optional

public extension ViuPlayerDelegate {
    func viuPlayer(_ player: ViuPlayer, stateDidChange state: ViuPlayerState) {}
    func viuPlayer(_ player: ViuPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {}
    func viuPlayer(_ player: ViuPlayer, bufferStateDidChange state: ViuPlayerBufferstate) {}
    func viuPlayer(_ player: ViuPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {}
    func viuPlayer(_ player: ViuPlayer, playerFailed error: ViuPlayerError) {}
}


open class ViuPlayer: NSObject {
    
    //
    weak var delegate : ViuPlayerDelegate?
    //
    var displayView : ViuPlayerView
    var gravityMode : ViuVideoGravityMode = .resizeAspect
    var backgroundMode : ViuPlayerBackgroundMode = .autoPlayAndPaused
    var bufferInterval : TimeInterval = 2.0
    //
    private var timeObserver: Any?
    //
    open fileprivate(set) var mediaFormat : ViuPlayerMediaFormat
    open fileprivate(set) var totalDuration : TimeInterval = 0.0
    open fileprivate(set) var currentDuration : TimeInterval = 0.0
    open fileprivate(set) var buffering : Bool = false
    open fileprivate(set) var playerAsset : AVURLAsset?
    open fileprivate(set) var contentURL : URL?
    open fileprivate(set) var error : ViuPlayerError
    
    fileprivate var seeking : Bool = false
    
    var imageGenerator: AVAssetImageGenerator?
    
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

    open var state: ViuPlayerState = .none {
        didSet {
            if state != oldValue {
                self.displayView.playStateDidChange(state)
                self.delegate?.viuPlayer(self, stateDidChange: state)
            }
        }
    }

    open var bufferState: ViuPlayerBufferstate = .none {
        didSet {
            if bufferState != oldValue {
                displayView.bufferStateDidChange(bufferState)
                delegate?.viuPlayer(self, bufferStateDidChange: bufferState)
            }
        }
    }

    // MARK: - life cycle

    public init(URL: URL?, playerView: ViuPlayerView?) {
        mediaFormat = ViuPlayerUtils.decoderVideoFormat(URL)
        contentURL = URL
        error = ViuPlayerError()
        if let view = playerView {
            displayView = view
        } else {
            displayView = ViuPlayerView()
        }
        super.init()
        if contentURL != nil {
            configurationPlayer(contentURL!)
        }
    }

    public convenience init(URL: URL) {
        self.init(URL: URL, playerView: nil)
    }

    public convenience init(playerView: ViuPlayerView) {
        self.init(URL: nil, playerView: playerView)
    }

    public convenience override init() {
        self.init(URL: nil, playerView: nil)
    }

    deinit {
        removePlayerNotifations()
        // 不能在这里添加删除订阅，按home键回系统主界面时会导致崩溃；
//        removePlayerItemObservers()
        cleanPlayer()        
        displayView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }

    internal func configurationPlayer(_ URL: URL) {
        displayView.setViuPlayer(viuPlayer: self)
        playerAsset = AVURLAsset(url: URL, options: .none)
        if URL.absoluteString.hasPrefix("file:///") {
            let keys = ["tracks", "playable"]
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
        timeObserver = player?.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] _ in
            guard let strongSelf = self else { return }
            if let currentTime = strongSelf.player?.currentTime().seconds,
                let totalDuration = strongSelf.player?.currentItem?.duration.seconds {
                strongSelf.currentDuration = currentTime
                strongSelf.delegate?.viuPlayer(strongSelf, playerDurationDidChange: currentTime, totalDuration: totalDuration)
                strongSelf.displayView.playerDurationDidChange(currentTime, totalDuration: totalDuration)
            }
        })
    }

    internal func removePlayerObservers() {
        player?.removeTimeObserver(timeObserver!)
    }
}

// MARK: - public

extension ViuPlayer {
    open func replaceVideo(_ URL: URL) {
        reloadPlayer()
        mediaFormat = ViuPlayerUtils.decoderVideoFormat(URL)
        contentURL = URL
        configurationPlayer(URL)
    }

    open func reloadPlayer() {
        seeking = false
        totalDuration = 0.0
        currentDuration = 0.0
        error = ViuPlayerError()
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

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.seeking = true
            strongSelf.startPlayerBuffering()
            strongSelf.playerItem?.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: Int32(NSEC_PER_SEC)), completionHandler: { finished in
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

// MARK: - private

extension ViuPlayer {
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

    // 获取元数据的字幕信息
    internal func loadMediaLegible() {
        let mc = AVMediaCharacteristic.legible
        let mediaGourp = playerAsset!.mediaSelectionGroup(forMediaCharacteristic: mc)

        guard let gourp = mediaGourp else {
            return
        }

        for option in gourp.options {
            if option.displayName == "English" {
                // 显示选中的字幕
                playerItem?.select(option, in: gourp)
            }
        }
    }
    
    // 获取元数据的音轨信息
    internal func loadMediaAudible() {
        let mc = AVMediaCharacteristic.audible
        let mediaGourp = playerAsset!.mediaSelectionGroup(forMediaCharacteristic: mc)

        guard let gourp = mediaGourp else {
            return
        }

        for option in gourp.options {
            print("loadMediaAudible \(option.displayName)")
        }
    }

    internal func generateThumbnails() {
        guard let asset = playerAsset else {
            print("generateThumbnails asset error")
            return
        }

        imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator?.maximumSize = CGSize(width: 200.0, height: 0.0)

        let duration: CMTime = asset.duration
        var times: [NSValue] = []
        let increment: CMTimeValue = duration.value / 20
        var currentValue: CMTimeValue = CMTimeValue(2 * duration.timescale)
        while currentValue <= duration.value {
            let time: CMTime = CMTime(value: currentValue, timescale: duration.timescale)
            times.append(NSValue(time: time))
            currentValue += increment
        }

        var imageCount = times.count
        var images: [ViuThumbnail] = []

        let handler: AVAssetImageGeneratorCompletionHandler = {
            _, imageRef, actualTime, result, _ in

            if result == .succeeded {
                guard let cgImage = imageRef else {
                    return
                }
                let image: UIImage = UIImage(cgImage: cgImage)
                let thumbnail: ViuThumbnail = ViuThumbnail()
                thumbnail.image = image
                thumbnail.time = actualTime
                images.append(thumbnail)
            } else {
                print("generateThumbnails result error")
            }

            if --imageCount == 0 {
                DispatchQueue.main.async {
                    let name = "ViuThumbnailsGeneratedNotification"
                    let nc: NotificationCenter = NotificationCenter.default
                    nc.post(name: NSNotification.Name(rawValue: name), object: images)
                }
            }
        }
        imageGenerator?.generateCGImagesAsynchronously(forTimes: times, completionHandler: handler)
    }
}

// MARK: - Notifation Selector & KVO

private var playerItemContext = 0

extension ViuPlayer {
    internal func addPlayerItemObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: options, context: &playerItemContext)
    }

    internal func addPlayerNotifications() {
        NotificationCenter.default.addObserver(self, selector: .playerItemDidPlayToEndTime, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationWillEnterForeground, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationDidEnterBackground, name: UIApplication.didEnterBackgroundNotification, object: nil)
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
        if let playerLayer = displayView.playerLayer {
            playerLayer.player = player
        }

        switch backgroundMode {
        case .suspend:
            pause()
        case .autoPlayAndPaused:
            play()
        case .proceed:
            break
        }
    }

    @objc internal func applicationDidEnterBackground(_ notification: Notification) {
        if let playerLayer = displayView.playerLayer {
            playerLayer.player = nil
        }

        switch backgroundMode {
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
    static let playerItemDidPlayToEndTime = #selector(ViuPlayer.playerItemDidPlayToEnd(_:))
    static let applicationWillEnterForeground = #selector(ViuPlayer.applicationWillEnterForeground(_:))
    static let applicationDidEnterBackground = #selector(ViuPlayer.applicationDidEnterBackground(_:))
}

extension ViuPlayer {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playerItemContext {
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
                    // 获取元数据的字幕信息
                    loadMediaLegible()
                    // 获取元数据的音轨信息
                    loadMediaAudible()
                    // 获取视频每帧的图片
                    generateThumbnails()

                case .failed:
                    state = .error
                    collectPlayerErrorLogEvent()
                    stopPlayerBuffering()
                    delegate?.viuPlayer(self, playerFailed: error)
                    displayView.playFailed(error)
                default:
                    break
                }

            } else if keyPath == #keyPath(AVPlayerItem.playbackBufferEmpty) {
                if let playbackBufferEmpty = change?[.newKey] as? Bool {
                    if playbackBufferEmpty {
                        startPlayerBuffering()
                    }
                }
            } else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
                // 计算缓冲

                let loadedTimeRanges = player?.currentItem?.loadedTimeRanges
                if let bufferTimeRange = loadedTimeRanges?.first?.timeRangeValue {
                    let star = bufferTimeRange.start.seconds // The start time of the time range.
                    let duration = bufferTimeRange.duration.seconds // The duration of the time range.
                    let bufferTime = star + duration

                    if let itemDuration = playerItem?.duration.seconds {
                        delegate?.viuPlayer(self, bufferedDidChange: bufferTime, totalDuration: itemDuration)
                        displayView.bufferedDidChange(bufferTime, totalDuration: itemDuration)
                        totalDuration = itemDuration
                        if itemDuration == bufferTime {
                            bufferState = .bufferFinished
                        }
                    }
                    if let currentTime = playerItem?.currentTime().seconds {
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

        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
