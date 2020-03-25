//
//  ViuPlayerView.swift
//  ViuPlayer
//
//  Created by Jerry He on 2019/11/11.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerSubtitlesView: ViuPlayerView {
    
    var firstSubtitles : ViuSubtitlesOld?
    let firstSubtitlesLabel = ViuCustomLabel()
    
    var secondSubtitles : ViuSubtitlesOld?
    let secondSubtitlesLabel = ViuCustomLabel()
    
    override func configurationUI() {
        super.configurationUI()
        
        setupFirstSubtitle()
        setupSecondSubtitle()
    }
    
    override func playStateDidChange(_ state: ViuPlayerState) {
        super.playStateDidChange(state)
        if state == .playing {
            
        }
    }
    
    override func displayControlView(_ isDisplay: Bool) {
        super.displayControlView(isDisplay)
    }
    
    override func reloadPlayerView() {
        super.reloadPlayerView()
        
    }
    
    override func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        super.playerDurationDidChange(currentDuration, totalDuration: totalDuration)
        if let sub = self.firstSubtitles?.search(for: currentDuration) {
            self.firstSubtitlesLabel.isHidden = false
            self.firstSubtitlesLabel.text = sub.content
            
            self.secondSubtitlesLabel.isHidden = false
            self.secondSubtitlesLabel.text = sub.content
            
        } else {
            self.firstSubtitlesLabel.isHidden = true            
            self.secondSubtitlesLabel.isHidden = true
        }
    }
    
    open func setSubtitles(_ subtitles : ViuSubtitlesOld) {
        self.firstSubtitles = subtitles
        self.secondSubtitles = subtitles
    }
    
    private func setupFirstSubtitle() {
        
        firstSubtitlesLabel.font = UIFont.boldSystemFont(ofSize: 48.0)
        firstSubtitlesLabel.verticalAlignment = .VerticalAlignmentBottom
        firstSubtitlesLabel.numberOfLines = 0
        firstSubtitlesLabel.textAlignment = .center
        firstSubtitlesLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //        subtitlesLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5031571062)
        firstSubtitlesLabel.adjustsFontSizeToFitWidth = false
        self.insertSubview(firstSubtitlesLabel, belowSubview: self.shadowView)
        
        firstSubtitlesLabel.translatesAutoresizingMaskIntoConstraints = false
        firstSubtitlesLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        firstSubtitlesLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
        firstSubtitlesLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -44).isActive = true
        firstSubtitlesLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    private func setupSecondSubtitle() {
        
        secondSubtitlesLabel.font = UIFont.boldSystemFont(ofSize: 48.0)
        secondSubtitlesLabel.verticalAlignment = .VerticalAlignmentTop
        secondSubtitlesLabel.numberOfLines = 0
        secondSubtitlesLabel.textAlignment = .center
        secondSubtitlesLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //        subtitlesLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5031571062)
        secondSubtitlesLabel.adjustsFontSizeToFitWidth = false
        self.insertSubview(secondSubtitlesLabel, belowSubview: self.shadowView)
        
        secondSubtitlesLabel.translatesAutoresizingMaskIntoConstraints = false
        secondSubtitlesLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        secondSubtitlesLabel.topAnchor.constraint(equalTo: self.viuPlayerTabbar.bottomAnchor, constant: 12).isActive = true
        secondSubtitlesLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -44).isActive = true
        secondSubtitlesLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
}
