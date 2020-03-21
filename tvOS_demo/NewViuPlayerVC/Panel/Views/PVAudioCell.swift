//
//  PVAudioCell.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/19.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

let PVAVDIO_TABLECELL = "PVAVDIOTABLECELL"

class PVAudioCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [tableView]
    }
    
    lazy var tableView: UITableView = {
        let view = UITableView.init(frame: CGRect.zero, style: .plain)
        view.register(PVAudioTableCell.self, forCellReuseIdentifier: PVAVDIO_TABLECELL)
        view.delegate = self
        view.dataSource = self
        view.estimatedRowHeight = 50
        return view
    }()
    
    var data: PVAudioTableModel? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 180).isActive = true
        tableView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.contents.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PVAVDIO_TABLECELL) as! PVAudioTableCell
        cell.textLabel?.text = data?.contents[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let titleLab = UILabel()
        titleLab.numberOfLines = 0
        titleLab.font = UIFont.systemFont(ofSize: 24)
        titleLab.textColor = UIColor.black.withAlphaComponent(0.8)
        titleLab.sizeToFit()
        titleLab.text = data?.headTitle
        
        view.addSubview(titleLab)
        titleLab.translatesAutoresizingMaskIntoConstraints = false
        titleLab.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        titleLab.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        titleLab.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true

        return view
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
