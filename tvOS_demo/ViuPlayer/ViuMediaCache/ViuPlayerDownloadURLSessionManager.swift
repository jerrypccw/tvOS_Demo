//
//  ViuPlayerDownloadURLSessionManager.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/4.
//  Copyright © 2020 jerry. All rights reserved.
//

import Foundation

public protocol ViuPlayerDownloadeURLSessionManagerDelegate: NSObjectProtocol {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}

open class ViuPlayerDownloadURLSessionManager: NSObject, URLSessionDataDelegate {
    
    fileprivate let kBufferSize = 10 * 1024
    fileprivate var bufferData = NSMutableData()
    fileprivate let bufferDataQueue = DispatchQueue(label: "com.Viuplayer.bufferDataQueue")
    
    open weak var delegate: ViuPlayerDownloadeURLSessionManagerDelegate?
    
    public init(delegate: ViuPlayerDownloadeURLSessionManagerDelegate?) {
        self.delegate = delegate
        super.init()
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        delegate?.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bufferDataQueue.sync {
            bufferData.append(data)
            if self.bufferData.length > kBufferSize {
                let chunkRange = NSRange(location: 0, length: self.bufferData.length)
                let chunkData = bufferData.subdata(with: chunkRange)
                bufferData.replaceBytes(in: chunkRange, withBytes: nil, length: 0)
                delegate?.urlSession(session, dataTask: dataTask, didReceive: chunkData)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        bufferDataQueue.sync {
            if bufferData.length > 0 && error == nil {
                let chunkRange = NSRange(location: 0, length: bufferData.length)
                let chunkData = bufferData.subdata(with: chunkRange)
                bufferData.replaceBytes(in: chunkRange, withBytes: nil, length: 0)
                delegate?.urlSession(session, dataTask: task as! URLSessionDataTask, didReceive: chunkData)
            }
        }
        delegate?.urlSession(session, task: task, didCompleteWithError: error)
    }
}
