//
//  ViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/9/27.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // 播放器导航栏
    let viuPlayerTabbar = ViuPlayerTabbarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction(swipe: )))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpAction(swipe: )))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        view.addSubview(viuPlayerTabbar)
        
        let model = ViuPlayerTabbarModel.init(buttonName: "abc")
        let model2 = ViuPlayerTabbarModel.init(buttonName: "abcd")
        let model3 = ViuPlayerTabbarModel.init(buttonName: "abcde")
        let model4 = ViuPlayerTabbarModel.init(buttonName: "abcde")
        viuPlayerTabbar.buttonModels = [model, model2, model3, model4]

    }
    
    @objc func swipeDownAction(swipe: UISwipeGestureRecognizer) {
        
        viuPlayerTabbar.showTabbarView()
    }
    
    @objc func swipeUpAction(swipe: UISwipeGestureRecognizer) {
        
        viuPlayerTabbar.hiddenTabbarView()
    }
    
}

//MARK: presses event for Native Controller
extension ViewController {
    
    /// 遥控器按键事件
    /// - Parameters:
    ///   - presses: 按钮对象
    ///   - event: 按钮事件
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        for press in presses {
            switch press.type {
            case .upArrow:
                viuPlayerTabbar.hiddenTabbarView()
                
                break
            case .downArrow:
                viuPlayerTabbar.showTabbarView()
                
                break
            case .leftArrow:
                
                break
            case .rightArrow:
                
                break
            case .select:
                
                break
            case .menu:
                viuPlayerTabbar.hiddenTabbarView()
                
                break
            case .playPause:
                
                let model = ViuPlayerTabbarModel.init(buttonName: "abc")
                let model1 = ViuPlayerTabbarModel.init(buttonName: "abcd")
                let model2 = ViuPlayerTabbarModel.init(buttonName: "abcd")
                viuPlayerTabbar.buttonModels = [model, model1, model2]
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
