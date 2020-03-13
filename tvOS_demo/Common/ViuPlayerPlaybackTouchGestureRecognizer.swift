//
//  ViuPlayerPlaybackTouchGestureRecognizer.swift
//  tvOS_demo
//
//  Created by TerryChe on 2020/3/12.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

enum TouchRemoteLocation {
    case center
    case left
    case right
}

open class ViuPlayerPlaybackTouchGestureRecognizer: UIGestureRecognizer {
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

    var remoteTouchLocation: TouchRemoteLocation {
        get {
            if let temp = objc_getAssociatedObject(self, &AssociatedKeys.managerKey) as? TouchRemoteLocation {
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

extension UIEvent {
    @nonobjc var digitizerLocation: CGPoint {
        guard let value = value(forKey: "_digitizerLocation") as? CGPoint else {
            return CGPoint(x: 0.5, y: 0.5)
        }
        return value
    }
}
