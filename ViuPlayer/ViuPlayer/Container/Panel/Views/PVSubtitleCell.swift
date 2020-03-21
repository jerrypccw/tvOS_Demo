//
//  PVSubtitleCell.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/13.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

class PVSubtitleCell: UICollectionViewCell {
        
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        subtitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
                
    }
    
    open override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
    
        if self == context.nextFocusedView {
            subtitleLabel.textColor = .white
        } else if self == context.previouslyFocusedView {
            subtitleLabel.textColor = .black
        }
    }
}
