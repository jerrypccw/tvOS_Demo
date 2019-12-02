//
//  ViuPlayerViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/28.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerViewController: UIViewController{
    
    var jhPlayer : JHPlayer = {
        let playerView = ViuPlayerView()
        let player = JHPlayer(playerView: playerView)
        return player
    }()
    
//    let touchBox = UIView()
//    var priorTouch = CGPoint.zero
//    var velocity = CGPoint.zero
    
    deinit {
        print("ViuPlayerViewController deinit")
    }
    
    // 使用PUSH转跳需要添加一下代码，不然会丢失焦点
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         self.navigationController?.setNavigationBarHidden(true, animated: true)
     }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        jhPlayer.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        view.addSubview(jhPlayer.displayView)
        
        jhPlayer.backgroundMode = .proceed
        jhPlayer.delegate = self
        jhPlayer.displayView.delegate = self
        
        jhPlayer.displayView.translatesAutoresizingMaskIntoConstraints = false
        jhPlayer.displayView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        jhPlayer.displayView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        jhPlayer.displayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        jhPlayer.displayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        setPlayerData()
        setupGestureRecognizer()
    
//        view.addSubview(touchBox)
//        touchBox.backgroundColor = .purple
//        touchBox.frame = CGRect.init(x: 100, y: 100, width: 100, height: 100)
    }
    
    private func setupGestureRecognizer() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe: )))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe: )))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        //MARK： 添加pan手势会导致swipes手势失效，可使用override touchBegan 等方法捕获remote轻触事件
//        let touchPan = UIPanGestureRecognizer(target: self, action: #selector(onTouchPan(pan: )))
//        view.addGestureRecognizer(touchPan)
        
        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(onPlayPauseTap(tap: )))
        playPauseTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        view.addGestureRecognizer(playPauseTap)

        let selectTap = UITapGestureRecognizer(target: self, action: #selector(onSelectTap(tap: )))
        selectTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        view.addGestureRecognizer(selectTap)

    }
    
    private func setPlayerData() {
        
        if  let srt = Bundle.main.url(forResource: "test", withExtension: "srt") {
            let playerView = self.jhPlayer.displayView as! ViuPlayerView
            playerView.setSubtitles(JHSubtitles(filePath: srt))
        }
        
        let mp4File = JHPlayerUtils.fileResource("hubblecast", fileType: "m4v")
        
        guard let urlStr: String = mp4File else {
            print("路径不存在")
            return
        }
        
        let url = URL.init(fileURLWithPath: urlStr)
        
        jhPlayer.replaceVideo(url)
        jhPlayer.play()
    }
}

///MARK: Event For UIGestureRecognizer
extension ViuPlayerViewController {
    
    @objc func onSwipeAction(swipe: UISwipeGestureRecognizer) {
        
        print("swipeAction : \(swipe)")
        
        switch swipe.direction {
        case .down:
            print("swipeDownAction")
            if jhPlayer.displayView.viuPlayerTabbar.isTabbarShow == false {
                jhPlayer.displayView.showTabbar()
            }
                        
            break
        case .up:
            print("swipeUpAction")
            if jhPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
                jhPlayer.displayView.hiddenTabbar()
            }
            break
        default:
            break
        }
    }
    
    @objc func onPlayPauseTap(tap: UITapGestureRecognizer) {

        switch jhPlayer.state {
        case .playFinished:
            break
        case .playing:
            jhPlayer.pause()
            jhPlayer.displayView.displayControlView(true)
            break
        case .paused:
            jhPlayer.play()
            jhPlayer.displayView.displayControlView(false)
            break
        case .none:
            break
        case .error:
            break
        }
    }
    
    @objc func onSelectTap(tap: UITapGestureRecognizer) {

        if jhPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
            jhPlayer.displayView.hiddenTabbar()
        }

        jhPlayer.displayView.isDisplayControl = !jhPlayer.displayView.isDisplayControl
        jhPlayer.displayView.displayControlView(jhPlayer.displayView.isDisplayControl)
    }
    
//    @objc func onTouchPan(pan: UIPanGestureRecognizer) {
//        let translation = pan.translation(in: view)
//        let location = pan.location(in: view)
//        switch pan.state {
//        case .began:
//
//            print("onTouchPan began")
//
//            let x = abs(translation.x)
//            let y = abs(translation.y)
//            if x < y {
//                jhPlayer.displayView.panGestureDirection = .vertical
//
//            } else if x > y{
//                guard jhPlayer.mediaFormat == .m3u8 else {
//                    jhPlayer.displayView.panGestureDirection = .horizontal
//                    return
//                }
//            }
//        case .changed:
//            switch jhPlayer.displayView.panGestureDirection {
//            case .horizontal:
//                  print("changed location: \(location)")
//                  if jhPlayer.currentDuration == 0 { break }
//                  let _ = panGestureHorizontal(location.x)
//            default:
//                break
//            }
//        case .ended:
//            switch jhPlayer.displayView.panGestureDirection {
//            case .horizontal:
//                   jhPlayer.displayView.setupTimer()
//            default:
//                break
//            }
//        default:
//            break
//        }
//    }
//
    internal func panGestureHorizontal(_ velocityX: CGFloat) -> TimeInterval {
        jhPlayer.displayView.displayControlView(true)
        jhPlayer.displayView.timer.invalidate()
//          let value = timeSlider.value
//        if let _ = jhPlayer.currentDuration ,let totalDuration = jhPlayer.totalDuration {
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

//MARK: presses event for Native Controller
extension ViuPlayerViewController {
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        print("touchesBegan")
//        guard let touch = touches.first else {
//            return
//        }
//        let location = touch.location(in: view)
//        touchBox.frame.origin = location
//        priorTouch = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
//        guard let touch = touches.first else {
//            return
//        }
//        let location:CGPoint = touch.location(in: view)

//        let offset = location - priorTouch
//        let direction = offset.normalized()
//        velocity = direction
//        let tmpPriorTouch = CGPoint(x: priorTouch.x * 0.75, y: priorTouch.y * 0.75)
//        let tmpLocation = CGPoint(x: location.x * 0.25, y: location.y * 0.25)
//        priorTouch = CGPoint(x: tmpLocation.x + tmpPriorTouch.x, y: tmpLocation.y + tmpPriorTouch.y)
//        touchBox.frame.origin = priorTouch
        
//        let point = event?.allTouches?.first?.location(in: view)
//        if jhPlayer.currentDuration == 0 { return }
//        let _ = panGestureHorizontal(point!.x)
//        print("touchesMoved \(point?.x)")

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        print("touchesEnded")
        jhPlayer.displayView.setupTimer()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        print("touchesCancelled")
    }
    
    /// 遥控器按键事件
    /// - Parameters:
    ///   - presses: 按钮对象
    ///   - event: 按钮事件
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        super.pressesBegan(presses, with: event)
//
//        for press in presses {
//            switch press.type {
//            case .leftArrow:
//                print("leftArrow")
//                break
//            case .rightArrow:
//                print("rightArrow")
//                break
//            case .select:
//                print("select")
//                if jhPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
//                    jhPlayer.displayView.hiddenTabbar()
//                }
//
//                jhPlayer.displayView.isDisplayControl = !jhPlayer.displayView.isDisplayControl
//                jhPlayer.displayView.displayControlView(jhPlayer.displayView.isDisplayControl)
//                break
//            case .menu:
//
//                break
//            case .playPause:
//                print("playPause")
//
//                switch jhPlayer.state {
//                case .playFinished:
//                    break
//                case .playing:
//                    jhPlayer.pause()
//                    jhPlayer.displayView.displayControlView(true)
//                    break
//                case .paused:
//                    jhPlayer.play()
//                    jhPlayer.displayView.displayControlView(false)
//                    break
//                case .none:
//                    break
//                case .error:
//                    break
//                }
//
//                break
//            default:
//                print("pressesBegan default")
//                break
//            }
//        }
//    }
    //
    //    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    //        print("pressesChanged  \(presses)")
    //    }
    //
    //    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    //        print("pressesEnded  \(presses)")
    //    }
    //
    //    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    //        print("pressesCancelled  \(presses)")
    //    }
    
}

// MARK JHPlayerDelegate
extension ViuPlayerViewController: JHPlayerDelegate {
    func jhPlayer(_ player: JHPlayer, playerFailed error: JHPlayerError) {
        print(error)
    }
    func jhPlayer(_ player: JHPlayer, stateDidChange state: JHPlayerState) {
        print("player State ",state)
        
        if state == .playFinished {
            let mp4File = JHPlayerUtils.fileResource("apple_tv_app_universal_search_part_01_sd", fileType: "mp4")
            let url = URL.init(fileURLWithPath: mp4File!)
            
            jhPlayer.replaceVideo(url)
            jhPlayer.play()
        }
    }
    func jhPlayer(_ player: JHPlayer, bufferStateDidChange state: JHPlayerBufferstate) {
        print("buffer State", state)
    }
    
}

// MARK JHPlayerViewDelegate
extension ViuPlayerViewController: JHPlayerViewDelegate {
    
    func jhPlayerView(_ playerView: JHPlayerView, willFullscreen fullscreen: Bool) {
    }
    
    func jhPlayerView(didTappedClose playerView: JHPlayerView) {
        
    }
    func jhPlayerView(didDisplayControl playerView: JHPlayerView) {
        
    }
}
