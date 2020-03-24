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

open class ViuPlaybackTouchGestureRecognizer: UIGestureRecognizer {
    private(set) var touchesMovedX: CGFloat = 0.0

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        cancelsTouchesInView = false
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
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

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        //        print("touchesMoved")

        if event.digitizerLocation.x < 0.3 {
            remoteTouchLocation = .left
        } else if event.digitizerLocation.x > 0.7 {
            remoteTouchLocation = .right
        } else {
            remoteTouchLocation = .center
        }

        guard let touch = touches.first else { return }
        let ptNew = touch.preciseLocation(in: view)
        let ptPrevious = touch.precisePreviousLocation(in: view)
        let offset = (ptNew.x - ptPrevious.x) * 0.1
        touchesMovedX = offset
        
        state = .changed
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        //        print("touchesCancelled")
        reset()
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        //        print("touchesEnded")
        reset()
    }

    open override func reset() {
        remoteTouchLocation = .center
        touchesMovedX = 0.0
        super.reset()
        state = .ended
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
        set(manager) {
            objc_setAssociatedObject(self, &AssociatedKeys.managerKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var stateString: String {
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

extension UIEvent {
    @nonobjc var digitizerLocation: CGPoint {
        guard let value = value(forKey: "_digitizerLocation") as? CGPoint else {
            return CGPoint(x: 0.5, y: 0.5)
        }
        return value
    }
}
