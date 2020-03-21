//
//  PVAudioTableCell.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/19.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

class PVAudioTableCell: UITableViewCell {
    
    open override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if self == context.nextFocusedView {
            textLabel?.textColor = .white
        } else if self == context.previouslyFocusedView {
            textLabel?.textColor = .black
        }
    }
}
