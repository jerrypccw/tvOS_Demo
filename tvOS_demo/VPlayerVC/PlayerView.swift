//
//  PlayerView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/19.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    
    public var player: Player!
    
    public var renderingView: PlayerRenderingView!
    
    public var ready: Bool = false
    
    public var autoplay: Bool = true

    public var isPlaying: Bool = false
    
    public var isSeeking: Bool = false
    
    public var isFullscreenModeEnabled: Bool = false
    
    public var isForwarding: Bool {
        return player.rate > 1
    }
    
    public var isRewinding: Bool {
        return player.rate < 0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    public func prepare() {
        ready = true
        player = Player()
        player.handler = self
        player.preparePlayerPlaybackDelegate()
        renderingView = PlayerRenderingView(with: self)
        renderingViewLayout(view: renderingView, into: self)
    }
    
    public func renderingViewLayout(view: UIView, into: UIView) {
        into.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: into.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: into.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: into.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: into.bottomAnchor).isActive = true
    }
    
    public func set(item: AVPlayerItem?) {
        if !ready {
            prepare()
        }
        
        player.replaceCurrentItem(with: item)
        if autoplay && item?.error == nil {
            play()
        }
    }
    
    public func play() {
        player.play()
        isPlaying = true
    }
    
    public func pause() {
        player.pause()
        isPlaying = false
    }
    
    public func togglePlayback() {
        if isPlaying {
            pause()
        }else {
            play()
        }
    }    
}
