//
//  ViuPlayerContainerView.swift
//  ViuPlayer
//
//  Created by TerryChe on 2020/3/19.
//  Copyright © 2020 TerryChe. All rights reserved.
//

import UIKit

class VPContainerView: UIView {
    let subTitleManager = VPSubtitlesManager()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configurationSubTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurationSubTitle() {
        subTitleManager.configurationUI(self)
    }
}
