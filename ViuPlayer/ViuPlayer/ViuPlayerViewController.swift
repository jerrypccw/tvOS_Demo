//
//  ViuPlayerViewController.swift
//  ViuPlayer
//
//  Created by TerryChe on 2020/3/19.
//  Copyright © 2020 TerryChe. All rights reserved.
//

import AVKit

open class ViuPlayerViewController: UIViewController {

    // 最顶层View，包括：InfoVC 和 Playback
    private let topView = ViuPlayerTopView()
    // 手势
    private let playbackGestureManager = ViuPlaybackGestureManager()
    
    // 中间层View，包括字幕 和 自定义
    private let containerView = ViuPlayerContainerView()
    
    // 播放器
    private let playerView = ViuPlayer()

    // 长按快进
    private var longPressTimer: Timer?

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        playerView.frame = view.frame
        playerView.delegate = self
        view.addSubview(playerView)
        
        containerView.frame = view.frame
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        
        topView.frame = view.frame
        topView.backgroundColor = .clear
        view.addSubview(topView)
            
    }
    
    deinit {
        print("ViuPlayerViewController deinit")
    }
    
    open func setupPlayerURL(_ url: URL) {
        topView.loadingIndicator.isHidden = false
        topView.loadingIndicator.startAnimating()
        playerView.setupPlayer(URL: url)
    }
    
    open func setupPlayback() {
        setupGestureRecognizer()
    }
    
    private var lastSelectedPanelTabIndex: Int = 0
    private var displayedPanelViewController: ViuPanelViewController?
    
    private func setupPanelViewController() {
        let panelVC = ViuPanelViewController()
        panelVC.selectedIndex = lastSelectedPanelTabIndex
        panelVC.delegate = self
        panelVC.transitioningDelegate = self
        panelVC.modalPresentationStyle = .overCurrentContext
        
        displayedPanelViewController = panelVC
        setupTabbarVC()
        present(displayedPanelViewController!, animated: true) { }
    }
    
    private func setupTabbarVC() {
        
        let model = PVIntroductionModel()
        model.titleName = "简介"
        model.imageUrl = ""
        model.dramaTitle = "第15集 测试的播放器"
        model.dramaDescription = "测试的播放器导航栏的简介 测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介"
        
        let model2 = PVSubtitleModel()
        model2.titleName = "语言"
        //        model2.subtitles += ["中文", "繁体中文"]
        model2.subtitles += ["中文", "英文", "印度文", "日文", "韩文", "法文", "意大利文", "西班牙文", "繁体中文"]
        model2.delegate = self
        
        let model3 = PVAudioCollectionModel()
        model3.titleName = "音频"
        
        let table = PVAudioTableModel()
        table.headTitle = "语言"
        table.contents = ["英语", "中文", "英语", "中文", "英语", "中文", "英语", "中文", "英语"]
        //        table.contents = ["英语"]
        table.delegate = self
        
        let table2 = PVAudioTableModel()
        table2.headTitle = "声音"
        table2.contents = ["完整动态范围", "降低高音量"]
        table2.delegate = self
        
        let table3 = PVAudioTableModel()
        table3.headTitle = "扬声器"
        table3.contents = ["客厅"]
        table3.delegate = self
        
        model3.collections.append(table)
        model3.collections.append(table2)
        model3.collections.append(table3)
        
        displayedPanelViewController?.tabbarModels = [model, model2, model3]
    }
    
    open func setupSubTitle(subTitle: [ViuSubtitles]){
        // Test
        if subTitle.count > 1 {
            containerView.subTitleManager.setSubtitles(first: subTitle[0], second: subTitle[1])
        } else if subTitle.count > 0 {
            containerView.subTitleManager.setSubtitles(first: subTitle[0], second: nil)
        }
    }
}

extension ViuPlayerViewController: ViuPlaybackGestureManagerDelegate {
    private func setupGestureRecognizer() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeAction(swipe:)))
        swipeDown.direction = .down
        swipeDown.delegate = playbackGestureManager
        view.addGestureRecognizer(swipeDown)
        
        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(onPlayPauseTap(tap:)))
        playPauseTap.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        playPauseTap.delegate = playbackGestureManager
        view.addGestureRecognizer(playPauseTap)
        
        playbackGestureManager.addGesture(view)
        playbackGestureManager.delegate = self
    }
    
    @objc public func onSwipeAction(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction {
        case .down:
            print("显示 InfoVC")
            setupPanelViewController()
                    
        default:
            break
        }
    }
    
    @objc public func onPlayPauseTap(tap: UITapGestureRecognizer) {
        playerView.playPauseAction()
    }
    
    public func onTouch(_ gesture: ViuPlaybackTouchGestureRecognizer) {
        // 信息栏显示，就不执行
//        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
        // 快进过程中忽略Touch
        if let rate = playerView.player?.rate, rate > 1 || rate < 0 { return }

        if gesture.state == .began || gesture.state == .changed {
            topView.displayControlView(true)
            
            if playerView.state == .paused {
                // 如果是暂停，就可以滑动
                if abs(gesture.touchesMovedX) > 1 {
                    topView.viuProgressView.setPorgressLineByUser(offset: gesture.touchesMovedX)
                }
            } else {
                // 播放中就快进/快退
                switch gesture.remoteTouchLocation {
                case .left:
                    topView.viuProgressView.showLeftActionIndicator(isLongPress: false)
                case .right:
                    topView.viuProgressView.showRightActionIndicator(isLongPress: false)
                case .center:
                    topView.viuProgressView.hiddenFastForwordAndRewind()
                }
            }
        } else {
            topView.viuProgressView.hiddenFastForwordAndRewind()
            topView.setupTimer()
        }
    }
    
    public func onTap(_ gesture: UITapGestureRecognizer) {
        // 信息栏显示，就不执行
//        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
        
        topView.displayControlView(true)
        
        if playerView.state == .paused {
            // 滑动跳特定时间
            playerView.seekTime(topView.viuProgressView.seekTime)
            topView.viuProgressView.hiddenThumbnail()
        } else if gesture.numberOfTapsRequired == 1 && gesture.state == .ended {
            switch gesture.remoteTouchLocation {
            case .left:// 快退10秒
                playerView.seekTime(offect: -10)
            case .right:// 快进10秒
                playerView.seekTime(offect: 10)
            case .center:
                playerView.playPauseAction()
            }
        }
    }
    
    public func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        // 信息栏显示，就不执行
//        if viuPlayer.displayView.viuPlayerTabbar.isTabbarShow == true { return }
        
        // 视频暂停时，就不执行
        if playerView.state == .paused { return }
        
        guard let player = playerView.player, let playerItem = player.currentItem else {
            return
        }
        
        topView.displayControlView(true)
        
        print("能否快进（rate>2）:\(playerItem.canPlayFastForward)")
        
        if (gesture.state == .began || gesture.state == .changed) && gesture.remoteTouchLocation != .center {
            switch gesture.remoteTouchLocation {
            case .left:// 快退
                topView.viuProgressView.showLeftActionIndicator(isLongPress: true)
                
                if playerItem.canPlayFastForward {
                    player.rate = -20
                } else {
                    player.pause()
                    longPressTimer?.invalidate()
                    longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (timer) in
                        print("快退")
                        self?.topView.viuProgressView.setPorgress(offset: -3)
                    })
                }
                
            case .right:// 快进
                topView.viuProgressView.showRightActionIndicator(isLongPress: true)
                
                if playerItem.canPlayFastForward {
                    player.rate = 20
                } else {
                    player.pause()
                    longPressTimer?.invalidate()
                    longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (timer) in
                        print("快进")
                        self?.topView.viuProgressView.setPorgress(offset: 3)
                    })
                }
                
            default:
                break
            }
        } else {
            if playerItem.canPlayFastForward {
                playerView.player?.rate = 1
            } else {
                longPressTimer?.invalidate()
                playerView.seekTime(topView.viuProgressView.seekTime)
            }
        }
    }
}

extension ViuPlayerViewController: ViuPlayerDelegate {
    // play state
    public func viuPlayer(_ player: ViuPlayer, stateDidChange state: ViuPlayerState) {
        switch state {
        case .playFinished:
//            topView.loadingIndicator.isHidden = true
//            topView.loadingIndicator.stopAnimating()
//            navigationController?.popViewController(animated: true)
            print("播放完成")
        case .paused:
//            topView.displayShadowView()
//            topView.displayControlView(true)
//            topView.viuProgressView.duration = playerView.player?.currentItem?.duration.seconds ?? 0
            break
        case .playing:
            topView.loadingIndicator.isHidden = true
            topView.loadingIndicator.stopAnimating()
        default:
            break
        }
    }
    
    // playe Duration
    public func viuPlayer(_ player: ViuPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {

        // 设置进度条
        topView.viuProgressView.setPorgressLineX(currentDuration: currentDuration, totalDuration: totalDuration)
        
        // 更新字幕
        containerView.subTitleManager.secondSubtitlesPosition = (presentedViewController == nil) ? 0 : 1
        containerView.subTitleManager.currentDuration = currentDuration
    }
    
    // buffer state
    public func viuPlayer(_ player: ViuPlayer, bufferStateDidChange state: ViuPlayerBufferState) {
        if state == .buffering {
            topView.loadingIndicator.isHidden = false
            topView.loadingIndicator.startAnimating()
        } else {
            topView.loadingIndicator.isHidden = true
            topView.loadingIndicator.stopAnimating()
        }
    }
    
    // buffered Duration
    public func viuPlayer(_ player: ViuPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
        topView.viuProgressView.progressBar.setProgress(Float(bufferedDuration / totalDuration), animated: true)
    }
    
    // play error
    public func viuPlayer(_ player: ViuPlayer, playerFailed error: ViuPlayerError) {
        print(error)
    }
}

extension ViuPlayerViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presented is ViuPanelViewController ? ViuSlideDownAnimatedTransitioner() : nil
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissed is ViuPanelViewController ? ViuSlideUpAnimatedTransitioner() : nil
    }
}

extension ViuPlayerViewController: ViuPanelViewControllerDelegate {
    func panelViewController(_ panelViewController: ViuPanelViewController, didSelectTabAtIndex index: Int) {
        lastSelectedPanelTabIndex = index
    }

    func panelViewControllerDidDismiss(_ panelViewController: ViuPanelViewController) {
        displayedPanelViewController = nil
    }
}


/// MARK:
extension ViuPlayerViewController: PVAudioTableModelDelegate {
    
    public func pvAudioTableSelectValue(_ string: String) {
        print(string)
    }
}

extension ViuPlayerViewController: PVSubtitleModelDelegate {
    
    public func pvSubtitleSelectValue(_ string: String) {
        print(string)
    }
}
