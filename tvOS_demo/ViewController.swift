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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
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
                viuProgressView.timerStart()
                
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
