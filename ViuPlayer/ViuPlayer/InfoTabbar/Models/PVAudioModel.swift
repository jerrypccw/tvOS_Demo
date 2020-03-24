//
//  PVAudioModel.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/20.
//  Copyright © 2020 jerry. All rights reserved.
//

import Foundation


public protocol PVAudioTableModelDelegate: NSObjectProtocol {
    func pvAudioTableSelectValue(_ string: String)
}

public extension PVAudioTableModelDelegate {
    func pvAudioTableSelectValue(_ string: String) {}
}

public class PVAudioTableModel {
    
    weak var delegate: PVAudioTableModelDelegate?
    var headTitle: String = ""
    var contents: [String] = []
}

public class PVAudioCollectionModel: PVPlayerTabbarModel {
    
    var collections: [PVAudioTableModel] = []
}



