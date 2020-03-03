//
//  ViuPlayerViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/28.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!

let m3u8URL = URL(string: "")!

class ViuPlayerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var bagenTimer: Timer = {
        let time = Timer()
        return time
    }()
    
    let bagenTimerDuration: TimeInterval = 0.1 /// default 5.0
    
    var viuPlayer: ViuPlayer = {
        let playerView = ViuPlayerSubtitlesView()
        let player = ViuPlayer(playerView: playerView)
        return player
    }()
    
    deinit {
        print("ViuPlayerViewController deinit")
    }
    
    // 使用PUSH转跳需要添加一下代码，不然会丢失焦点
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viuPlayer.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        view.addSubview(viuPlayer.displayView)
        
        viuPlayer.backgroundMode = .proceed
        viuPlayer.delegate = self
        
        viuPlayer.displayView.translatesAutoresizingMaskIntoConstraints = false
        viuPlayer.displayView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        viuPlayer.displayView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viuPlayer.displayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viuPlayer.displayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        setPlayerData()
        setupGestureRecognizer()
    }
    
    
    private func setPlayerData() {
        viuPlayer.replaceVideo(url)
        viuPlayer.play()
    }
}

// MARK: viuPlayerDelegate
extension ViuPlayerViewController: ViuPlayerDelegate {
    func viuPlayer(_ player: ViuPlayer, playerFailed error: ViuPlayerError) {
        print("ViuPlayerViewController \(error)")
    }
    
    func viuPlayer(_ player: ViuPlayer, stateDidChange state: ViuPlayerState) {
        switch state {
        case .playFinished:
            navigationController?.popViewController(animated: true)
        case .paused:
            viuPlayer.displayView.displayShadowView()
            viuPlayer.displayView.displayControlView(true)
            viuPlayer.displayView.viuProgressView.showThumbnail(duration: 0)
        case .playing:
            viuPlayer.displayView.hiddenShadowView()
            viuPlayer.displayView.setupTimer()
            viuPlayer.displayView.viuProgressView.hiddenThumbnail()
        default:
            break
        }
    }
    
    func viuPlayer(_ player: ViuPlayer, bufferStateDidChange state: ViuPlayerBufferstate) {
        print("buffer State", state)
        
        switch state {
        case .buffering:
            viuPlayer.displayView.viuProgressView.hiddenFastForwordAndRewind()
            viuPlayer.displayView.viuProgressView.bufferingIndicator.startAnimating()
        case .readyToPlay:
            viuPlayer.displayView.viuProgressView.hiddenFastForwordAndRewind()
            viuPlayer.displayView.viuProgressView.bufferingIndicator.stopAnimating()
        default:
            break
        }
    }
    
    func viuPlayer(_ player: ViuPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
//        print("bufferedDidChange \(bufferedDuration)")
    }
    
    func viuPlayer(_ player: ViuPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {
//        print("currentDuration \(currentDuration)")
    }
}

extension ViuPlayerViewController {
    
    func setupGestureRecognizer() {
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
        swipeUp.direction = .up
        // 设置为YES，以防止视图处理可能被识别为该手势的任何触摸或按下
        //        swipeDown.delaysTouchesBegan = true
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(onPlayPauseTap(tap:)))
        playPauseTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        view.addGestureRecognizer(playPauseTap)
        
        // 继承UIGestureRecognizer 重写该手势的touch事件
        let viuGesture = ViuRemoteGestureRecognizer(target: self, action: #selector(touchLocationDidChange(_:)))
        viuGesture.delegate = self
        view.addGestureRecognizer(viuGesture)
    }
    
    // 必须同时支持多个手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func touchLocationDidChange(_ gesture: ViuRemoteGestureRecognizer) {
        
        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
        
        if gesture.state == .began || gesture.state == .changed {
            viuPlayer.displayView.displayControlView(true)
        }
        
        // 进度条出现才处理
        if viuPlayer.displayView.isDisplayControl {
//            print("gesture.touchesMovedX -- \(gesture.touchesMovedX)")
            viuPlayer.displayView.viuProgressView.setPorgressLineByUser(offset: gesture.touchesMovedX)
            return
        }
        
        switch gesture.touchLocation {
        case .left:
            viuPlayer.displayView.viuProgressView.showLeftActionIndicator()
            if gesture.isClick && gesture.state == .ended {
                var duration = viuPlayer.currentDuration
                if duration < 10.0 {
                    duration = 0.0
                } else {
                    duration = duration - 10.0
                }
                viuPlayer.seekTime(duration)
            }
            
            if gesture.isLongPress && gesture.state == .changed {
                print(gesture.isLongPress)
            }
            
        case .right:
            viuPlayer.displayView.viuProgressView.showRightActionIndicator()
            if gesture.isClick && gesture.state == .ended {
                let duration = viuPlayer.currentDuration + 10.0
                viuPlayer.seekTime(duration)
            }
            if gesture.isLongPress && gesture.state == .changed {
                viuPlayer.displayView.viuProgressView.rightActionIndicator.image = UIImage.init(named: "forward")
            }
            
        case .unknown:
            viuPlayer.displayView.viuProgressView.hiddenFastForwordAndRewind()
            viuPlayer.displayView.setupTimer()
            if gesture.isClick && gesture.state == .ended {
                playPauseAction()
            }
            
        }
        
    }
    
    @objc func onSwipeAction(swipe: UISwipeGestureRecognizer) {
        
        switch swipe.direction {
        case .down:
            if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == false {
                viuPlayer.displayView.showTabbar()
            }
            break
        case .up:
            if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
                viuPlayer.displayView.hiddenTabbar()
            }
            break
        default:
            break
        }
    }
    
    @objc func onPlayPauseTap(tap: UITapGestureRecognizer) {
        playPauseAction()
    }
    
    private func playPauseAction() {
        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
            // 如果Tabber显示，就隐藏
            viuPlayer.displayView.hiddenTabbar()
        } else {
            switch viuPlayer.state {
            case .playing:
                viuPlayer.pause()
                break
            case .paused:
                viuPlayer.play()
                break
            default:
                break
            }
        }
    }
}
