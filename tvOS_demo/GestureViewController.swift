//
//  GestureViewController.swift
//  tvOS_demo
//
//  Created by TerryChe on 2020/3/10.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

enum TouchLocation {
    case center
    case left
    case right
}

class GestureViewController: UIViewController, GestureManagerDelegate {
    let gm = GestureManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gm.addGesture(view)
        gm.delegate = self
    }
    
    func onTap(_ gesture: TouchGesture) {
        print("\(gesture.remoteTouchLocation) === 触摸 === \(gesture.stateString)")
    }
    
    func onClick(_ gesture: UITapGestureRecognizer) {
        print("\(gesture.remoteTouchLocation) >>>>>> 点击 >>> \(gesture.stateString)")
    }
    
    func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        print("\(gesture.remoteTouchLocation) <<<<<<<<< 长按 <<< \(gesture.stateString)")
    }
}

public protocol GestureManagerDelegate : NSObjectProtocol {
    func onTap(_ gesture: TouchGesture)
    
    func onClick(_ gesture: UITapGestureRecognizer)

    func onLongPress(_ gesture: UILongPressGestureRecognizer)
}

class GestureManager: NSObject, UIGestureRecognizerDelegate {
    weak open var delegate: GestureManagerDelegate? // the gesture recognizer's delegate
    var touchLocation: TouchLocation = .center
    
    func addGesture(_ target: UIView) {
        let touch = TouchGesture(target: self, action: #selector(touchGesture(_:)))
        touch.delegate = self
        target.addGestureRecognizer(touch)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        target.addGestureRecognizer(tap)
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        long.cancelsTouchesInView = false
        long.delegate = self
        target.addGestureRecognizer(long)
    }
    
    @objc func touchGesture(_ gesture: TouchGesture) {
        touchLocation = gesture.remoteTouchLocation
        
        if let delegate = delegate {
            delegate.onTap(gesture)
        }
    }
    
    @objc func tapGesture(_ gesture: UITapGestureRecognizer) {
        if let delegate = delegate {
            gesture.remoteTouchLocation = touchLocation
            delegate.onClick(gesture)
        }
    }
    
    @objc func longPressGesture(_ gesture: UILongPressGestureRecognizer) {
        if let delegate = delegate {
            gesture.remoteTouchLocation = touchLocation
            delegate.onLongPress(gesture)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

open class TouchGesture: UIGestureRecognizer {
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        cancelsTouchesInView = false
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
//        print("touchesBegan")

        if event.digitizerLocation.x < 0.3 {
            remoteTouchLocation = .left
        } else if event.digitizerLocation.x > 0.7 {
            remoteTouchLocation = .right
        } else {
            remoteTouchLocation = .center
        }

        state = .began
    }
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
//        print("touchesMoved")

        if event.digitizerLocation.x < 0.3 {
            remoteTouchLocation = .left
        } else if event.digitizerLocation.x > 0.7 {
            remoteTouchLocation = .right
        } else {
            remoteTouchLocation = .center
        }
    }
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
//        print("touchesCancelled")
        reset()
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
//        print("touchesEnded")
        reset()
    }

    override open func reset() {
        remoteTouchLocation = .center
        super.reset()
    }
}

extension UIGestureRecognizer {
    private struct AssociatedKeys {
        static var managerKey = "UIGestureRecognizer.remoteTouchLocation"
    }

    var remoteTouchLocation: TouchLocation {
        get {
            if let temp = objc_getAssociatedObject(self, &AssociatedKeys.managerKey) as? TouchLocation {
                return temp
            }
            
            return .center
        }
        set (manager) {
            objc_setAssociatedObject(self, &AssociatedKeys.managerKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var stateString: String {
        get {
            switch state {
            case .began:
                return "began"
            case .cancelled:
                return "cancelled"
            case .changed:
                return "changed"
            case .ended:
                return "ended"
            case .failed:
                return "failed"
            case .possible:
                return "possible"
            case .recognized:
                return "recognized"
            default:
                return "unkonw"
            }
        }
    }
}
