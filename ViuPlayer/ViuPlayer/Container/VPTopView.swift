//
//  ViuPlayerTopView.swift
//  ViuPlayer
//
//  Created by TerryChe on 2020/3/20.
//  Copyright © 2020 TerryChe. All rights reserved.
//

import UIKit

class VPTopView: UIView {
    // 播放器进度条
    let viuProgressView = VPPlaybackView()
    // 中间转圈圈
    let loadingIndicator = VPLoadingIndicator()
    
    private let controlViewDuration: TimeInterval = 6.0 /// default 5.0
    private let displayDuration: TimeInterval = 0.5

    private var timer = Timer()
    
    // bottom view
    open var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.isHidden = true
        return view
    }()
    
    // MARK: - life cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configurationShadowView()
        configurationViuProgressView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer.invalidate()
        
        print("ViuPlayerView deinit")
    }
    
    open func displayControlView(_ isDisplay: Bool) {
        if isDisplay {
            displayControlAnimation()
        } else {
            hiddenControlAnimation()
        }
    }
}

// MARK: - private
extension VPTopView {
    
    internal func displayControlAnimation() {
        timer.invalidate()
        UIView.animate(withDuration: displayDuration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viuProgressView.alpha = 1
            strongSelf.viuProgressView.isHidden = false
        })
    }
    
    internal func hiddenControlAnimation() {
        UIView.animate(withDuration: displayDuration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viuProgressView.alpha = 0
            strongSelf.viuProgressView.isHidden = true
        })
    }
    
    internal func displayShadowView() {
        UIView.animate(withDuration: displayDuration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.shadowView.alpha = 1
            strongSelf.shadowView.isHidden = false
        })
    }
    
    internal func hiddenShadowView() {
        UIView.animate(withDuration: displayDuration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.shadowView.alpha = 0
            strongSelf.shadowView.isHidden = true
        })
    }
    
    internal func setupTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: controlViewDuration, repeats: false) { [weak self] (timer) in
            guard let strongSelf = self else { return }
            strongSelf.displayControlView(false)
        }
    }
}

// MARK: - UI autoLayout
extension VPTopView {
    internal func configurationShadowView() {
        addSubview(shadowView)
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        shadowView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        shadowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        loadingIndicator.lineWidth = 4.0
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 80).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    internal func configurationViuProgressView() {
        
        viuProgressView.isHidden = true
        addSubview(viuProgressView)
        viuProgressView.translatesAutoresizingMaskIntoConstraints = false
        viuProgressView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        viuProgressView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        viuProgressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        viuProgressView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
}
