//
//  GestureViewController.swift
//  tvOS_demo
//
//  Created by TerryChe on 2020/3/10.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit
import BitmovinPlayer

class BitmovinPlayerViewController: UIViewController {
    override func viewDidLoad() {
        // Create the HLS stream URL
//        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/playlist.m3u8") else {
//            return
//        }
        
       guard let streamUrl = URL(string: "https://d1k2us671qcoau.cloudfront.net/vodapi/airplay.m3u8?vid=c897cf1be4c15031cf95317ea814e4a3&ts=202003181153&layer=Layer4&streamurl=https://stream-hk.viu.com/s/A0lJrVx9YSgqGXLp3lws3g/1584518028/UD/c897cf1be4c15031cf95317ea814e4a3/c897cf1be4c15031cf95317ea814e4a3_Layer4_vod.m3u8&region=hk&subLang=3:1:7:8&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kMWsydXM2NzFxY29hdS5jbG91ZGZyb250Lm5ldC92b2RhcGkvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTU4NDUxODAyOH19fV19&Signature=dQ29JBqBZLWEKje7hfKToJ-XWhMOZoRcZP83lq-uvxflQ5MDb0Hc4UyCXLm9ExlOFQcLFIVzlwc8gbAiTN0pxFq-fwAvP~cz51DZHfYNf3qtc77clc4OWspg-XidSzmEZa4kzOLVy8d8Pxnj5BtabnHcKYam6s5cJxYmfWVYZEgI0QXYHWtaYJ2Nx0SgrKLc1VFR0qYHob-ZJSbKIJkFh3E-Ugessr5TsFi7WUnaEQ9mwp0eP4JlijLbb-6GiwMATGoSX73SX07BBCR6SerlYaRcm4WmSjYYf00Uhb-YukwKx5-izX3McCIWces5bXDdDDC2AqTS0ObRik0S3uiutw__&Key-Pair-Id=APKAJ6Z4RF5IYK7Y3SQQ") else {
            return
        }
        
//       guard let streamUrl = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8") else {
//            return
//        }
        
        /// BitmovinPlayer
        // Create a source item based on the HLS stream URL
        let hlsSource = HLSSource(url: streamUrl)
        let sourceItem = SourceItem(adaptiveSource: hlsSource)
        
        sourceItem?.metadata = [
            AVMetadataIdentifier.commonIdentifierTitle : "标题" as NSCopying & NSObjectProtocol,
            AVMetadataIdentifier.commonIdentifierDescription : "正文介绍正文介绍正文介绍正文介绍正文介绍正文介绍正文介绍正文介绍正文介绍正文介绍正文介绍" as NSCopying & NSObjectProtocol
        ]

        // Create player configuration
        let config = PlayerConfiguration()

        // Add the source item to the configuration
        config.sourceItem = sourceItem
        
        let player = BitmovinPlayer(configuration: config)
        
        let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds

        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)
        
        player.play()
    }
}
