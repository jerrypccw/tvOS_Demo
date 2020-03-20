//
//  TestViuPlayerViewController.swift
//  tvOS_demo
//
//  Created by TerryChe on 2020/3/20.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit
import ViuPlayer

class TestViuPlayerViewController: ViuPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupPlayerURL(url)
        setupPlayback()
    }
}
