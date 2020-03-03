//
//  ViuPlayerCacheSession.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/4.
//  Copyright © 2020 jerry. All rights reserved.
//

import Foundation

open class ViuPlayerCacheSession: NSObject {
    public fileprivate(set) var downloadQueue: OperationQueue
    static let shared = ViuPlayerCacheSession()
    
    public override init() {
        let queue = OperationQueue()
        queue.name = "com.Viuplayer.downloadSession"
        downloadQueue = queue
    }
}
