//
//  VPlayerViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/2/18.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

class VPlayerViewController: UIViewController {
    
    // 进度条
    lazy var transportBar: ViuProgressBar = {
        let bar = ViuProgressBar()
        return bar
    }()
    
    // 进度控制器
    lazy var playbackControlView: ViuGradientView = {
        let view = ViuGradientView()
        return view
    }()
    
    // remote滑动快进及后退的时间
    lazy var scrubbingLabel: UIView = {
        let label = UILabel()
        label.text = "01:00"
        label.textColor = .white
        return label
    }()
    
    // 开始时间
    lazy var positionLabel: UILabel = {
        let label = UILabel()
        label.text = "01:00"
        label.textColor = .white
        return label
    }()
    
    // 结束时间
    lazy var remainingLabel: UILabel = {
        let label = UILabel()
        label.text = "01:00"
        label.textColor = .white
        return label
    }()
    
    // 快进
    lazy var rightActionIndicator: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    // 后退
    lazy var leftActionIndicator: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
 
    
    // 快进buffer加载
    lazy var bufferingIndicator: UIActivityIndicatorView = {
        if #available(tvOS 13.0, *) {
            let av = UIActivityIndicatorView.init(style: .large)
            return av
        } else {
            let av = UIActivityIndicatorView.init(style: .white)
            return av
        }
    }()
    
    // 进度条时间点竖线
    lazy var positionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var positionController: PositionController? {
        didSet {
            guard positionController !== oldValue else { return }
            oldValue?.isEnabled = false
            positionController?.isEnabled = true
        }
    }
    
    private var isBuffering: Bool = false {
        didSet {
            guard isBuffering != oldValue else { return }

            if isBuffering {
                bufferingIndicator.startAnimating()
            } else {
                bufferingIndicator.stopAnimating()
            }
            
            rightActionIndicator.isHidden = isBuffering
        }
    }
    
    var playPauseGesture: UITapGestureRecognizer!
    var cancelGesture: UITapGestureRecognizer!
    var actionGesture: LongPressGestureRecogniser!
    var remoteActionPositionController: RemoteActionPositionController!
    
    private var lastSelectedPanelTabIndex: Int = 0
    private var displayedPanelViewController: ViuPanelViewController?
    private var isPanelDisplayed: Bool {
        return displayedPanelViewController != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playbackControlView.isHidden = true
        
        let font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.medium)
        positionLabel.font = font
        remainingLabel.font = font
                
        setPlaybackControlViewLayout()
        setTransportBarLayout()
        setPositionLayout()
        setPositionLabelLayout()
        setRemainingLabel()
        setRightActionIndicatorLayout()
        setLeftActionIndicatorLayout()
        setPlaybackControlViewLayout()
        
        // Gesture
        actionGesture = LongPressGestureRecogniser.init(target: self, action: #selector(click(_:)))
        view.addGestureRecognizer(actionGesture)
        
        playPauseGesture = UITapGestureRecognizer.init(target: self, action: #selector(playOrPause(_:)))
        view.addGestureRecognizer(playPauseGesture)
        
        cancelGesture = UITapGestureRecognizer.init(target: self, action: #selector(cancel(_:)))
        view.addGestureRecognizer(cancelGesture)
        
        remoteActionPositionController = RemoteActionPositionController()
        remoteActionPositionController.delegate = self
        remoteActionPositionController.rightActionIndicator = rightActionIndicator
        remoteActionPositionController.leftActionIndicator = leftActionIndicator
        
        setupPositionController()
        
        setupPanelViewController()
    }
    
    func setupPanelViewController() {
        let panelVC = ViuPanelViewController()
        panelVC.selectedIndex = lastSelectedPanelTabIndex
        panelVC.transitioningDelegate = self
        present(panelVC, animated: true, completion: nil)
    }
    
    // GestureRecogniser
    @objc func click(_ sender: LongPressGestureRecogniser) {
        positionController?.click(sender)
    }
    
    @objc func playOrPause(_ sender: Any) {
        positionController?.playOrPause(sender)
    }
    
    @objc func cancel(_ sender: Any) {
        hideControl()
    }
    
    fileprivate func setupPositionController() {
//        guard player.isSeekable && !isOpening && !isPanelDisplayed else {
//            positionController = nil
//            return
//        }
//
//        if player.state == .paused {
//            scrubbingPositionController.selectedTime = player.time
//            positionController = scrubbingPositionController
//        } else {
//            positionController = remoteActionPositionController
//        }
        positionController = remoteActionPositionController
    }
    
    // MARK: Control
    var playbackControlHideTimer: Timer?
    public func showPlaybackControl() {
        playbackControlHideTimer?.invalidate()
//        if player.state != .paused {
            autoHideControl()
//        }

        guard self.playbackControlView.isHidden else {
            return
        }
        self.cancelGesture.isEnabled = true

        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.playbackControlView.isHidden = false
        })
    }

    private func autoHideControl() {
        playbackControlHideTimer?.invalidate()
        playbackControlHideTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.hideControl()
        }
    }

    private func hideControl() {
        playbackControlHideTimer?.invalidate()
        self.cancelGesture.isEnabled = false

        guard !self.playbackControlView.isHidden else {
            return
        }

        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.playbackControlView.isHidden = true
        })
    }
    
    // setLayout
    private func setPlaybackControlViewLayout() {
        
        view.addSubview(playbackControlView)
        playbackControlView.translatesAutoresizingMaskIntoConstraints = false
        playbackControlView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playbackControlView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playbackControlView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        playbackControlView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    private func setTransportBarLayout() {
        
        playbackControlView.addSubview(transportBar)
        let cView = playbackControlView
        transportBar.translatesAutoresizingMaskIntoConstraints = false
        transportBar.leadingAnchor.constraint(equalTo: cView.leadingAnchor, constant: 90).isActive = true
        transportBar.centerXAnchor.constraint(equalTo: cView.centerXAnchor).isActive = true
        transportBar.bottomAnchor.constraint(equalTo: cView.bottomAnchor, constant: -90).isActive = true
        transportBar.widthAnchor.constraint(equalToConstant: 1740).isActive = true
        transportBar.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    private func setPositionLayout() {
        
        transportBar.addSubview(positionView)
        positionView.translatesAutoresizingMaskIntoConstraints = false
        positionView.bottomAnchor.constraint(equalTo: transportBar.bottomAnchor).isActive = true
        positionView.heightAnchor.constraint(equalTo: transportBar.heightAnchor).isActive = true
        positionView.widthAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    private func setPositionLabelLayout() {
        
        playbackControlView.addSubview(positionLabel)
        positionLabel.translatesAutoresizingMaskIntoConstraints = false
        positionLabel.centerXAnchor.constraint(equalTo: positionView.centerXAnchor).isActive = true
        positionLabel.leadingAnchor.constraint(lessThanOrEqualTo: transportBar.leadingAnchor).isActive = true
        positionLabel.topAnchor.constraint(equalTo: transportBar.bottomAnchor, constant: 8).isActive = true
    }
    
    private func setRemainingLabel() {
        
        playbackControlView.addSubview(remainingLabel)
        remainingLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingLabel.trailingAnchor.constraint(equalTo: transportBar.trailingAnchor).isActive = true
        remainingLabel.topAnchor.constraint(equalTo: transportBar.bottomAnchor, constant: -8).isActive = true
        remainingLabel.lastBaselineAnchor.constraint(equalTo: positionLabel.lastBaselineAnchor).isActive = true
        remainingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: playbackControlView.leadingAnchor).isActive = true
    }
    
    private func setRightActionIndicatorLayout() {
        
        playbackControlView.addSubview(rightActionIndicator)
        rightActionIndicator.translatesAutoresizingMaskIntoConstraints = false
        rightActionIndicator.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor, constant: 8).isActive = true
        rightActionIndicator.centerYAnchor.constraint(equalTo: positionLabel.centerYAnchor).isActive = true
        rightActionIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        rightActionIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setLeftActionIndicatorLayout() {
        
        playbackControlView.addSubview(leftActionIndicator)
        leftActionIndicator.translatesAutoresizingMaskIntoConstraints = false
        leftActionIndicator.trailingAnchor.constraint(equalTo: positionLabel.leadingAnchor, constant: -8).isActive = true
        leftActionIndicator.centerYAnchor.constraint(equalTo: positionLabel.centerYAnchor).isActive = true
        leftActionIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        leftActionIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    private func setBufferingIndicatorLayout() {
        
        playbackControlView.addSubview(bufferingIndicator)
        bufferingIndicator.translatesAutoresizingMaskIntoConstraints = false
        bufferingIndicator.leadingAnchor.constraint(equalTo: positionLabel.leadingAnchor, constant: 8).isActive = true
        bufferingIndicator.centerYAnchor.constraint(equalTo: positionLabel.centerYAnchor).isActive = true
        bufferingIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        bufferingIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    // 使用PUSH转跳需要添加一下代码，不然会丢失焦点
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

// MARK: - Gesture
extension VPlayerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Remote Action Delegate
extension VPlayerViewController: RemoteActionPositionControllerDelegate {
    
    func remoteActionPositionControllerDidDetectTouch(_ remote: RemoteActionPositionController) {
        showPlaybackControl()
    }
    
    func remoteActionPositionController(_ : RemoteActionPositionController, didSelectAction action: RemoteActionPositionController.Action) {
        
        showPlaybackControl()
        
        switch action {
        case .fastForward:
            print("fastForward")
        case .rewind:
            print("rewind")
        case .jumpForward:
            print("jumpForward")
        case .jumpBackward:
            print("jumpBackward")
        case .pause:
            print("pause")
        case .reset:
            print("reset")
        }
    }
}

extension VPlayerViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presented is ViuPanelViewController ? ViuSlideDownAnimatedTransitioner() : nil
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissed is ViuPanelViewController ? ViuSlideUpAnimatedTransitioner() : nil
    }
}
