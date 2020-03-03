//
//  ViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/9/27.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let btn = UIButton.init(type: .custom)
    
    let btn2 = UIButton.init(type: .custom)
    
    let btn3 = UIButton.init(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        btn.setTitle("play movie", for: .normal)
        btn.setTitle("play movie", for: .focused)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.blue, for: .focused)
        btn.addTarget(self, action: #selector(gotoPlayerVC), for: .primaryActionTriggered)
        
        view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        btn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 200).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        btn2.setTitle("play movie2", for: .normal)
        btn2.setTitle("play movie2", for: .focused)
        btn2.setTitleColor(.black, for: .normal)
        btn2.setTitleColor(.blue, for: .focused)
        btn2.addTarget(self, action: #selector(gotoPlayerVC2), for: .primaryActionTriggered)
        
        view.addSubview(btn2)
        btn2.translatesAutoresizingMaskIntoConstraints = false
        btn2.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        btn2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btn2.widthAnchor.constraint(equalToConstant: 300).isActive = true
        btn2.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        btn3.setTitle("play movie3", for: .normal)
        btn3.setTitle("play movie3", for: .focused)
        btn3.setTitleColor(.black, for: .normal)
        btn3.setTitleColor(.blue, for: .focused)
        btn3.addTarget(self, action: #selector(gotoPlayerVC3), for: .primaryActionTriggered)
        
        view.addSubview(btn3)
        btn3.translatesAutoresizingMaskIntoConstraints = false
        btn3.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100).isActive = true
        btn3.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btn3.widthAnchor.constraint(equalToConstant: 300).isActive = true
        btn3.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
    }
    
    
    @objc func gotoPlayerVC() {
        navigationController?.pushViewController(ViuPlayerViewController(), animated: true)
        //        self.present(ViuPlayerViewController(), animated: true, completion: nil)
    }
    
    @objc func gotoPlayerVC2() {
        navigationController?.pushViewController(VPlayerViewController(), animated: true)
        //        self.present(ViuPlayerViewController(), animated: true, completion: nil)
    }
    
    @objc func gotoPlayerVC3() {
        navigationController?.pushViewController(PlayerViewController(), animated: true)
        //        self.present(ViuPlayerViewController(), animated: true, completion: nil)
    }
    
    
}
