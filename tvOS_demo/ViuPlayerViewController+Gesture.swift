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
        view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)

        // MARK： 添加pan手势会导致swipes手势失效，可使用override touchBegan 等方法捕获remote轻触事件
        //        let touchPan = UIPanGestureRecognizer(target: self, action: #selector(onTouchPan(pan: )))
        //        view.addGestureRecognizer(touchPan)

        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(onPlayPauseTap(tap:)))
        playPauseTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        view.addGestureRecognizer(playPauseTap)

        let selectTap = UITapGestureRecognizer(target: self, action: #selector(onSelectTap(tap:)))
        selectTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        view.addGestureRecognizer(selectTap)
    }
}

// MARK: Event For UIGestureRecognizer

extension ViuPlayerViewController {
    @objc func onSwipeAction(swipe: UISwipeGestureRecognizer) {
        print("swipeAction : \(swipe)")

        switch swipe.direction {
        case .down:
            print("swipeDownAction")
            if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == false {
                viuPlayer.displayView.showTabbar()
            }

            break
        case .up:
            print("swipeUpAction")
            if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
                viuPlayer.displayView.hiddenTabbar()
            }
            break
        default:
            break
        }
    }

    @objc func onPlayPauseTap(tap: UITapGestureRecognizer) {
        switch viuPlayer.state {
        case .playFinished:
            break
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
        case .none:
            break
        case .error:
            break
        }
    }

    @objc func onSelectTap(tap: UITapGestureRecognizer) {
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

    internal func panGestureHorizontal(_ velocityX: CGFloat) -> TimeInterval {
        viuPlayer.displayView.displayControlView(true)
        viuPlayer.displayView.timer.invalidate()
//          let value = timeSlider.value
//        if let _ = viuPlayer.currentDuration ,let totalDuration = viuPlayer.totalDuration {
//              let sliderValue = (TimeInterval(value) *  totalDuration) + TimeInterval(velocityX) / 100.0 * (TimeInterval(totalDuration) / 400)
//              timeSlider.setValue(Float(sliderValue/totalDuration), animated: true)
//
//              return sliderValue
//          } else {
//              return TimeInterval.nan
//          }
        return TimeInterval.nan
    }
}

////MARK: UIGestureRecognizerDelegate
extension ViuPlayerViewController: UIGestureRecognizerDelegate {
    // 添加多个手势的时候，需要使用UIGestureRecognizerDelegate方法，避免手势冲突
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
