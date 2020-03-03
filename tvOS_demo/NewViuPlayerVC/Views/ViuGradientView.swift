//
//  ViuGradientView.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/18.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

class ViuGradientView: UIView {
    @IBInspectable
    var topColor: UIColor = .clear
    @IBInspectable
    var bottomColor: UIColor = .black

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        (layer as? CAGradientLayer)?.colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
