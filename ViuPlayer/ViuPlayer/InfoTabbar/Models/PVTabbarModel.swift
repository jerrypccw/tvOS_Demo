//
//  ViuPlayerTabbarModel.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/12.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit
import Foundation

open class PVPlayerTabbarModel {
    
    var titleName: String
    
    init(name: String) {
        self.titleName = name
    }
}

//extension PVPlayerTabbarModel {
//    convenience init(title: String) {
//        self.init(name: title)
//    }
//}

open class PVIntroductionModel: PVPlayerTabbarModel {
    
    var imageUrl: String
    var dramaTitle: String
    var dramaDescription: String
    
    public init(title:String, imageUrl: String, dramaTitle: String, dramaDescription: String) {
        self.imageUrl = imageUrl
        self.dramaTitle = dramaTitle
        self.dramaDescription = dramaDescription
        super.init(name: title)
    }
}

public protocol PVSubtitleModelDelegate: NSObjectProtocol {
    func pvSubtitleSelectValue(_ string: String)
}

public extension PVSubtitleModelDelegate {
    func pvSubtitleSelectValue(_ string: String) {}
}


/// MARK
open class PVSubtitleModel: PVPlayerTabbarModel {
    
    var subtitles: [String]
    
    weak var delegate: PVSubtitleModelDelegate?
    
    public init(title: String, subtitles: [String], delegate: UIViewController) {
        self.subtitles = subtitles
        self.delegate = delegate as? PVSubtitleModelDelegate
        super.init(name: title)
    }
}


open class PVCustomModel: PVPlayerTabbarModel {
    
    var customs: [String]
    
    public init(title: String, customs: [String]) {
        self.customs = customs
        super.init(name: title)
    }
}


//open class PVAudioModel: PVPlayerTabbarModel {
//
//    var languages: [String] = []
//    var sounds: [String] = []
//    var speakers: [String] = []
//
//    public init(title: String, lang: [String], sound: [String], speaker: [String]) {
//        languages = lang
//        sounds = sound
//        speakers = speaker
//        super.init(name: title)
//    }
//}

public protocol PVAudioTableModelDelegate: NSObjectProtocol {
    func pvAudioTableSelectValue(_ string: String)
}

public extension PVAudioTableModelDelegate {
    func pvAudioTableSelectValue(_ string: String) {}
}

open class PVAudioTableModel {
    
    weak var delegate: PVAudioTableModelDelegate?
    var headTitle: String = ""
    var contents: [String] = []
    
    public init(headTitle: String, contents: [String], delegate: UIViewController) {
        self.headTitle = headTitle
        self.contents = contents
        self.delegate = delegate as? PVAudioTableModelDelegate
    }
}

open class PVAudioModel: PVPlayerTabbarModel {
    
    var audioModels: [PVAudioTableModel] = []
    
    public init(title: String, audioModels: [PVAudioTableModel]) {
        self.audioModels = audioModels
        super.init(name: title)
    }
}

