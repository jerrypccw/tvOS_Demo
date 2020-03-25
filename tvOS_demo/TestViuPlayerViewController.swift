//
//  TestViuPlayerViewController.swift
//  tvOS_demo
//
//  Created by TerryChe on 2020/3/20.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit
import ViuPlayer

class TestViuPlayerViewController: ViuPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        https://d1k2us671qcoau.cloudfront.net/distribute?area_id=1&ccs_product_id=9ab3e938b857337620e38577b9e59d1f&duration=0&language_flag_id=1&language_id=1&os=tvOS&platform_flag_label=tv&product_subtitle_language_id=1&ut=2
        
        let url = URL(string: "https://stream-hk.viu.com/s/pHlfvBuT7ghzbo8csXCxig/1585046401/UD/9ab3e938b857337620e38577b9e59d1f/9ab3e938b857337620e38577b9e59d1f_Layer4_vod.m3u8")!
        setupPlayerURL(url)
        setupPlayback()
        
//    https://dfp6rglgjqszk.cloudfront.net/index.php?r=v1/series/detail&area_id=1&language_flag_id=1&language_id=1&os=tvOS&os_flag_id=103&platform_flag_label=tv&product_id=255335&ut=2
        setupSubTitle(subTitle: [
            ViuSubtitles(urlPath: URL(string: "https://d2anahhhmp1ffz.cloudfront.net/883089942/f667d321f94647192c9666f6c3051cfb7a5d8b6a")!, format: .srt),
            ViuSubtitles(urlPath: URL(string: "https://d2anahhhmp1ffz.cloudfront.net/3107204754/6e234068e1279c3cdb771ca0a7369d65bc921b8e")!, format: .srt),
        ])
    }
}
