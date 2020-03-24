//
//  PVAudioViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/19.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

let PVAUDIO_CELL = "PVAUDIOCELL"

class PVAudioViewController: UIViewController {
    
    var model: PVAudioCollectionModel? {
        didSet {
            title = "音频"
            collectionView.reloadData()
        }
    }
    
    lazy var tableContentHeights:[CGFloat] = []
    
    private var collectionHeightConstraint: NSLayoutConstraint!
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [collectionView]
    }
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionLayout)
        view.backgroundColor = UIColor.clear
        view.register(PVAudioCell.self, forCellWithReuseIdentifier: PVAUDIO_CELL)
        view.delegate = self
        view.dataSource = self
        if #available(tvOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never /// 清除顶部留白
        }
        view.isScrollEnabled = false
        return view
    }()
    
    lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 240, bottom: 0, right: 200)
        layout.itemSize.width = 360
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCollectionView()
        refreshLayout()
    }
    
    private func refreshLayout() {
        
        collectionView.layoutIfNeeded()
        let tableHeight = getArrayMaxOne(tableContentHeights)
        collectionHeightConstraint.constant = tableHeight
        
        if tableHeight > 560 {
            preferredContentSize = CGSize(width: 1720, height: 560)
        } else {
            preferredContentSize = CGSize(width: 1720, height: collectionHeightConstraint.constant + 120)
        }
    }
    
    private func getArrayMaxOne<T:Comparable>(_ seq:[T]) ->T{
        assert(seq.count > 0)
        return seq.reduce(seq[0]){ max($0, $1) }
    }
    
    private func addCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        collectionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 300)
        collectionHeightConstraint.priority = .defaultLow
        collectionHeightConstraint.isActive = true
    }
}

extension PVAudioViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.collections.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PVAUDIO_CELL, for: indexPath) as! PVAudioCell
        cell.data = model?.collections[indexPath.row]
        tableContentHeights.append(cell.tableView.contentSize.height)
        return cell
    }
    
}

extension PVAudioViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

