//
//  TimeInterval+Extension.swift
//  tvOS_demo
//
//  Created by TerryChe on 2019/12/4.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

extension TimeInterval {
    func formatToString() -> String {
        if isNaN {
            return "00:00"
        }
        let interval = Int(self)
        let sec = Int(truncatingRemainder(dividingBy: 60))
        let min = interval / 60
        return String(format: "%02d:%02d", min, sec)
    }
}
