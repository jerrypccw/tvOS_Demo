//
//  ViuPlayerViewController+Gesture.swift
//  tvOS_demo
//
//  Created by TerryChe on 2019/12/4.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

extension ViuPlayerViewController: UIGestureRecognizerDelegate {
    
    func setupGestureRecognizer() {
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
        swipeUp.direction = .up
        // 设置为YES，以防止视图处理可能被识别为该手势的任何触摸或按下
        //        swipeUp.delaysTouchesBegan = true
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
        swipeDown.direction = .down
        // 设置为YES，以防止视图处理可能被识别为该手势的任何触摸或按下
        //        swipeDown.delaysTouchesBegan = true
        view.addGestureRecognizer(swipeDown)
        
        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(onPlayPauseTap(tap:)))
        playPauseTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        view.addGestureRecognizer(playPauseTap)
        
        let selectTap = UITapGestureRecognizer(target: self, action: #selector(onSelectTap(tap:)))
        selectTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        selectTap.delaysTouchesBegan = true
        view.addGestureRecognizer(selectTap)
        
        //        let upTap = UITapGestureRecognizer(target: self, action: #selector(onUpTap(tap:)))
        //        upTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.upArrow.rawValue)]
        //        upTap.delaysTouchesBegan = true
        //        upTap.delaysTouchesEnded = true
        //        view.addGestureRecognizer(upTap)
        //
        //        let downTap = UITapGestureRecognizer(target: self, action: #selector(onDownTap(tap:)))
        //        downTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.downArrow.rawValue)]
        //        downTap.delaysTouchesBegan = true
        //        downTap.delaysTouchesEnded = true
        //        view.addGestureRecognizer(downTap)
        //
        //        let leftTap = UITapGestureRecognizer(target: self, action: #selector(onLeftTap(tap:)))
        //        leftTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.leftArrow.rawValue)]
        //        leftTap.delaysTouchesBegan = true
        //        leftTap.delaysTouchesEnded = true
        //        view.addGestureRecognizer(leftTap)
        //
        //        let rightTap = UITapGestureRecognizer(target: self, action: #selector(onRightTap(tap:)))
        //        rightTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.rightArrow.rawValue)]
        //        rightTap.delaysTouchesBegan = true
        //        rightTap.delaysTouchesEnded = true
        //        view.addGestureRecognizer(rightTap)
        
        // 继承UIGestureRecognizer 重写该手势的touch事件
        let viuGesture = ViuRemoteGestureRecognizer(target: self, action: #selector(touchLocationDidChange(_:)))
        viuGesture.delegate = self
        view.addGestureRecognizer(viuGesture)
        
    }
    
    // 必须同时支持多个手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: Event For UIGestureRecognizer

extension ViuPlayerViewController {
    
    @objc func touchLocationDidChange(_ gesture: ViuRemoteGestureRecognizer) {
        
        // tabbar出现后不处理
        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
        
        if gesture.state == .ended {
            viuPlayer.displayView.setupTimer()
            
        } else if gesture.state == .began {
            ViuGestureSetupTimer()
        }
        
        // 进度条出现才处理
        if viuPlayer.displayView.isDisplayControl {
            viuPlayer.displayView.viuProgressView.setPorgressLineByUser(offset: gesture.touchesMovedX)
        }
        
        
        // 左右轻触
        switch gesture.touchLocation {
        case .left:
            print("touchLocationDidChange left")
            break
        case .right:
            print("touchLocationDidChange right")
            break
        default:
            return
        }
    }
    
    private func ViuGestureSetupTimer() {
        bagenTimer.invalidate()
        bagenTimer = Timer.viuPlayer_scheduledTimerWithTimeInterval(bagenTimerDuration, block: { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
            strongSelf.viuPlayer.displayView.displayControlView(true)
            }, repeats: false)
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
    
    @objc func onSelectTap(tap: UITapGestureRecognizer) {
        playPauseAction()
    }
    
    //    @objc func onUpTap(tap: UITapGestureRecognizer) {
    //
    //        print("onUpTap")
    //    }
    //
    //    @objc func onDownTap(tap: UITapGestureRecognizer) {
    //
    //        print("onDownTap")
    //    }
    //
    //    @objc func onLeftTap(tap: UITapGestureRecognizer) {
    //
    //        print("onLeftTap")
    //    }
    //
    //    @objc func onRightTap(tap: UITapGestureRecognizer) {
    //
    //        print("onRightTap")
    //    }
    
    
    private func playPauseAction() {
        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
            // 如果Tabber显示，就隐藏
            viuPlayer.displayView.hiddenTabbar()
        } else {
            switch viuPlayer.state {
            case .playing:
                viuPlayer.pause()
                viuPlayer.displayView.displayControlView(true)
                break
            case .paused:
                // 跳转对应的时间播放
                let seekTime = viuPlayer.displayView.viuProgressView.seekTime
                if seekTime == viuPlayer.currentDuration {
                    viuPlayer.play()
                } else {
                    viuPlayer.seekTime(seekTime)
                }
                viuPlayer.displayView.displayControlView(false)
                break
            default:
                break
            }
        }
    }
}


// MARK: presses event for Native Controller
//extension ViuPlayerViewController {
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        touches.forEach({ touch in
//            switch touch.type{
//            case .indirect:
//                self.touchStart = touch.timestamp
//                print("touchesBegan")
//                viuPlayer.displayView.displayControlView(true)
//                break
//            default:
//                break
//            }
//        })
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        // 进度条没出现就不处理
//        if !viuPlayer.displayView.isDisplayControl {
//            return
//        }
//
//        // 设置进度条控制
//        guard let touch = touches.first else {
//            return
//        }
//        let ptNew = touch.preciseLocation(in: view)
//        let ptPrevious = touch.precisePreviousLocation(in: view)
//        let offset = (ptNew.x - ptPrevious.x) * 0.1
//
//        viuPlayer.displayView.viuProgressView.setPorgressLineByUser(offset: offset)
//        // 取消Timer计时
//        viuPlayer.displayView.timer.invalidate()
//
//        //        print("majorRadius:\(touch.majorRadius) === majorRadiusTolerance:\(touch.majorRadiusTolerance)")
//        //        print("azimuthAngle:\(touch.azimuthAngle(in: view)) === azimuthUnitVector:\(touch.azimuthUnitVector(in: view))")
//        print("preciseLocation:\(ptNew)")
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        viuPlayer.displayView.setupTimer()
//
//        touches.forEach({ touch in
//            switch touch.type{
//            case .indirect:
//                if let start = self.touchStart,
//                    (touch.timestamp - start < 0.5) {
//                    print("touchesEnded")
//                    super.touchesEnded(touches, with: event)
//                }else {
//                    print("touchesEnded Long touch")
//                }
//                break
//            default:
//                break
//            }
//        })
//    }
//}
