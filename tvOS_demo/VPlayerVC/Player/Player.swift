//
//  Player.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/19.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit
import AVFoundation

class Player: AVPlayer {
    
    /// Notification key
    public enum PlayerNotificationInfoKey: String {
        case time = "VIU_PLAYER_TIME"
    }
    
    /// Notification post
    public enum PlayerNotificationName: String {
        case assetLoaded = "VIU_ASSET_ADDED"
        case timeChanged = "VIU_TIME_CHANGED"
        case willPlay = "VIU_PLAYER_STATE_WILL_PLAY"
        case play = "VIU_PLAYER_STATE_PLAY"
        case pause = "VIU_PLAYER_STATE_PAUSE"
        case buffering = "VIU_PLAYER_BUFFERING"
        case endBuffering = "VIU_PLAYER_END_BUFFERING"
        case didEnd = "VIU_PLAYER_END_PLAYING"
        case keepUp = "VIU_PLAYER_KEEPUP"
        case failedToPlayToEndTime = "VIU_PLAYER_FAILDTOPLAYTOENDTIME"
        case timeJumped = "VIU_PLAYER_TIMEJUMPED"
        case stalled = "VIU_PLAYER_STALLED"
        
        public var notification: NSNotification.Name {
            return NSNotification.Name.init(self.rawValue)
        }
    }

    public var handler: PlayerView!
    
    /// Context
    private var playerItemContext = 0
    
    /// bufferTime
    private var bufferInterval: TimeInterval = 2.0
    
    /// bufferTimeTotal
    open fileprivate(set) var totalDuration : TimeInterval = 0.0
    
    /// bufferStatus
    public var isBuffering: Bool = false
    
    /// Play content
    override open func play() {
        NotificationCenter.default.post(name: Player.PlayerNotificationName.play.notification, object: self, userInfo: nil)
        super.play()
    }
    
    /// Pause content
    override open func pause() {
        NotificationCenter.default.post(name: Player.PlayerNotificationName.pause.notification, object: self, userInfo: nil)
        super.pause()
    }
    
    /// change video item
    override open func replaceCurrentItem(with item: AVPlayerItem?) {
        super.replaceCurrentItem(with: item)
        NotificationCenter.default.post(name: Player.PlayerNotificationName.assetLoaded.notification, object: self, userInfo: nil)
        if item != nil {
            currentItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: .new, context: &playerItemContext)
            currentItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp), options: .new, context: &playerItemContext)
            currentItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferFull), options: .new, context: &playerItemContext)
            currentItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: &playerItemContext)
            currentItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: .new, context: &playerItemContext)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemTimeJumped, object: self)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: self)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: self)
    }
}

extension Player {
    
    /// 获取播放的开始时间
    public func startTime() -> CMTime {
        guard let item = currentItem else {
            return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
        
        if item.reversePlaybackEndTime.isValid {
            return item.reversePlaybackEndTime
        }else {
            return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
    }
    
    /// 获取播放的结束时间
    public func endTime() -> CMTime {
        guard let item = currentItem else {
            return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
        
        if item.forwardPlaybackEndTime.isValid {
            return item.forwardPlaybackEndTime
        }else {
            if item.duration.isValid && !item.duration.isIndefinite {
                return item.duration
            }else {
                return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            }
        }
    }
    
    /// Prepare
    public func preparePlayerPlaybackDelegate() {
        
        // 监听播放时间点
        addPeriodicTimeObserver(forInterval: CMTime(seconds: 1,preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                queue: DispatchQueue.main) { (time) in
            NotificationCenter.default.post(name: Player.PlayerNotificationName.timeChanged.notification, object: self, userInfo: [PlayerNotificationInfoKey.time.rawValue: time])
        }
        
        addPlayerItemObservers()
        addPlayerNotifications()
    }
    
    internal func addPlayerItemObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: options, context: &playerItemContext)
        addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: options, context: &playerItemContext)
        addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: options, context: &playerItemContext)
        addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp), options: options, context: &playerItemContext)
        addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferFull), options: options, context: &playerItemContext)
    }
    
    internal func addPlayerNotifications() {
        //
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self,
                                               queue: OperationQueue.main) { (notification) in
            NotificationCenter.default.post(name: Player.PlayerNotificationName.didEnd.notification, object: self, userInfo: nil)
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: self,
                                               queue: OperationQueue.main) { (notification) in
            NotificationCenter.default.post(name: Player.PlayerNotificationName.failedToPlayToEndTime.notification, object: self, userInfo: nil)
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemTimeJumped, object: self,
                                               queue: OperationQueue.main) { (notification) in
            NotificationCenter.default.post(name: Player.PlayerNotificationName.timeJumped.notification, object: self, userInfo: nil)
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled, object: self,
                                               queue: OperationQueue.main) { (notification) in
            NotificationCenter.default.post(name: Player.PlayerNotificationName.stalled.notification, object: self, userInfo: nil)
        }
    }

    
    /// Value observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playerItemContext {
            
            print("player observeValue keyPath = \(String(describing: keyPath))")
            
            switch keyPath {
            case #keyPath(AVPlayerItem.status):
                observePlayerStatus(key: keyPath, change: change)
                break
            case #keyPath(AVPlayerItem.playbackBufferEmpty):
                isBuffering = true
                NotificationCenter.default.post(name: Player.PlayerNotificationName.buffering.notification, object: self, userInfo: nil)
                break
            case #keyPath(AVPlayerItem.playbackLikelyToKeepUp):
                isBuffering = false
                NotificationCenter.default.post(name: Player.PlayerNotificationName.keepUp.notification, object: self, userInfo: nil)
                break
            case #keyPath(AVPlayerItem.playbackBufferFull):
                isBuffering = false
                NotificationCenter.default.post(name: Player.PlayerNotificationName.endBuffering.notification, object: self, userInfo: nil)
                break
            case #keyPath(AVPlayerItem.loadedTimeRanges):
                
                break
            default:
                break
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func observePlayerloadedTimeRanges() {
        
        let loadedTimeRanges = currentItem!.loadedTimeRanges
        if let bufferTimeRange = loadedTimeRanges.first?.timeRangeValue {
            let star = bufferTimeRange.start.seconds
            let duration = bufferTimeRange.duration.seconds
            let bufferTime = star + duration
            let itemDuration = currentItem!.duration.seconds
            let currentTime = currentItem!.currentTime().seconds
            
            totalDuration = itemDuration
            
            if itemDuration == bufferTime {
               
            }
            
            if (bufferTime - currentTime) >= bufferInterval {
                self.play()
            }
            
            if (bufferTime - currentTime) < bufferInterval {
                isBuffering = true
            } else {
                isBuffering = false
            }
                        
        } else {
            self.play()
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
            
            break
        case .readyToPlay:
            
            break
        case .failed:
            
            break
        default:
            break
        }
    }
}

