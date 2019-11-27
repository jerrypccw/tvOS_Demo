//
//  ViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/9/27.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var jhPlayer : JHPlayer = {
        let playeView = ViuPlayerView()
        let playe = JHPlayer(playerView: playeView)
        return playe
    }()
    
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
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe: )))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe: )))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
    }
    
    func setPlayerData() {
        
        if  let srt = Bundle.main.url(forResource: "test", withExtension: "srt") {
            let playerView = self.jhPlayer.displayView as! ViuPlayerView
            playerView.setSubtitles(JHSubtitles(filePath: srt))
        }
        
        let mp4File = JHPlayerUtils.fileResource("apple_tv_app_universal_search_part_01_sd", fileType: "mp4")
        
        guard let urlStr: String = mp4File else {
            print("路径不存在")
            return
        }
        
        let url = URL.init(fileURLWithPath: urlStr)
        
        jhPlayer.replaceVideo(url)
        jhPlayer.play()
    }
    
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        
        print("swipeAction : \(swipe)")
        
        switch swipe.direction {
        case .down:
            print("swipeDownAction")
            if jhPlayer.displayView.viuPlayerTabbar.isTabbarShow == false {
                jhPlayer.displayView.viuPlayerTabbar.showTabbarView()
            }
            
            
            break
        case .up:
            print("swipeUpAction")
            if jhPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
                jhPlayer.displayView.viuPlayerTabbar.hiddenTabbarView()
                updateFocusIfNeeded()
            }
            break
        default:
            break
        }
    }
}

////MARK: UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {

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
extension ViewController {
    
    /// 遥控器按键事件
    /// - Parameters:
    ///   - presses: 按钮对象
    ///   - event: 按钮事件
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        //        super.pressesBegan(presses, with: event)
        
        for press in presses {
            switch press.type {
            case .upArrow:

                
                break
            case .downArrow:
            
                
                break
            case .leftArrow:
                
                break
            case .rightArrow:
                
                break
            case .select:
                print("select")
                if jhPlayer.displayView.viuPlayerTabbar.isTabbarShow == true {
                    jhPlayer.displayView.viuPlayerTabbar.hiddenTabbarView()
                }

                jhPlayer.displayView.isDisplayControl = !jhPlayer.displayView.isDisplayControl
                jhPlayer.displayView.displayControlView(jhPlayer.displayView.isDisplayControl)
                break
            case .menu:
            
                break
            case .playPause:
                print("playPause")
                                
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
              
                
                break
            default:
                print("pressesBegan default")
                break
            }
        }
    }
    
    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("pressesChanged  \(presses)")
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("pressesEnded  \(presses)")
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("pressesCancelled  \(presses)")
    }
    
}

// MARK JHPlayerDelegate
extension ViewController: JHPlayerDelegate {
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
extension ViewController: JHPlayerViewDelegate {
    
    func jhPlayerView(_ playerView: JHPlayerView, willFullscreen fullscreen: Bool) {
    }
    
    func jhPlayerView(didTappedClose playerView: JHPlayerView) {
        
    }
    func jhPlayerView(didDisplayControl playerView: JHPlayerView) {
        
    }
    
}
