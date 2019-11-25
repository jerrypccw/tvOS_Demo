//
//  JHPlayerError.swift
//  JHPlayerView
//
//  Created by Jerry He on 2019/2/10.
//  Copyright © 2019年 jerry. All rights reserved.
//

import Foundation
import AVFoundation

public struct JHPlayerError: CustomStringConvertible {
    var error : Error?
    var playerItemErrorLogEvent : [AVPlayerItemErrorLogEvent]?
    var extendedLogData : Data?
    var extendedLogDataStringEncoding : UInt?
    
    public var description: String {
        return "Player Log -------------------------- \n error: \(String(describing: error))\n playerItemErrorLogEvent: \(String(describing: playerItemErrorLogEvent))\n extendedLogData: \(String(describing: extendedLogData))\n extendedLogDataStringEncoding \(String(describing: extendedLogDataStringEncoding))\n --------------------------"
    }
}
