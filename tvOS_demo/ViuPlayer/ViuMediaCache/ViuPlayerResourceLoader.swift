//
//  ViuPlayerResourceLoader.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/1/22.
//  Copyright © 2020 jerry. All rights reserved.
//

import Foundation
import AVFoundation

public protocol ViuPlayerResourceLoaderDelegate: class {
    func resourceLoader(_ resourceLoader: ViuPlayerResourceLoader, didFailWithError  error:Error?)
}

open class ViuPlayerResourceLoader: NSObject {
    open fileprivate(set) var url: URL
    open weak var delegate: ViuPlayerResourceLoaderDelegate?
    
    fileprivate var downloader: ViuPlayerDownloader
    fileprivate var pendingRequestWorkers = Dictionary<String ,ViuPlayerResourceLoadingRequest>()
    fileprivate var isCancelled: Bool = false
    
    deinit {
        downloader.invalidateAndCancel()
    }
    
    public init(url: URL) {
        self.url = url
        downloader = ViuPlayerDownloader(url: url)
        super.init()
    }
    
    open func add(_ request: AVAssetResourceLoadingRequest) {
        for (_, value) in pendingRequestWorkers {
            value.cancel()
            value.finish()
        }
        pendingRequestWorkers.removeAll()
        startWorker(request)
    }
    
    open func remove(_ request: AVAssetResourceLoadingRequest) {
        let key = self.key(forRequest: request)
        let loadingRequest = ViuPlayerResourceLoadingRequest(downloader, request)
        loadingRequest.finish()
        pendingRequestWorkers.removeValue(forKey: key)
    }
    
    open func cancel() {
        downloader.cancel()
    }
    
    internal func startWorker(_ request: AVAssetResourceLoadingRequest) {
        let key = self.key(forRequest: request)
        let loadingRequest = ViuPlayerResourceLoadingRequest(downloader, request)
        loadingRequest.delegate = self
        pendingRequestWorkers[key] = loadingRequest
        loadingRequest.startWork()
    }
    
    internal func key(forRequest request: AVAssetResourceLoadingRequest) -> String {
        
        if let range = request.request.allHTTPHeaderFields!["Range"]{
            return String(format: "%@%@", (request.request.url?.absoluteString)!, range)
        }
        
        return String(format: "%@", (request.request.url?.absoluteString)!)
    }
}

// MARK: - ViuPlayerResourceLoadingRequestDelegate
extension ViuPlayerResourceLoader: ViuPlayerResourceLoadingRequestDelegate {
    public func resourceLoadingRequest(_ resourceLoadingRequest: ViuPlayerResourceLoadingRequest, didCompleteWithError error: Error?) {
        remove(resourceLoadingRequest.request)
        if error != nil {
            delegate?.resourceLoader(self, didFailWithError: error)
        }
    }
    
}

