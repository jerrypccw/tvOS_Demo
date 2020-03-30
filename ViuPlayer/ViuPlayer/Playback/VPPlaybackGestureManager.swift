//
//  ViuPlayerPlaybackGestureManager.swift
//  tvOS_demo
//
//  Created by TerryChe on 2020/3/12.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

class VPPlaybackGestureManager: NSObject, UIGestureRecognizerDelegate {
    weak open var delegate: ViuPlaybackGestureManagerDelegate? // the gesture recognizer's delegate
    var touchLocation: VPTouchRemoteLocation = .center
    
    func addGesture(_ target: UIView) {
        let touch = VPPlaybackTouchGestureRecognizer(target: self, action: #selector(touchGesture(_:)))
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
    
    @objc func touchGesture(_ gesture: VPPlaybackTouchGestureRecognizer) {
        touchLocation = gesture.remoteTouchLocation
        
        if let delegate = delegate {
            delegate.onTouch(gesture)
        }
    }
    
    @objc func tapGesture(_ gesture: UITapGestureRecognizer) {
        if let delegate = delegate {
            gesture.remoteTouchLocation = touchLocation
            delegate.onTap(gesture)
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

public protocol ViuPlaybackGestureManagerDelegate : NSObjectProtocol {
    func onTouch(_ gesture: VPPlaybackTouchGestureRecognizer)
    
    func onTap(_ gesture: UITapGestureRecognizer)

    func onLongPress(_ gesture: UILongPressGestureRecognizer)
}
