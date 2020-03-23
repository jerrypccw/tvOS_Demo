//
//  PVAudioModel.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/20.
//  Copyright © 2020 jerry. All rights reserved.
//

import Foundation

public class PVAudioCollectionModel {    
    var collections: [PVAudioTableModel] = []
}

public class PVAudioTableModel {
    
    weak var delegate: PVAudioTableModelDelegate?
    var headTitle: String = ""
    var contents: [String] = []
}


public protocol PVAudioTableModelDelegate: NSObjectProtocol {
    func pvAudioTableSelectValue(_ string: String)
}

public extension PVAudioTableModelDelegate {
    func pvAudioTableSelectValue(_ string: String) {}
}
