//
//  PlayerRenderingView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/19.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

open class PlayerRenderingView: UIView {
    
    var renderingLayer: PlayerLayer!
    
    var player: PlayerView!

    init(with player: PlayerView) {
        super.init(frame: CGRect.zero)
        self.player = player
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if renderingLayer == nil {
            renderingLayer = PlayerLayer.init(with: player)
            layer.addSublayer(renderingLayer.playerLayer)
        }        
        renderingLayer.playerLayer.frame = bounds
    }
}
