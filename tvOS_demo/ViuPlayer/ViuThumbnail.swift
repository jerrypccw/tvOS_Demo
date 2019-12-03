//
//  JHThumbnail.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/30.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit
import Foundation
import CoreMedia

class ViuThumbnail: NSObject {
    
    var time: CMTime
    var image: UIImage
    
    override init() {
        time = CMTime.init()
        image = UIImage.init()
    }
}
