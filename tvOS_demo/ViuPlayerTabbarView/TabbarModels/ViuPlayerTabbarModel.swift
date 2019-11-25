//
//  ViuPlayerTabbarModel.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/12.
//  Copyright © 2019 jerry. All rights reserved.
//

import Foundation

class ViuPlayerTabbarModel: NSObject {
    
    var buttonName: String
    
    override init() {
        buttonName = ""
    }
}

class TabbarIntroductionModel: ViuPlayerTabbarModel {
    
    var imageUrl: String
    var dramaTitle: String
    var dramaDescription: String
    
    override init() {
        imageUrl = ""
        dramaTitle = ""
        dramaDescription = ""
    }
}

class TabbarSubtitleModel: ViuPlayerTabbarModel {
    
    var subtitles: [String]
    
    override init() {
        subtitles = ["关闭"]
    }
}

class TabbarCustomModel: ViuPlayerTabbarModel {
    
    var customs: [String]
    
    override init() {
        customs = ["开关"]
    }
}


