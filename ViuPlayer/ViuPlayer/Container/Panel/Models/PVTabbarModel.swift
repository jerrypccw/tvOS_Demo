//
//  ViuPlayerTabbarModel.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/12.
//  Copyright © 2019 jerry. All rights reserved.
//

import Foundation

public class PVPlayerTabbarModel: NSObject {
    
    var titleName: String
    
    override init() {
        titleName = ""
    }
}

public class PVIntroductionModel: PVPlayerTabbarModel {
    
    var imageUrl: String
    var dramaTitle: String
    var dramaDescription: String
    
    override init() {
        imageUrl = ""
        dramaTitle = ""
        dramaDescription = ""
    }
}

public protocol PVSubtitleModelDelegate: NSObjectProtocol {
    func pvSubtitleSelectValue(_ string: String)
}

public extension PVSubtitleModelDelegate {
    func pvSubtitleSelectValue(_ string: String) {}
}

public class PVSubtitleModel: PVPlayerTabbarModel {
    
    var subtitles: [String]
    
    weak var delegate: PVSubtitleModelDelegate?
    
    override init() {
        subtitles = ["未知语言"]
    }
}


public class PVCustomModel: PVPlayerTabbarModel {
    
    var customs: [String]
    
    override init() {
        customs = ["开关"]
    }
}


public class PVAudioModel: PVPlayerTabbarModel {
    
    var languages: [String]
    var sounds: [String]
    var speaker: [String]
    
    override init() {
        languages = ["未知"]
        sounds = ["完整动态范围"]
        speaker = ["设备名称"]
    }
}



