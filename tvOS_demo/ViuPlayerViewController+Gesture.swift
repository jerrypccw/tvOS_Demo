//
//  ViuPlayerViewController+Gesture.swift
//  tvOS_demo
//
//  Created by TerryChe on 2019/12/4.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

//extension ViuPlayerViewController: UIGestureRecognizerDelegate {
//    
//    func setupGestureRecognizer() {
//        
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
//        swipeUp.direction = .up
//        // 设置为YES，以防止视图处理可能被识别为该手势的任何触摸或按下
//        //        swipeUp.delaysTouchesBegan = true
//        view.addGestureRecognizer(swipeUp)
//        
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
//        swipeDown.direction = .down
//        // 设置为YES，以防止视图处理可能被识别为该手势的任何触摸或按下
//        //        swipeDown.delaysTouchesBegan = true
//        view.addGestureRecognizer(swipeDown)
//        
//        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(onPlayPauseTap(tap:)))
//        playPauseTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
//        view.addGestureRecognizer(playPauseTap)
//        
//        //        let selectTap = UITapGestureRecognizer(target: self, action: #selector(onSelectTap(tap:)))
//        //        selectTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
//        //        selectTap.delaysTouchesBegan = true
//        //        view.addGestureRecognizer(selectTap)
//        
//        //        let upTap = UITapGestureRecognizer(target: self, action: #selector(onUpTap(tap:)))
//        //        upTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.upArrow.rawValue)]
//        //        upTap.delaysTouchesBegan = true
//        //        upTap.delaysTouchesEnded = true
//        //        view.addGestureRecognizer(upTap)
//        //
//        //        let downTap = UITapGestureRecognizer(target: self, action: #selector(onDownTap(tap:)))
//        //        downTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.downArrow.rawValue)]
//        //        downTap.delaysTouchesBegan = true
//        //        downTap.delaysTouchesEnded = true
//        //        view.addGestureRecognizer(downTap)
//        //
//        //        let leftTap = UITapGestureRecognizer(target: self, action: #selector(onLeftTap(tap:)))
//        //        leftTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.leftArrow.rawValue)]
//        //        leftTap.delaysTouchesBegan = true
//        //        leftTap.delaysTouchesEnded = true
//        //        view.addGestureRecognizer(leftTap)
//        //
//        //        let rightTap = UITapGestureRecognizer(target: self, action: #selector(onRightTap(tap:)))
//        //        rightTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.rightArrow.rawValue)]
//        //        rightTap.delaysTouchesBegan = true
//        //        rightTap.delaysTouchesEnded = true
//        //        view.addGestureRecognizer(rightTap)
//        
//        // 继承UIGestureRecognizer 重写该手势的touch事件
//        let viuGesture = ViuRemoteGestureRecognizer(target: self, action: #selector(touchLocationDidChange(_:)))
//        viuGesture.delegate = self
//        view.addGestureRecognizer(viuGesture)        
//    }
//    
//    // 必须同时支持多个手势
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}
//
//// MARK: Event For UIGestureRecognizer
//extension ViuPlayerViewController {
//    
//    @objc func touchLocationDidChange(_ gesture: ViuRemoteGestureRecognizer) {
//        
//        // tabbar出现后不处理
//        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
//        
//        if gesture.state == .ended {
//            viuPlayer.displayView.setupTimer()
//            viuPlayer.displayView.viuProgressView.hiddenFastForwordAndBack()
//            
//        } else if gesture.state == .began {
//            ViuGestureSetupTimer()
//        }
//        
//        // 进度条出现才处理
//        if viuPlayer.displayView.isDisplayControl {
//            print("gesture.touchesMovedX -- \(gesture.touchesMovedX)")
//            viuPlayer.displayView.viuProgressView.setPorgressLineByUser(offset: gesture.touchesMovedX)
//        }
//        
//        switch viuPlayer.state {
//        case .playing:
//            viuPlayer.displayView.displayControlView(false)
//            break
//        case .paused:
//            if viuPlayer.displayView.isDisplayControl {
//                print("gesture.touchesMovedX -- \(gesture.touchesMovedX)")
//                viuPlayer.displayView.viuProgressView.setPorgressLineByUser(offset: gesture.touchesMovedX)
//            }
//            break
//        default:
//            break
//        }
//        
//    
//        // 左右轻触
//        switch gesture.touchLocation {
//        case .left:
//            touchLocationDidChangeLeft(gesture)
//            break
//        case .right:
//            touchLocationDidChangeRight(gesture)
//            break
//        default:
//            touchLocationDidChangeUnknow(gesture)
//            break
//        }
//    }
//    
//    private func touchLocationDidChangeLeft(_ gesture: ViuRemoteGestureRecognizer) {
//        
//        if viuPlayer.state == .playing {
//            viuPlayer.displayView.viuProgressView.showBackLabel()
//        }
//
//        
//        switch viuPlayer.state {
//        case .playing:
//            viuPlayer.displayView.viuProgressView.showBackLabel()
//            break
//        case .paused:
//            viuPlayer.displayView.viuProgressView.hiddenFastForwordAndBack()
//            break
//        default:
//            break
//        }
//        
//        if gesture.isClick && gesture.state == .ended {
//
//            var duration = viuPlayer.currentDuration
//            if duration < 10.0 {
//                duration = 0.0
//            } else {
//                duration = duration - 10.0
//            }
//            viuPlayer.seekTime(duration)
//        }
//    }
//    
//    private func touchLocationDidChangeRight(_ gesture: ViuRemoteGestureRecognizer) {
//        
//        if viuPlayer.state == .playing {
//            viuPlayer.displayView.viuProgressView.showFastForword()
//        }
//        
//        switch viuPlayer.state {
//        case .playing:
//            viuPlayer.displayView.viuProgressView.showFastForword()
//            break
//        case .paused:
//            viuPlayer.displayView.viuProgressView.hiddenFastForwordAndBack()
//            break
//        default:
//            break
//        }
//        
//        
//        if gesture.isClick && gesture.state == .ended {
//            print("isClick right \(viuPlayer.currentDuration)")
//            let duration = viuPlayer.currentDuration + 10.0
//            viuPlayer.seekTime(duration)
//        }
//    }
//    
//    private func touchLocationDidChangeUnknow(_ gesture: ViuRemoteGestureRecognizer) {
//        viuPlayer.displayView.viuProgressView.hiddenFastForwordAndBack()
//        if gesture.isClick && gesture.state == .ended {
//            playPauseAction()
//        }
//    }
//    
//    private func ViuGestureSetupTimer() {
//        bagenTimer.invalidate()
//        bagenTimer = Timer.viuPlayer_scheduledTimerWithTimeInterval(bagenTimerDuration, block: { [weak self] in
//            guard let strongSelf = self else { return }
//            if strongSelf.viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
//            strongSelf.viuPlayer.displayView.displayControlView(true)
//            }, repeats: false)
//    }
//    
//    
//    @objc func onSwipeAction(swipe: UISwipeGestureRecognizer) {
//        
//        switch swipe.direction {
//        case .down:
//            if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == false {
//                viuPlayer.displayView.showTabbar()
//            }
//            break
//        case .up:
//            if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
//                viuPlayer.displayView.hiddenTabbar()
//            }
//            break
//        default:
//            break
//        }
//    }
//    
//    @objc func onPlayPauseTap(tap: UITapGestureRecognizer) {
//        playPauseAction()
//    }
//    
//    //    @objc func onSelectTap(tap: UITapGestureRecognizer) {
//    //        playPauseAction()
//    //    }
//    
//    //    @objc func onUpTap(tap: UITapGestureRecognizer) {
//    //
//    //        print("onUpTap")
//    //    }
//    //
//    //    @objc func onDownTap(tap: UITapGestureRecognizer) {
//    //
//    //        print("onDownTap")
//    //    }
//    //
//    //    @objc func onLeftTap(tap: UITapGestureRecognizer) {
//    //
//    //        print("onLeftTap")
//    //    }
//    //
//    //    @objc func onRightTap(tap: UITapGestureRecognizer) {
//    //
//    //        print("onRightTap")
//    //    }
//    
//    
//    private func playPauseAction() {
//        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
//            // 如果Tabber显示，就隐藏
//            viuPlayer.displayView.hiddenTabbar()
//        } else {
//            switch viuPlayer.state {
//            case .playing:
//                viuPlayer.pause()
//                viuPlayer.displayView.displayControlView(true)
//                break
//            case .paused:
//                // 跳转对应的时间播放
//                let seekTime = viuPlayer.displayView.viuProgressView.seekTime
//                if seekTime == viuPlayer.currentDuration {
//                    viuPlayer.play()
//                } else {
//                    viuPlayer.seekTime(seekTime) { [weak self] (finished) in
//                        guard let strongSelf = self else { return }
//                        if finished {
//                            strongSelf.viuPlayer.displayView.setupTimer()
//                        }
//                    }
//                }
//                break
//            default:
//                break
//            }
//        }
//    }
//}
