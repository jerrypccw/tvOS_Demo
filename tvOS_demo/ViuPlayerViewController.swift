//
//  ViuPlayerViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2019/11/28.
//  Copyright © 2019 jerry. All rights reserved.
//

import UIKit


/// 请求片源Api，香港地区
// https://d1k2us671qcoau.cloudfront.net/distribute?area_id=1&ccs_product_id=0a1188fd36bea62177c2d17e5ddf06ae&duration=0&language_flag_id=1&os=tvOS&platform_flag_label=tv&product_subtitle_language_id=1%3A3%3A7%3A8&ut=2
let url = URL(string: "https://stream-hk.viu.com/s/4j8mhSZ6BFOyaNZ9_mLmdA/1575613728/UD/0a1188fd36bea62177c2d17e5ddf06ae/0a1188fd36bea62177c2d17e5ddf06ae_Layer1_vod.m3u8")!

class ViuPlayerViewController: UIViewController {
    
    var bagenTimer: Timer = {
           let time = Timer()
           return time
    }()
    
    let bagenTimerDuration: TimeInterval = 0.1 /// default 5.0
    
    var viuPlayer: ViuPlayer = {
        let playerView = ViuPlayerSubtitlesView()
        let player = ViuPlayer(playerView: playerView)
        return player
    }()

    deinit {
        print("ViuPlayerViewController deinit")
    }

    // 使用PUSH转跳需要添加一下代码，不然会丢失焦点
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viuPlayer.pause()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow

        view.addSubview(viuPlayer.displayView)

        viuPlayer.backgroundMode = .proceed
        viuPlayer.delegate = self
        viuPlayer.displayView.delegate = self

        viuPlayer.displayView.translatesAutoresizingMaskIntoConstraints = false
        viuPlayer.displayView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        viuPlayer.displayView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viuPlayer.displayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viuPlayer.displayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        setPlayerData()
        setupGestureRecognizer()
    }
    

    private func setPlayerData() {
        if  let srt = Bundle.main.url(forResource: "test", withExtension: "srt") {
            let playerView = self.viuPlayer.displayView as! ViuPlayerSubtitlesView
            playerView.setSubtitles(ViuSubtitles(filePath: srt))
        }

        let mp4File = ViuPlayerUtils.fileResource("hubblecast", fileType: "m4v")

        guard let urlStr: String = mp4File else {
            print("路径不存在")
            return
        }

        let url = URL.init(fileURLWithPath: urlStr)

//        if let playerView = viuPlayer.displayView as? ViuPlayerSubtitlesView {
//            let url = URL(string: "https://d2anahhhmp1ffz.cloudfront.net/1141076793/c3e1435ecb3e2ae3aa4ff0b20d7c9824e1b7a0c3")!
//            let subtitle = ViuSubtitles(urlPath: url, format: .srt)
//            playerView.setSubtitles(subtitle)
//        }

        viuPlayer.replaceVideo(url)
        viuPlayer.play()
    }
}

// MARK: viuPlayerDelegate
extension ViuPlayerViewController: ViuPlayerDelegate {
    func viuPlayer(_ player: ViuPlayer, playerFailed error: ViuPlayerError) {
        print(error)
    }

    func viuPlayer(_ player: ViuPlayer, stateDidChange state: ViuPlayerState) {
        print("player State ", state)

        if state == .playFinished {
            viuPlayer.replaceVideo(url)
            viuPlayer.play()
        }
    }

    func viuPlayer(_ player: ViuPlayer, bufferStateDidChange state: ViuPlayerBufferstate) {
        print("buffer State", state)
    }
}

// MARK: viuPlayerViewDelegate

extension ViuPlayerViewController: ViuPlayerViewDelegate {
    func viuPlayerView(_ playerView: ViuPlayerView, willFullscreen fullscreen: Bool) {
    }

    func viuPlayerView(didTappedClose playerView: ViuPlayerView) {
    }

    func viuPlayerView(didDisplayControl playerView: ViuPlayerView) {
    }
}
