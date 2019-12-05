//
//  ViuPlayerViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/28.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerViewController: UIViewController{
    
    var viuPlayer : ViuPlayer = {
        let playerView = ViuPlayerSubtitlesView()
        let player = ViuPlayer(playerView: playerView)
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
        viuPlayer.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        view.addSubview(viuPlayer.displayView)
        
        viuPlayer.backgroundMode = .proceed
        viuPlayer.delegate = self
        viuPlayer.displayView.delegate = self
        
        viuPlayer.displayView.translatesAutoresizingMaskIntoConstraints = false
        viuPlayer.displayView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        viuPlayer.displayView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viuPlayer.displayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viuPlayer.displayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
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
            let playerView = self.viuPlayer.displayView as! ViuPlayerSubtitlesView
            playerView.setSubtitles(ViuSubtitles(filePath: srt))
        }
        
        let mp4File = ViuPlayerUtils.fileResource("hubblecast", fileType: "m4v")
        
        guard let urlStr: String = mp4File else {
            print("路径不存在")
            return
        }
        
        let url = URL.init(fileURLWithPath: urlStr)
        
        viuPlayer.replaceVideo(url)
        viuPlayer.play()
    }
}

///MARK: Event For UIGestureRecognizer
extension ViuPlayerViewController {
    
    @objc func onSwipeAction(swipe: UISwipeGestureRecognizer) {
        
        print("swipeAction : \(swipe)")
        
        switch swipe.direction {
        case .down:
            print("swipeDownAction")
            viuPlayer.displayView.displayControlView(false)
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
        
       playSelectTapAction()
    }
    
    @objc func onSelectTap(tap: UITapGestureRecognizer) {
        
       playSelectTapAction()
    }
    
    private func playSelectTapAction() {
        
        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
            viuPlayer.displayView.hiddenTabbar()
        }
        
        switch viuPlayer.state {
        case .playFinished:
            break
        case .playing:
            viuPlayer.pause()
            viuPlayer.displayView.displayControlView(true)
            viuPlayer.displayView.viuProgressView.pauseStatusAction()
            break
        case .paused:
            viuPlayer.play()
            viuPlayer.displayView.displayControlView(false)
            viuPlayer.displayView.viuProgressView.normalStatusAction()
            break
        case .none:
            break
        case .error:
            break
        }
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
    //                viuPlayer.displayView.panGestureDirection = .vertical
    //
    //            } else if x > y{
    //                guard viuPlayer.mediaFormat == .m3u8 else {
    //                    viuPlayer.displayView.panGestureDirection = .horizontal
    //                    return
    //                }
    //            }
    //        case .changed:
    //            switch viuPlayer.displayView.panGestureDirection {
    //            case .horizontal:
    //                  print("changed location: \(location)")
    //                  if viuPlayer.currentDuration == 0 { break }
    //                  let _ = panGestureHorizontal(location.x)
    //            default:
    //                break
    //            }
    //        case .ended:
    //            switch viuPlayer.displayView.panGestureDirection {
    //            case .horizontal:
    //                   viuPlayer.displayView.setupTimer()
    //            default:
    //                break
    //            }
    //        default:
    //            break
    //        }
    //    }
    //
    
    //    internal func panGestureHorizontal(_ velocityX: CGFloat) -> TimeInterval {
    //        viuPlayer.displayView.displayControlView(true)
    //        viuPlayer.displayView.timer.invalidate()
    //          let value = timeSlider.value
    //        if let _ = viuPlayer.currentDuration ,let totalDuration = viuPlayer.totalDuration {
    //              let sliderValue = (TimeInterval(value) *  totalDuration) + TimeInterval(velocityX) / 100.0 * (TimeInterval(totalDuration) / 400)
    //              timeSlider.setValue(Float(sliderValue/totalDuration), animated: true)
    //
    //              return sliderValue
    //          } else {
    //              return TimeInterval.nan
    //          }
    //        return TimeInterval.nan
    //      }
    
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
        viuPlayer.displayView.displayControlView(true)
        
        
        //        guard let touch = touches.first else {
        //            return
        //        }
        //        let location = touch.location(in: view)
        //        touchBox.frame.origin = location
        //        priorTouch = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        print("touchesMoved")
        viuPlayer.displayView.displayControlView(true)
        
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
        //        if viuPlayer.currentDuration == 0 { return }
        //        let _ = panGestureHorizontal(point!.x)
        //        print("touchesMoved \(point?.x)")
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        print("touchesEnded")
        viuPlayer.displayView.setupTimer()
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
    //                if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
    //                    viuPlayer.displayView.hiddenTabbar()
    //                }
    //
    //                viuPlayer.displayView.isDisplayControl = !viuPlayer.displayView.isDisplayControl
    //                viuPlayer.displayView.displayControlView(viuPlayer.displayView.isDisplayControl)
    //                break
    //            case .menu:
    //
    //                break
    //            case .playPause:
    //                print("playPause")
    //
    //                switch viuPlayer.state {
    //                case .playFinished:
    //                    break
    //                case .playing:
    //                    viuPlayer.pause()
    //                    viuPlayer.displayView.displayControlView(true)
    //                    break
    //                case .paused:
    //                    viuPlayer.play()
    //                    viuPlayer.displayView.displayControlView(false)
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

// MARK viuPlayerDelegate
extension ViuPlayerViewController: ViuPlayerDelegate {
    func viuPlayer(_ player: ViuPlayer, playerFailed error: ViuPlayerError) {
        print(error)
    }
    func viuPlayer(_ player: ViuPlayer, stateDidChange state: ViuPlayerState) {
        print("player State ",state)
        
        if state == .playFinished {
            let mp4File = ViuPlayerUtils.fileResource("apple_tv_app_universal_search_part_01_sd", fileType: "mp4")
            let url = URL.init(fileURLWithPath: mp4File!)
            
            viuPlayer.replaceVideo(url)
            viuPlayer.play()
        }
    }
    func viuPlayer(_ player: ViuPlayer, bufferStateDidChange state: ViuPlayerBufferstate) {
        print("buffer State", state)
    }
    
}

// MARK viuPlayerViewDelegate
extension ViuPlayerViewController: ViuPlayerViewDelegate {
    
    func viuPlayerView(_ playerView: ViuPlayerView, willFullscreen fullscreen: Bool) {
    }
    
    func viuPlayerView(didTappedClose playerView: ViuPlayerView) {
        
    }
    func viuPlayerView(didDisplayControl playerView: ViuPlayerView) {
        
    }
}
