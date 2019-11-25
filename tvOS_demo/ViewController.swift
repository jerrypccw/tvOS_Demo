//
//  ViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/9/27.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // 播放器导航栏
    let viuPlayerTabbar = ViuPlayerTabbarView()
    // 播放器进度条
    let viuProgressView = ViuPlayerProgressView()
    
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
        
        view.addSubview(viuPlayerTabbar)
        view.addSubview(viuProgressView)
        
        viuProgressView.isHidden = true
        viuProgressView.translatesAutoresizingMaskIntoConstraints = false
        viuProgressView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 100).isActive = true
        viuProgressView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -100).isActive = true
        viuProgressView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        viuProgressView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        
        let model = TabbarIntroductionModel()
        model.buttonName = "简介"
        model.imageUrl = ""
        model.dramaTitle = "第15集 测试的播放器"
        model.dramaDescription = "测试的播放器导航栏的简介 测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介"
        
        let model2 = TabbarCustomModel()
        model2.buttonName = "字幕"
        model2.customs += ["开", "关"]
        
        let model3 = TabbarSubtitleModel()
        model3.buttonName = "语言"
        model3.subtitles += ["中文", "英文"]
        
        viuPlayerTabbar.buttonModels = [model, model2, model3]
        
    }
    
    func setPlayerData() {
        
        if  let srt = Bundle.main.url(forResource: "Despacito Remix Luis Fonsi ft.Daddy Yankee Justin Bieber Lyrics [Spanish]", withExtension: "srt") {
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
            if viuPlayerTabbar.isTabbarShow == false {
                viuPlayerTabbar.showTabbarView()
            }
            
            
            break
        case .up:
            print("swipeUpAction")
            if viuPlayerTabbar.isTabbarShow == true {
                viuPlayerTabbar.hiddenTabbarView()
            }
            break
        default:
            break
        }
    }
}

//MARK: UIGestureRecognizerDelegate
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
                
                if viuPlayerTabbar.isTabbarShow == false{
                    viuPlayerTabbar.hiddenTabbarView()
                }
                
                break
            case .downArrow:
                
                if viuPlayerTabbar.isTabbarShow == false{
                    viuPlayerTabbar.showTabbarView()
                }
                
                break
            case .leftArrow:
                
                break
            case .rightArrow:
                
                break
            case .select:
                
                
                break
            case .menu:
                
                let model = TabbarIntroductionModel()
                model.buttonName = "简介"
                model.imageUrl = ""
                model.dramaTitle = "第15集 测试的播放器"
                model.dramaDescription = "测试的播放器导航栏的简介 测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介"
                
                viuPlayerTabbar.buttonModels = [model]
                
                break
            case .playPause:
                
                if viuPlayerTabbar.isTabbarShow == true {
                    viuPlayerTabbar.hiddenTabbarView()
                }
                
                viuProgressView.isHidden = !viuProgressView.isHidden
                
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
