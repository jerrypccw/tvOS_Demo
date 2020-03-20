//
//  ViuPlayerViewController.swift
//  ViuPlayer
//
//  Created by TerryChe on 2020/3/19.
//  Copyright © 2020 TerryChe. All rights reserved.
//

import AVKit

open class ViuPlayerViewController: UIViewController {

    // 最顶层View，包括：InfoVC 和 Playback
    private let topView = ViuPlayerTopView()
    // 手势
    private let playbackGestureManager = ViuPlaybackGestureManager()
    
    // 中间层View，包括字幕 和 自定义
    private let containerView = ViuPlayerContainerView()
    
    // 播放器
    private let playerView = ViuPlayer()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        playerView.frame = view.frame
        view.addSubview(playerView)
        
        containerView.frame = view.frame
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        
        topView.frame = view.frame
        topView.backgroundColor = .clear
        view.addSubview(topView)
    }
    
    deinit {
        print("ViuPlayerViewController deinit")
    }
    
    open func setupPlayerURL(_ url: URL) {
        playerView.setupPlayer(URL: url)
    }
    
    open func setupPlayback() {
        setupGestureRecognizer()
    }
}

extension ViuPlayerViewController: ViuPlaybackGestureManagerDelegate {
    private func setupGestureRecognizer() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
        swipeDown.direction = .down
        swipeDown.delegate = playbackGestureManager
        view.addGestureRecognizer(swipeDown)
        
        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(onPlayPauseTap(tap:)))
        playPauseTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        playPauseTap.delegate = playbackGestureManager
        view.addGestureRecognizer(playPauseTap)
        
        playbackGestureManager.addGesture(view)
        playbackGestureManager.delegate = self
    }
    
    @objc public func onSwipeAction(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction {
        case .down:
            print("显示 InfoVC")
        default:
            break
        }
    }
    
    @objc public func onPlayPauseTap(tap: UITapGestureRecognizer) {
        playerView.playPauseAction()
    }
    
    public func onTouch(_ gesture: ViuPlaybackTouchGestureRecognizer) {
        // 信息栏显示，就不执行
//        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
        // 快进过程中忽略Touch
        if let rate = playerView.player?.rate, rate > 1 || rate < 0 { return }

        if gesture.state == .began || gesture.state == .changed {
            topView.displayControlView(true)
            
            if playerView.state == .paused {
                // 如果是暂停，就可以滑动
                topView.viuProgressView.setPorgressLineByUser(offset: gesture.touchesMovedX)
            } else {
                // 播放中就快进/快退
                switch gesture.remoteTouchLocation {
                case .left:
                    topView.viuProgressView.showLeftActionIndicator(isLongPress: false)
                case .right:
                    topView.viuProgressView.showRightActionIndicator(isLongPress: false)
                case .center:
                    topView.viuProgressView.hiddenFastForwordAndRewind()
                }
            }
        } else {
            topView.viuProgressView.hiddenFastForwordAndRewind()
            topView.setupTimer()
        }
    }
    
    public func onTap(_ gesture: UITapGestureRecognizer) {
        // 信息栏显示，就不执行
//        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
        
        topView.displayControlView(true)
        
        if playerView.state == .paused {
            // 滑动跳特定时间
            playerView.seekTime(topView.viuProgressView.seekTime)
        } else if gesture.numberOfTapsRequired == 1 && gesture.state == .ended {
            switch gesture.remoteTouchLocation {
            case .left:// 快退10秒
                playerView.seekTime(offect: -10)
            case .right:// 快进10秒
                playerView.seekTime(offect: 10)
            case .center:
                playerView.playPauseAction()
            }
        }
    }
    
    public func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        // 信息栏显示，就不执行
//        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
        
        // 视频暂停时，就不执行
        if playerView.state == .paused { return }
        
        topView.displayControlView(true)
        
        if (gesture.state == .began || gesture.state == .changed) && gesture.remoteTouchLocation != .center {
            switch gesture.remoteTouchLocation {
            case .left:// 快退
                topView.viuProgressView.showLeftActionIndicator(isLongPress: true)
                playerView.player?.rate = -4
            case .right:// 快进
                topView.viuProgressView.showRightActionIndicator(isLongPress: true)
                playerView.player?.rate = 4
            default:
                break
            }
        } else {
            playerView.player?.rate = 1
        }
    }
}

