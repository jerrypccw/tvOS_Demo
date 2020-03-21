//
//  PVSubtitleViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/12.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit
/// 定义重用标识
let PVSUBTITLE_CELL = "PVSUBTITLE_CELL"

class PVSubtitleViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var model: TabbarSubtitleModel? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [collectionView]
    }

    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionLayout)
        view.backgroundColor = UIColor.clear
        view.register(PVSubtitleCell.self, forCellWithReuseIdentifier: PVSUBTITLE_CELL)
        view.delegate = self
        view.dataSource = self
        if #available(tvOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never /// 清除顶部留白
        }
        return view
    }()
    
    lazy var collectionLayout: PVCenterFlowLayout = {
        let layout = PVCenterFlowLayout()
        layout.itemWidth = 100.0
        layout.itemHeight = 60.0
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: 1720, height: 180)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.subtitles.count ?? 0
    }
    
    /// 返回UICollectionViewCell视图
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PVSUBTITLE_CELL, for: indexPath) as! PVSubtitleCell
        cell.subtitleLabel.text = model?.subtitles[indexPath.row]
        return cell
    }
    
    
}
