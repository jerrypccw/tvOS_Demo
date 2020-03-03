//
//  PlayerViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/19.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    
    // 使用PUSH转跳需要添加一下代码，不然会丢失焦点
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }



}
