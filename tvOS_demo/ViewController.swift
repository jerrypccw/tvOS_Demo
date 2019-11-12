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
    
    //    var touchLengthY: CGFloat = 0.0
    //    var touchEvent: Int = 0
    
    // 
    let viuPlayerTabbar = ViuPlayerTabbarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        
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
        
        showTabBar()
    }
    
    @objc func swipeUpAction(swipe: UISwipeGestureRecognizer) {
        
        hideTabBar()
    }
    
    /// 显示TabBar
    func showTabBar() {
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            
            var frame = self?.viuPlayerTabbar.frame
            frame?.origin.y = 0
            self?.viuPlayerTabbar.frame = frame ?? CGRect.zero
        })
    }
    
    /// 隐藏TabBar
    func hideTabBar() {
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            
            var frame = self?.viuPlayerTabbar.frame
            frame?.origin.y = -200
            self?.viuPlayerTabbar.frame = frame ?? CGRect.zero
        })
    }
    
    
    /// 遥控器按键事件
    /// - Parameters:
    ///   - presses: <#presses description#>
    ///   - event: <#event description#>
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("pressesBegan \(presses)")
        
        for press in presses {
            switch press.type {
            case .upArrow:
                print("pressesBegan upArrow")
                let model = ViuPlayerTabbarModel.init(buttonName: "abc")
                let model1 = ViuPlayerTabbarModel.init(buttonName: "abcd")
                let model2 = ViuPlayerTabbarModel.init(buttonName: "abcd")
                viuPlayerTabbar.buttonModels = [model, model1, model2]
                
                hideTabBar()
                break
            case .downArrow:
                print("pressesBegan downArrow")
                
                showTabBar()
                break
            case .leftArrow:
                print("pressesBegan leftArrow")
                let model1 = ViuPlayerTabbarModel.init(buttonName: "abcd")
                let model2 = ViuPlayerTabbarModel.init(buttonName: "abcd")
                viuPlayerTabbar.buttonModels = [model1, model2]
                break
            case .rightArrow:
                print("pressesBegan rightArrow")
                break
            case .select:
                print("pressesBegan select")
                break
            case .menu:
                print("pressesBegan menu")
                break
            case .playPause:
                print("pressesBegan play/pause")
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


//MARK: touches event for Native Controller

extension ViewController {
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        guard let touch = touches.first else { return }
    //        let touchLocation = touch.location(in: self.view)
    //
    //        touchLengthY = touchLocation.y
    //    }
    //
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        guard let touch = touches.first else { return }
    //        let touchLocation = touch.location(in: self.view)
    //
    //        var tmpY = touchLocation.y
    //
    //        tmpY = tmpY - touchLengthY
    //
    //        if  tmpY > 500 {
    //            touchEvent += 1
    //        }
    //
    //        if touchEvent == 1 {
    //            print("下拉事件触发")
    //        }
    //
    //
    //
    //    }
    //
    //    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        guard let touch = touches.first else { return }
    //        let touchLocation = touch.location(in: self.view)
    //
    //        touchLengthY = 0.0
    //        touchEvent = 0
    //    }
    //
    //    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        guard let touch = touches.first else { return }
    //        let touchLocation = touch.location(in: self.view)
    //
    //        touchLengthY = 0.0
    //        touchEvent = 0
    //    }
    //
    //    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
    //        print("touchesEstimatedPropertiesUpdated \(touches)")
    //    }
}
