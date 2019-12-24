//
//  ViuTapGestureRecogniser.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/12/20.
//  Copyright © 2019 jerry. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class ViuTapGestureRecogniser: UITapGestureRecognizer {
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        presses.forEach { (press) in
            if press.isSynthetic { ignore(press, for: event) }
        }
        super.pressesBegan(presses, with: event)
    }
}

extension UIPress {
    @nonobjc var isSynthetic: Bool {
        guard let value = value(forKey: "_isSynthetic") as? Bool else { return false }
        return value
    }
}
