//
//  PlayerLayer.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/19.
//  Copyright © 2020 jerry. All rights reserved.
//

import AVFoundation

open class PlayerLayer: CALayer {
    
    /// Player Layer to be used
    var playerLayer: AVPlayerLayer!
    
    /// VersaPlayer instance being rendered
    var playerView: PlayerView!
    
    override public init(layer: Any) {
        super.init(layer: layer)
    }
    
    override public init() {
        super.init()
    }
    
    convenience init(with player: PlayerView) {
        self.init()
        playerLayer = AVPlayerLayer.init(player: player.player)
        addSublayer(playerLayer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSublayers() {
        super.layoutSublayers()
        playerLayer.frame = bounds
    }
    
}
