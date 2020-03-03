//
//  ViuPlayerDownloader.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/4.
//  Copyright © 2020 jerry. All rights reserved.
//

import Foundation
import MobileCoreServices

// MARK: - ViuPlayerDownloader
open class ViuPlayerDownloader: NSObject {
    open fileprivate(set) var url: URL
    open weak var delegate: ViuPlayerDownloaderDelegate?
    open var cacheMedia: ViuPlayerCacheMedia?
    open var cacheMediaWorker: ViuPlayerCacheMediaWorker
    
    fileprivate var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    fileprivate var isDownloadToEnd: Bool = false
    fileprivate var actionWorker: ViuPlayerDownloadActionWorker?
    
    deinit {
        ViuPlayerDownloaderStatus.shared.remove(URL: url)
    }
    
    public init(url: URL) {
        self.url = url
        cacheMediaWorker = ViuPlayerCacheMediaWorker(url: url)
        cacheMedia = cacheMediaWorker.cacheConfiguration?.cacheMedia
        super.init()
    }
    
    open func dowloaderTask(_ fromOffset: Int64, _ length: Int, _ isEnd: Bool) {
        if isCurrentURLDownloading() {
            handleCurrentURLDownloadingError()
            return
        }
        ViuPlayerDownloaderStatus.shared.add(URL: self.url)
        
        var range = NSRange(location: Int(fromOffset), length: length)
        if isEnd {
            if let contentLength = cacheMediaWorker.cacheConfiguration?.cacheMedia?.contentLength {
                range.length = Int(contentLength) - range.location
            } else {
                range.length = 0 - range.location
            }
            
        }
        let actions = cacheMediaWorker.cachedDataActions(forRange: range)
        actionWorker = ViuPlayerDownloadActionWorker(actions: actions, url: url, cacheMediaWorker: cacheMediaWorker)
        actionWorker?.delegate = self
        actionWorker?.start()
    }
    open func dowloadFrameStartToEnd() {
        if isCurrentURLDownloading() {
            handleCurrentURLDownloadingError()
            return
        }
        ViuPlayerDownloaderStatus.shared.add(URL: url)
        
        isDownloadToEnd = true
        let range = NSRange(location: 0, length: 2)
        let actions = cacheMediaWorker.cachedDataActions(forRange: range)
        actionWorker = ViuPlayerDownloadActionWorker(actions: actions, url: url, cacheMediaWorker: cacheMediaWorker)
        actionWorker?.delegate = self
        actionWorker?.start()
        
        
    }
    open func cancel() {
        ViuPlayerDownloaderStatus.shared.remove(URL: url)
        actionWorker?.cancel()
        actionWorker?.delegate = nil
        actionWorker = nil
    }
    
    open func invalidateAndCancel() {
        ViuPlayerDownloaderStatus.shared.remove(URL: url)
        actionWorker?.cancel()
        actionWorker?.delegate = nil
        actionWorker = nil
    }
    
    // check
    internal func isCurrentURLDownloading() -> Bool {
        return ViuPlayerDownloaderStatus.shared.contains(URL: url)
    }
    
    internal func handleCurrentURLDownloadingError() {
        
        if isCurrentURLDownloading() {
            let userInfo = [NSLocalizedDescriptionKey: "URL: \(url) alreay in downloading queue."]
            let error = NSError(domain: "com.Viuplayer.download", code: -1, userInfo: userInfo)
            delegate?.downloader(self, didFinishedWithError: error as Error)
        }
    }
}

// MARK: - ViuPlayerDownloaderStatus
public struct ViuPlayerDownloaderStatus {
    
    static let shared = ViuPlayerDownloaderStatus()
    fileprivate var downloadingURLs: NSMutableSet
    fileprivate let downloaderStatusQueue = DispatchQueue(label: "com.Viuplayer.downloaderStatusQueue")
    
    init() {
        downloadingURLs = NSMutableSet()
    }
    
    public func add(URL: URL) {
        downloaderStatusQueue.sync {
            downloadingURLs.add(URL)
        }
    }
    
    public func remove(URL: URL) {
        downloaderStatusQueue.sync {
            downloadingURLs.remove(URL)
        }
    }
    
    public func contains(URL: URL) -> Bool{
        return downloadingURLs.contains(URL)
    }
    
    public func urls() -> NSSet {
        return downloadingURLs.copy() as! NSSet
    }
}

public protocol ViuPlayerDownloaderDelegate: class {
    func downloader(_ downloader: ViuPlayerDownloader, didReceiveResponse response: URLResponse)
    func downloader(_ downloader: ViuPlayerDownloader, didReceiveData data: Data)
    func downloader(_ downloader: ViuPlayerDownloader, didFinishedWithError error: Error?)
}


extension ViuPlayerDownloaderDelegate {
    public func downloader(_ downloader: ViuPlayerDownloader, didReceiveResponse response: URLResponse) { }
    public func downloader(_ downloader: ViuPlayerDownloader, didReceiveData data: Data) { }
    public func downloader(_ downloader: ViuPlayerDownloader, didFinishedWithError error: Error?) { }
}


// MARK: - ViuPlayerDownloadActionWorkerDelegate
extension ViuPlayerDownloader: ViuPlayerDownloadActionWorkerDelegate {
    
    public func downloadActionWorker(_ actionWorker: ViuPlayerDownloadActionWorker, didFinishWithError error: Error?) {
        ViuPlayerDownloaderStatus.shared.remove(URL: url)
        if error == nil && isDownloadToEnd {
            isDownloadToEnd = false
            let length = (cacheMediaWorker.cacheConfiguration?.cacheMedia?.contentLength)! - 2
            dowloaderTask(2, Int(length), true)
        } else {
            delegate?.downloader(self, didFinishedWithError: error)
        }
    }
    
    public func downloadActionWorker(_ actionWorker: ViuPlayerDownloadActionWorker, didReceive data: Data, isLocal: Bool) {
        delegate?.downloader(self, didReceiveData: data)
    }
    
    public func downloadActionWorker(_ actionWorker: ViuPlayerDownloadActionWorker, didReceive response: URLResponse) {
        if cacheMedia == nil {
            let cacheMedia = ViuPlayerCacheMedia()
            if response.isKind(of: HTTPURLResponse.classForCoder()) {
                
                let HTTPurlResponse = response as! HTTPURLResponse                                  // set header
                let acceptRange = HTTPurlResponse.allHeaderFields["Accept-Ranges"] as? String
                if let bytes = acceptRange?.isEqual("bytes") {
                    cacheMedia.isByteRangeAccessSupported = bytes
                }
                // fix swift allHeaderFields NO! case insensitive
                let contentRange = HTTPurlResponse.allHeaderFields["content-range"] as? String
                let contentRang = HTTPurlResponse.allHeaderFields["Content-Range"] as? String
                if let last = contentRange?.components(separatedBy: "/").last {
                    cacheMedia.contentLength = Int64(last)!
                }
                if let last = contentRang?.components(separatedBy: "/").last {
                    cacheMedia.contentLength = Int64(last)!
                }
                
            }
            if let mimeType = response.mimeType {
                let contentType =  UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
                if let takeUnretainedValue = contentType?.takeUnretainedValue() {
                    cacheMedia.contentType = takeUnretainedValue as String
                }
            }
            self.cacheMedia = cacheMedia
            let isSetCacheMedia = cacheMediaWorker.set(cacheMedia: cacheMedia)
            if !isSetCacheMedia {
                let nsError = NSError(domain: "com.Viuplayer.cacheMedia", code: -1, userInfo: [NSLocalizedDescriptionKey:"Set cache media failed."])
                delegate?.downloader(self, didFinishedWithError: nsError as Error)
                return
            }
        }
        delegate?.downloader(self, didReceiveResponse: response)
    }
}
