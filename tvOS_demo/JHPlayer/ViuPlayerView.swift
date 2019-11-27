//
//  ViuPlayerView.swift
//  ViuPlayer
//
//  Created by Jerry He on 2019/11/11.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit

class ViuPlayerView: JHPlayerView {
    
    var subtitles : JHSubtitles?
    let subtitlesLabel = CustomLabel()
    
    override func configurationUI() {
        super.configurationUI()
        
        subtitlesLabel.font = UIFont.boldSystemFont(ofSize: 48.0)
        subtitlesLabel.verticalAlignment = .VerticalAlignmentBottom
        subtitlesLabel.numberOfLines = 0
        subtitlesLabel.textAlignment = .center
        subtitlesLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        subtitlesLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5031571062)
        subtitlesLabel.adjustsFontSizeToFitWidth = false
        self.insertSubview(subtitlesLabel, belowSubview: self.bottomView)
        
        subtitlesLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitlesLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        subtitlesLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        subtitlesLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        subtitlesLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

    }
    
    override func playStateDidChange(_ state: JHPlayerState) {
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
        if let sub = self.subtitles?.search(for: currentDuration) {
            self.subtitlesLabel.isHidden = false
            self.subtitlesLabel.text = sub.content
        } else {
            self.subtitlesLabel.isHidden = true
        }
    }
    
    open func setSubtitles(_ subtitles : JHSubtitles) {
        self.subtitles = subtitles
    }
    
}
