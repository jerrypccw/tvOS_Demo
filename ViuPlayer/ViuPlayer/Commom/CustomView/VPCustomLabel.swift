//
//  CustomLabel.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/15.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

enum VPVerticalAlignment {
    case top
    case middle
    case bottom
}

class VPCustomLabel: UILabel {

    var verticalAlignment: VPVerticalAlignment {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        verticalAlignment = .middle
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let actualRect = self.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: actualRect)
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch self.verticalAlignment {
        case .top:
            textRect.origin.y = bounds.origin.y
        case .bottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
        case .middle:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0
        }
        return textRect
    }
}
