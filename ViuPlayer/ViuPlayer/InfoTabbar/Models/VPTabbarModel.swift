//
//  ViuPlayerTabbarModel.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/12.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit
import Foundation

open class VPPlayerTabbarModel {
    
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

open class VPIntroductionModel: VPPlayerTabbarModel {
    
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

public protocol VPSubtitleModelDelegate: NSObjectProtocol {
    func pvSubtitleSelectValue(_ string: String)
}

public extension VPSubtitleModelDelegate {
    func pvSubtitleSelectValue(_ string: String) {}
}


/// MARK
open class VPSubtitleModel: VPPlayerTabbarModel {
    
    var subtitles: [String]
    
    weak var delegate: VPSubtitleModelDelegate?
    
    public init(title: String, subtitles: [String], delegate: UIViewController) {
        self.subtitles = subtitles
        self.delegate = delegate as? VPSubtitleModelDelegate
        super.init(name: title)
    }
}


open class VPCustomModel: VPPlayerTabbarModel {
    
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

public protocol VPAudioTableModelDelegate: NSObjectProtocol {
    func pvAudioTableSelectValue(_ string: String)
}

public extension VPAudioTableModelDelegate {
    func pvAudioTableSelectValue(_ string: String) {}
}

open class VPAudioTableModel {
    
    weak var delegate: VPAudioTableModelDelegate?
    var headTitle: String = ""
    var contents: [String] = []
    
    public init(headTitle: String, contents: [String], delegate: UIViewController) {
        self.headTitle = headTitle
        self.contents = contents
        self.delegate = delegate as? VPAudioTableModelDelegate
    }
}

open class VPAudioModel: VPPlayerTabbarModel {
    
    var audioModels: [VPAudioTableModel] = []
    
    public init(title: String, audioModels: [VPAudioTableModel]) {
        self.audioModels = audioModels
        super.init(name: title)
    }
}

