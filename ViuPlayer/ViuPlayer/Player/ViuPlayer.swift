//
//  ViuPlayer.swift
//  ViuPlayer
//
//  Created by TerryChe on 2020/3/19.
//  Copyright © 2020 TerryChe. All rights reserved.
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
public enum ViuPlayerBufferState: Int {
    case none           // default
    case readyToPlay    // 准备播放
    case buffering      // 正在缓冲
    case stop           // 停止
    case bufferFinished // 缓冲完成
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

//public enum ViuVideoGravityMode: Int {
//    case resize
//    case resizeAspect      // default
//    case resizeAspectFill
//}

public protocol ViuPlayerDelegate: NSObjectProtocol {
    // play state
    func viuPlayer(_ player: ViuPlayer, stateDidChange state: ViuPlayerState)
    // playe Duration
    func viuPlayer(_ player: ViuPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval)
    // buffer state
    func viuPlayer(_ player: ViuPlayer, bufferStateDidChange state: ViuPlayerBufferState)
    // buffered Duration
    func viuPlayer(_ player: ViuPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval)
    // play error
    func viuPlayer(_ player: ViuPlayer, playerFailed error: ViuPlayerError)
}

// MARK: - delegate methods optional

public extension ViuPlayerDelegate {
    func viuPlayer(_ player: ViuPlayer, stateDidChange state: ViuPlayerState) {}
    func viuPlayer(_ player: ViuPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {}
    func viuPlayer(_ player: ViuPlayer, bufferStateDidChange state: ViuPlayerBufferState) {}
    func viuPlayer(_ player: ViuPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {}
    func viuPlayer(_ player: ViuPlayer, playerFailed error: ViuPlayerError) {}
}

open class ViuPlayer: UIView {
    
    //
    weak var delegate : ViuPlayerDelegate?
    //
//    var gravityMode : ViuVideoGravityMode = .resizeAspect
    var backgroundMode : ViuPlayerBackgroundMode = .autoPlayAndPaused
    var bufferInterval : TimeInterval = 2.0
    //
    private var timeObserver: Any?
    //
    open fileprivate(set) var mediaFormat : ViuPlayerMediaFormat?
    open fileprivate(set) var totalDuration : TimeInterval = 0.0
    open fileprivate(set) var currentDuration : TimeInterval = 0.0
    open fileprivate(set) var buffering : Bool = false
//    open fileprivate(set) var playerAsset : AVURLAsset?
    open fileprivate(set) var contentURL : URL?
    open fileprivate(set) var error = ViuPlayerError()
//    fileprivate var resourceLoaderManager = ViuPlayerResourceLoaderManager()
    fileprivate var seeking : Bool = false
    fileprivate var isUserPaused : Bool = false
    
    var imageGenerator: AVAssetImageGenerator?
    
    var playerLayer : AVPlayerLayer?

    //
    open fileprivate(set) var player : AVPlayer? {
        willSet{
            removePlayerObservers()
            
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
        }
        didSet {
            addPlayerObservers()
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = frame
            playerLayer?.videoGravity = .resizeAspect
            layer.addSublayer(playerLayer!)
        }
    }
    
    open fileprivate(set) var playerItem : AVPlayerItem? {
        willSet {
            removePlayerItemObservers()
            removePlayerNotifations()
        }
        didSet {
            guard let item = playerItem else { return }
            addPlayerItemObservers()
            addPlayerNotifications()
            player = AVPlayer(playerItem: item)
            totalDuration = item.duration.seconds
        }
    }

    open var state: ViuPlayerState = .none {
        didSet {
            if state != oldValue {
                delegate?.viuPlayer(self, stateDidChange: state)
            }
        }
    }

    open var bufferState: ViuPlayerBufferState = .none {
        didSet {
            if bufferState != oldValue {
                delegate?.viuPlayer(self, bufferStateDidChange: bufferState)
            }
        }
    }
    
    deinit {
        removePlayerNotifations()
        cleanPlayer()
        NotificationCenter.default.removeObserver(self)
    }
    
    public func setupPlayer(URL: URL) {
        mediaFormat = ViuPlayerUtils.decoderVideoFormat(URL)
        contentURL = URL

        configurationPlayer(contentURL!)
    }

    internal func configurationPlayer(_ url: URL) {
        if url.absoluteString.hasPrefix("file:///") {
            let keys = ["tracks", "playable"]
            playerItem = AVPlayerItem(asset: AVURLAsset(url: url), automaticallyLoadedAssetKeys: keys)
        } else {
            playerItem = AVPlayerItem(asset: AVURLAsset(url: url))
        }
        play()
    }
    
    // time KVO
    internal func addPlayerObservers() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] _ in
            guard let strongSelf = self,
                let player = strongSelf.player,
                let playerItem = player.currentItem else { return }
            
            let currentTime = player.currentTime().seconds
            strongSelf.currentDuration = currentTime
            strongSelf.delegate?.viuPlayer(strongSelf, playerDurationDidChange: currentTime, totalDuration: playerItem.duration.seconds)
        })
    }

    internal func removePlayerObservers() {
        player?.removeTimeObserver(timeObserver!)
    }
}

// MARK: - public

extension ViuPlayer {
    open func playPauseAction() {
        switch state {
        case .playing:
            isUserPaused = true
            pause()
            break
        case .paused:
            isUserPaused = false
            play()
            break
        default:
            isUserPaused = false
            break
        }
    }
    
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
        playerItem?.cancelPendingSeeks()
        playerItem = nil
        
        player?.pause()
        player?.cancelPendingPrerolls()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    open func play() {
        player?.play()
        state = .playing
    }

    open func pause() {
        player?.pause()
        state = .paused
    }

    open func seekTime(offect: Double, autoPlay: Bool = true) {
        let newDuration = max(currentDuration + offect, 0)
        seekTime(newDuration, autoPlay: autoPlay)
    }
    
    open func seekTime(_ time: TimeInterval, autoPlay: Bool = true) {
        seekTime(time, autoPlay: autoPlay, completion: nil)
    }

    open func seekTime(_ time: TimeInterval, autoPlay: Bool = true, completion: ((Bool) -> Swift.Void)?) {
        if time.isNaN || playerItem?.status != .readyToPlay || seeking {
            if completion != nil {
                completion!(false)
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.seeking = true
            strongSelf.startPlayerBuffering()
            strongSelf.playerItem?.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: Int32(NSEC_PER_SEC)), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { finished in
                DispatchQueue.main.async {
                    strongSelf.stopPlayerBuffering()
                    if autoPlay {
                        strongSelf.play()
                    }
                    if completion != nil {
                        completion!(finished)
                    }
                    strongSelf.seeking = false
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
}

// MARK: - Notifation Selector & KVO

private var playerItemContext = 0

extension ViuPlayer {
    internal func addPlayerItemObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp), options: options, context: &playerItemContext)
        
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
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp))
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
            
            switch keyPath {
                
            case #keyPath(AVPlayerItem.status):
                observePlayerStatus(key: keyPath, change: change)
                
            case #keyPath(AVPlayerItem.playbackBufferEmpty):
                if let playbackBufferEmpty = change?[.newKey] as? Bool {
                    if playbackBufferEmpty {
                        startPlayerBuffering()
                    }
                }
            case #keyPath(AVPlayerItem.playbackLikelyToKeepUp):
                stopPlayerBuffering()

            case #keyPath(AVPlayerItem.loadedTimeRanges):
                observeLoadTimeRangs()
                
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func observePlayerStatus(key: String?, change: [NSKeyValueChangeKey: Any]?) {
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
            delegate?.viuPlayer(self, playerFailed: error)
        default:
            break
        }
    }
    
    private func observeLoadTimeRangs() {
        guard let playerItem = player?.currentItem else { return }
        
        let loadedTimeRanges = playerItem.loadedTimeRanges
        if let bufferTimeRange = loadedTimeRanges.first?.timeRangeValue {
            let star = bufferTimeRange.start.seconds // The start time of the time range.
            let duration = bufferTimeRange.duration.seconds // The duration of the time range.
            let bufferTime = star + duration
            
            delegate?.viuPlayer(self, bufferedDidChange: bufferTime, totalDuration: totalDuration)
            
            if totalDuration == bufferTime {
                bufferState = .bufferFinished
            }
            
            let currentTime = playerItem.currentTime().seconds
            if (bufferTime - currentTime) < bufferInterval {
                bufferState = .buffering
                buffering = true
            } else {
                buffering = false
                bufferState = .readyToPlay
            }
            
        }
    }
}


//    // 获取元数据的字幕信息
//    internal func loadMediaLegible() {
//        let mc = AVMediaCharacteristic.legible
//        let mediaGourp = playerAsset!.mediaSelectionGroup(forMediaCharacteristic: mc)
//
//        guard let gourp = mediaGourp else {
//            return
//        }
//
//        for option in gourp.options {
//            if option.displayName == "English" {
//                // 显示选中的字幕
//                playerItem?.select(option, in: gourp)
//            }
//        }
//    }
//
//    // 获取元数据的音轨信息
//    internal func loadMediaAudible() {
//        let mc = AVMediaCharacteristic.audible
//        let mediaGourp = playerAsset!.mediaSelectionGroup(forMediaCharacteristic: mc)
//
//        guard let gourp = mediaGourp else {
//            return
//        }
//
//        for option in gourp.options {
//            print("loadMediaAudible \(option.displayName)")
//        }
//    }
//
//    internal func generateThumbnails() {
//        guard let asset = playerAsset else {
//            print("generateThumbnails asset error")
//            return
//        }
//
//        imageGenerator = AVAssetImageGenerator(asset: asset)
//        imageGenerator?.maximumSize = CGSize(width: 200.0, height: 0.0)
//
//        let duration: CMTime = asset.duration
//        var times: [NSValue] = []
//        let increment: CMTimeValue = duration.value / 20
//        var currentValue: CMTimeValue = CMTimeValue(2 * duration.timescale)
//        while currentValue <= duration.value {
//            let time: CMTime = CMTime(value: currentValue, timescale: duration.timescale)
//            times.append(NSValue(time: time))
//            currentValue += increment
//        }
//
//        var imageCount = times.count
//        var images: [ViuThumbnail] = []
//
//        let handler: AVAssetImageGeneratorCompletionHandler = {
//            _, imageRef, actualTime, result, _ in
//
//            if result == .succeeded {
//                guard let cgImage = imageRef else {
//                    return
//                }
//                let image: UIImage = UIImage(cgImage: cgImage)
//                let thumbnail: ViuThumbnail = ViuThumbnail()
//                thumbnail.image = image
//                thumbnail.time = actualTime
//                images.append(thumbnail)
//            } else {
//                print("generateThumbnails result error")
//            }
//
//            if --imageCount == 0 {
//                DispatchQueue.main.async {
//                    let name = "ViuThumbnailsGeneratedNotification"
//                    let nc: NotificationCenter = NotificationCenter.default
//                    nc.post(name: NSNotification.Name(rawValue: name), object: images)
//                }
//            }
//        }
//        imageGenerator?.generateCGImagesAsynchronously(forTimes: times, completionHandler: handler)
//    }
