//
//  ViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/9/27.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton.init(type: .custom)
        btn.setTitle("play movie", for: .normal)
        btn.setTitle("play movie", for: .focused)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.blue, for: .focused)
        btn.addTarget(self, action: #selector(gotoPlayerVC), for: .primaryActionTriggered)
        
        view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        btn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 200).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    @objc func gotoPlayerVC() {
//        navigationController?.pushViewController(ViuPlayerViewController(), animated: true)
        self.present(ViuPlayerViewController(), animated: true, completion: nil)
    }
    
}
