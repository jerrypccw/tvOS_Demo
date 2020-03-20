//
//  TimeInterval+Extension.swift
//  ViuPlayer
//
//  Created by TerryChe on 2020/3/20.
//  Copyright © 2020 TerryChe. All rights reserved.
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
