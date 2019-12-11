//
//  ViuPlayerViewController+Gesture.swift
//  tvOS_demo
//
//  Created by TerryChe on 2019/12/4.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

extension ViuPlayerViewController {
    
    func setupGestureRecognizer() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
        swipeUp.direction = .up
        // 设置为YES，以防止视图处理可能被识别为该手势的任何触摸或按下
        swipeUp.delaysTouchesBegan = true
        view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
        swipeDown.direction = .down
        // 设置为YES，以防止视图处理可能被识别为该手势的任何触摸或按下
        swipeDown.delaysTouchesBegan = true
        view.addGestureRecognizer(swipeDown)

        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(onPlayPauseTap(tap:)))
        playPauseTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        view.addGestureRecognizer(playPauseTap)

        let selectTap = UITapGestureRecognizer(target: self, action: #selector(onSelectTap(tap:)))
        selectTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        selectTap.delaysTouchesBegan = true
        selectTap.delaysTouchesEnded = true
        view.addGestureRecognizer(selectTap)
        
    }
}

// MARK: Event For UIGestureRecognizer

extension ViuPlayerViewController {
    @objc func onSwipeAction(swipe: UISwipeGestureRecognizer) {
//        print("swipeAction : \(swipe)")

        switch swipe.direction {
        case .down:
//            print("swipeDownAction")
            if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == false {
                viuPlayer.displayView.showTabbar()
            }
            break
        case .up:
//            print("swipeUpAction")
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
extension ViuPlayerViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        print("touchesBegan")
        viuPlayer.displayView.displayControlView(true)

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        // 进度条没出现就不处理
        if !viuPlayer.displayView.isDisplayControl {
            return
        }

        // 设置进度条控制
        guard let touch = touches.first else {
            return
        }
        let ptNew = touch.preciseLocation(in: view)
        let ptPrevious = touch.precisePreviousLocation(in: view)
        let offset = (ptNew.x - ptPrevious.x) * 0.1

        viuPlayer.displayView.viuProgressView.setPorgressLineByUser(offset: offset)
        // 取消Timer计时
        viuPlayer.displayView.timer.invalidate()

//        print("majorRadius:\(touch.majorRadius) === majorRadiusTolerance:\(touch.majorRadiusTolerance)")
//        print("azimuthAngle:\(touch.azimuthAngle(in: view)) === azimuthUnitVector:\(touch.azimuthUnitVector(in: view))")
        print("preciseLocation:\(ptNew)")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        print("touchesEnded")
        viuPlayer.displayView.setupTimer()
    }

}
