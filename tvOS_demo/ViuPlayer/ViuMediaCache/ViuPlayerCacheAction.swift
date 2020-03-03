//
//  ViuPlayerCacheAction.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/4.
//  Copyright © 2020 jerry. All rights reserved.
//

import Foundation

public enum ViuPlayerCacheActionType: Int {
    case local
    case remote
}

public struct ViuPlayerCacheAction: Hashable, CustomStringConvertible {
    public var type: ViuPlayerCacheActionType
    public var range: NSRange
    
    public var description: String {
        return "type: \(type)  range:\(range)"
    }
    
    public var hashValue: Int {
        return String(format: "%@%@", NSStringFromRange(range), String(describing: type)).hashValue
    }
    
    public static func ==(lhs: ViuPlayerCacheAction, rhs: ViuPlayerCacheAction) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    init(type: ViuPlayerCacheActionType, range: NSRange) {
        self.type = type
        self.range = range
    }
    
}
