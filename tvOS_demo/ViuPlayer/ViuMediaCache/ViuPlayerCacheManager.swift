//
//  ViuPlayerCacheManager.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/4.
//  Copyright © 2020 jerry. All rights reserved.
//

import Foundation

public extension Notification.Name {
    
    static var ViuPlayerCacheManagerDidUpdateCache = Notification.Name.init("com.vein.Viuplayer.CacheManagerDidUpdateCache")
    static var ViuPlayerCacheManagerDidFinishCache = Notification.Name.init("com.vein.Viuplayer.CacheManagerDidFinishCache")
    static var ViuPlayerCacheManagerDidCleanCache = Notification.Name.init("com.vein.Viuplayer.CacheManagerDidCleanCache")
}

open class ViuPlayerCacheConfiguration: NSObject {
    
    open var maxCacheAge: TimeInterval = 60 * 60 * 24 * 7 // 1 week

    open var maxCacheSize: UInt = 0
}


open class ViuPlayerCacheManager: NSObject {
    
    static public let ViuPlayerCacheConfigurationKey: String = "ViuPlayerCacheConfigurationKey"
    static public let ViuPlayerCacheErrorKey: String = "ViuPlayerCacheErrorKey"
    static public let ViuPlayerCleanCacheKey: String = "ViuPlayerCleanCacheKey"
    
    public static var mediaCacheNotifyInterval = 0.1
    
    fileprivate let ioQueue = DispatchQueue(label: "com.Viuplayer.ioQueue")
    fileprivate var fileManager: FileManager!
    
    public static let shared = ViuPlayerCacheManager()
    open private(set) var cacheConfig = ViuPlayerCacheConfiguration()
    
    public override init() {
        super.init()
        ioQueue.sync { fileManager = FileManager() }
    }
    
    static public func cacheDirectory() -> String {
        return NSTemporaryDirectory().appending("ViuplayerCache")
    }
    
    static public func cacheFilePath(for url: URL) -> String {
        if let cacheFolder = url.lastPathComponent.components(separatedBy: ".").first {
            let cacheFilePath = (cacheDirectory().appending("/\(cacheFolder)") as NSString).appendingPathComponent(url.lastPathComponent)
            print(cacheFilePath)
            return cacheFilePath
        }
        
        return (cacheDirectory() as NSString).appendingPathComponent(url.lastPathComponent)
    }
    
    static public func cacheConfiguration(forURL url: URL) -> ViuPlayerCacheMediaConfiguration {
        let filePath = cacheFilePath(for: url)
        let configuration = ViuPlayerCacheMediaConfiguration.configuration(filePath: filePath)
        return configuration
    }
    
    open func calculateCacheSize(completion handler: @escaping ((_ size: UInt) -> ())) {
        ioQueue.async {
            let cacheDirectory = ViuPlayerCacheManager.cacheDirectory()
            let (_, diskCacheSize, _) = self.cachedFiles(atPath: cacheDirectory, onlyForCacheSize: true)
            DispatchQueue.main.async {
                handler(diskCacheSize)
            }
        }
    }
    
    open func cleanAllCache() {
        ioQueue.sync {
            do {
                let cacheDirectory = ViuPlayerCacheManager.cacheDirectory()
                try fileManager.removeItem(atPath: cacheDirectory)
            } catch { }
        }
    }
    
    open func cleanOldFiles(completion handler: (()->())? = nil) {
        ioQueue.sync {
            let cacheDirectory = ViuPlayerCacheManager.cacheDirectory()
            var (URLsToDelete, diskCacheSize, cachedFiles) = self.cachedFiles(atPath: cacheDirectory, onlyForCacheSize: false)
            
            for fileURL in URLsToDelete {
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch _ { }
            }
            
            if cacheConfig.maxCacheSize > 0 && diskCacheSize > cacheConfig.maxCacheSize {
                let targetSize = cacheConfig.maxCacheSize / 2
                
                let sortedFiles = cachedFiles.keysSortedByValue {
                    resourceValue1, resourceValue2 -> Bool in
                    
                    if let date1 = resourceValue1.contentAccessDate,
                        let date2 = resourceValue2.contentAccessDate
                    {
                        return date1.compare(date2) == .orderedAscending
                    }
                    
                    return true
                }
                
                for fileURL in sortedFiles {
                    let (_, cacheSize, _) = self.cachedFiles(atPath: fileURL.path, onlyForCacheSize: true)
                    diskCacheSize -= cacheSize
                    
                    do {
                        try fileManager.removeItem(at: fileURL)
                    } catch { }
                    
                    URLsToDelete.append(fileURL)
                    
                    if diskCacheSize < targetSize {
                        break
                    }
                }
            }
            
            DispatchQueue.main.async {
                
                if URLsToDelete.count != 0 {
                    let cleanedHashes = URLsToDelete.map { $0.lastPathComponent }
                    NotificationCenter.default.post(name: .ViuPlayerCacheManagerDidCleanCache, object: self, userInfo: [ViuPlayerCacheManager.ViuPlayerCleanCacheKey: cleanedHashes])
                }
                
                handler?()
            }
        }
    }
    
    fileprivate func cachedFiles(atPath path: String, onlyForCacheSize: Bool) -> (urlsToDelete: [URL], diskCacheSize: UInt, cachedFiles: [URL: URLResourceValues]) {
        
        let expiredDate: Date? = (cacheConfig.maxCacheAge < 0) ? nil : Date(timeIntervalSinceNow: -cacheConfig.maxCacheAge)
        
        var cachedFiles = [URL: URLResourceValues]()
        var urlsToDelete = [URL]()
        var diskCacheSize: UInt = 0
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        let fullPath = (path as NSString).expandingTildeInPath
        do {
            let url = URL(fileURLWithPath: fullPath)
            
            if let directoryEnumerator = fileManager.enumerator(at:url, includingPropertiesForKeys: Array(resourceKeys), options: [.skipsHiddenFiles], errorHandler: nil) {
                for (_ , value) in directoryEnumerator.enumerated() {
                    do {
                        if let fileURL = value as? URL{
                            let resourceValues = try fileURL.resourceValues(forKeys: resourceKeys)
                            
                            if !onlyForCacheSize,
                                let expiredDate = expiredDate,
                                let lastAccessData = resourceValues.contentAccessDate,
                                (lastAccessData as NSDate).laterDate(expiredDate) == expiredDate
                            {
                                urlsToDelete.append(fileURL)
                                continue
                            }
                            
                            
                            if !onlyForCacheSize && resourceValues.isDirectory == true {
                                cachedFiles[fileURL] = resourceValues
                            }
                            
                            if let size = resourceValues.totalFileAllocatedSize {
                                diskCacheSize += UInt(size)
                            }
                        }
                    } catch { }
                }
            }
        }
        return (urlsToDelete, diskCacheSize, cachedFiles)
        
    }
    
    
}

extension Dictionary {
    func keysSortedByValue(_ isOrderedBefore: (Value, Value) -> Bool) -> [Key] {
        return Array(self).sorted{ isOrderedBefore($0.1, $1.1) }.map{ $0.0 }
    }
}
