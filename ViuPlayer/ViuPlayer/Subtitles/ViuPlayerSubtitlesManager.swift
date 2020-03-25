//
//  ViuPlayerSubtitlesView.swift
//  ViuPlayer
//
//  Created by TerryChe on 2020/3/23.
//  Copyright © 2020 TerryChe. All rights reserved.
//

import UIKit

class ViuPlayerSubtitlesManager {

    var firstSubtitles: ViuSubtitles?
    let firstSubtitlesLabel = ViuCustomLabel()
    
    var secondSubtitles: ViuSubtitles?
    let secondSubtitlesLabel = ViuCustomLabel()
    var secondSubtitlesTopAnchor: NSLayoutConstraint?
    var secondSubtitlesBottonAnchor: NSLayoutConstraint?
    
    open var currentDuration: TimeInterval = 0.0 {
        didSet {
            if let sub = firstSubtitles?.search(for: currentDuration) {
                firstSubtitlesLabel.isHidden = false
                firstSubtitlesLabel.text = sub.content
                firstSubtitlesLabel.sizeToFit()
                
                firstSubtitlesLabel.backgroundColor = .clear
            } else {
//                firstSubtitlesLabel.isHidden = true
                
                firstSubtitlesLabel.text = " "
                firstSubtitlesLabel.sizeToFit()
                firstSubtitlesLabel.backgroundColor = .yellow
            }
            
            if let sub = secondSubtitles?.search(for: currentDuration) {
                secondSubtitlesLabel.isHidden = false
                secondSubtitlesLabel.text = sub.content
                secondSubtitlesLabel.sizeToFit()
                
                secondSubtitlesLabel.backgroundColor = .clear
            } else {
//                secondSubtitlesLabel.isHidden = true
                
                secondSubtitlesLabel.text = " "
                secondSubtitlesLabel.sizeToFit()
                secondSubtitlesLabel.backgroundColor = .red
            }
            
            //Test
//            firstSubtitlesLabel.isHidden = false
//            firstSubtitlesLabel.backgroundColor = .yellow
//            firstSubtitlesLabel.text = "1111111111111111111111"
//            firstSubtitlesLabel.sizeToFit()
//
//            secondSubtitlesLabel.isHidden = false
//            secondSubtitlesLabel.backgroundColor = .red
//            secondSubtitlesLabel.text = "2222222222222222222222"
//            secondSubtitlesLabel.sizeToFit()
        }
    }
    
    open var secondSubtitlesPosition: Int = 0 {
        didSet {
            secondSubtitlesTopAnchor?.isActive = secondSubtitlesPosition == 0
            secondSubtitlesBottonAnchor?.isActive = !(secondSubtitlesTopAnchor?.isActive ?? true)
        }
    }
    
    open func configurationUI(_ view: UIView) {
        setupFirstSubtitle(view)
        setupSecondSubtitle(view)
    }
    
    open func setSubtitles(first: ViuSubtitles, second: ViuSubtitles?) {
        self.firstSubtitles = first
        
        guard let second = second else {
            return
        }
        self.secondSubtitles = second
    }
    
    private func setupFirstSubtitle(_ view: UIView) {
        firstSubtitlesLabel.font = UIFont.boldSystemFont(ofSize: 48.0)
        firstSubtitlesLabel.verticalAlignment = .VerticalAlignmentBottom
        firstSubtitlesLabel.numberOfLines = 0
        firstSubtitlesLabel.textAlignment = .center
        firstSubtitlesLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //        subtitlesLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5031571062)
        firstSubtitlesLabel.adjustsFontSizeToFitWidth = false
        view.addSubview(firstSubtitlesLabel)
        
        firstSubtitlesLabel.translatesAutoresizingMaskIntoConstraints = false
        firstSubtitlesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        firstSubtitlesLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        firstSubtitlesLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -44).isActive = true
//        firstSubtitlesLabel.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    private func setupSecondSubtitle(_ view: UIView) {
        secondSubtitlesLabel.font = UIFont.boldSystemFont(ofSize: 48.0)
        secondSubtitlesLabel.verticalAlignment = .VerticalAlignmentTop
        secondSubtitlesLabel.numberOfLines = 0
        secondSubtitlesLabel.textAlignment = .center
        secondSubtitlesLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //        subtitlesLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5031571062)
        secondSubtitlesLabel.adjustsFontSizeToFitWidth = false
        view.addSubview(secondSubtitlesLabel)
        
        secondSubtitlesLabel.translatesAutoresizingMaskIntoConstraints = false
        secondSubtitlesLabel.centerXAnchor.constraint(equalTo: firstSubtitlesLabel.centerXAnchor).isActive = true
        secondSubtitlesLabel.widthAnchor.constraint(equalTo: firstSubtitlesLabel.widthAnchor).isActive = true
        
        secondSubtitlesTopAnchor = secondSubtitlesLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160)
        secondSubtitlesBottonAnchor = secondSubtitlesLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -540)
    }
}
