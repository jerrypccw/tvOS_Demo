//
//  Timer+JHPlayer.swift
//  JHPlayerView
//
//  Created by Jerry He on 2019/2/10.
//  Copyright © 2019年 jerry. All rights reserved.
//

import Foundation

extension Timer {
    class func jhPlayer_scheduledTimerWithTimeInterval(_ timeInterval: TimeInterval, block: @escaping ()->(), repeats: Bool) -> Timer {
        return self.scheduledTimer(timeInterval: timeInterval, target:
            self, selector: #selector(self.jhPlayer_blcokInvoke(_:)), userInfo: block, repeats: repeats)
    }
    
    @objc class func jhPlayer_blcokInvoke(_ timer: Timer) {
        let block: ()->() = timer.userInfo as! ()->()
        block()
    }
    
}
