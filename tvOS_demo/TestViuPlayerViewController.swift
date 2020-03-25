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
        
        let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
        setupPlayerURL(url)
        setupPlayback()
        setupTabbarVC()
    }
    
    private func setupTabbarVC() {
        
        let decString = "测试的播放器导航栏的简介 测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介"
        let model = PVIntroductionModel.init(title: "简介",
                                             imageUrl: "",
                                             dramaTitle: "第15集 测试的播放器",
                                             dramaDescription: decString)
        
        let subtitles = ["中文", "英文", "印度文", "日文", "韩文", "法文", "意大利文", "西班牙文", "繁体中文"]
        let model2 = PVSubtitleModel.init(title: "语言", subtitles: subtitles, delegate: self)
        
        let contents = ["英语", "中文", "英语", "中文", "英语", "中文", "英语", "中文", "英语"]
        let table = PVAudioTableModel.init(headTitle: "语言", contents: contents, delegate: self)
        
        let contents2 = ["完整动态范围", "降低高音量"]
        let table2 = PVAudioTableModel.init(headTitle: "声音", contents: contents2, delegate: self)
        
        let contents3 = ["客厅"]
        let table3 = PVAudioTableModel.init(headTitle: "扬声器", contents: contents3, delegate: self)
        
        let collections = [table, table2, table3]
        let model3 = PVAudioModel.init(title: "音频", audioModels: collections)
        
        panelViewController.tabbarModels = [model, model2, model3]
        
    }
}

/// MARK:
extension TestViuPlayerViewController: PVAudioTableModelDelegate {
    
    public func pvAudioTableSelectValue(_ string: String) {
        print(string)
    }
}

extension ViuPlayerViewController: PVSubtitleModelDelegate {
    
    public func pvSubtitleSelectValue(_ string: String) {
        print(string)

        // Do any additional setup after loading the view.
//        https://d1k2us671qcoau.cloudfront.net/distribute?area_id=1&ccs_product_id=9ab3e938b857337620e38577b9e59d1f&duration=0&language_flag_id=1&language_id=1&os=tvOS&platform_flag_label=tv&product_subtitle_language_id=1&ut=2
        
        let url = URL(string: "https://stream-hk.viu.com/s/fSKjMDW1Kieu_wEJY3DEoA/1585122493/UD/9ab3e938b857337620e38577b9e59d1f/9ab3e938b857337620e38577b9e59d1f_Layer4_vod.m3u8")!
        setupPlayerURL(url)
        setupPlayback()
        
//    https://dfp6rglgjqszk.cloudfront.net/index.php?r=v1/series/detail&area_id=1&language_flag_id=1&language_id=1&os=tvOS&os_flag_id=103&platform_flag_label=tv&product_id=255335&ut=2
        setupSubTitle(subTitle: [
            ViuSubtitles(urlPath: URL(string: "https://d2anahhhmp1ffz.cloudfront.net/883089942/f667d321f94647192c9666f6c3051cfb7a5d8b6a")!, format: .srt),
            ViuSubtitles(urlPath: URL(string: "https://d2anahhhmp1ffz.cloudfront.net/3107204754/6e234068e1279c3cdb771ca0a7369d65bc921b8e")!, format: .srt),
        ])
    }
}
