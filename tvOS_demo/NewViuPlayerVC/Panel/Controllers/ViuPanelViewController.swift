//
//  ViuPanelViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/10.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit
import Foundation

protocol ViuPanelViewControllerDelegate: class {
    func panelViewController(_ panelViewController: ViuPanelViewController, didSelectTabAtIndex: Int)
    func panelViewControllerDidDismiss(_ panelViewController: ViuPanelViewController)
}

class ViuPanelViewController: UIViewController {
    
    private var contentHeightConstraint: NSLayoutConstraint!
    
    private var swipUp = UISwipeGestureRecognizer()

    private lazy var tabBar = UITabBar()
    
    private lazy var contentView = UIView()

    private lazy var filletView = UIView()
    
    private var currentViewController: UIViewController?
    
    private lazy var focusEnvironments: [UIFocusEnvironment] = [self.tabBar]
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return focusEnvironments
    }
    
    private var viewControllers: [UIViewController] = [] {
        didSet {
            updateTabBars()
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            guard oldValue != selectedIndex else {
                return
            }
            updateContentForSelection()
            self.delegate?.panelViewController(self, didSelectTabAtIndex: selectedIndex)
        }
    }
    
    var isCellFocus: Bool = false
    
    weak var delegate: ViuPanelViewControllerDelegate?

    /// MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFilletView()
        setupTabbar()
        setupLineView(filletView)
        setupContentView()
        setupViewControllers()
        setupGestureRecognizer()
        updateContentForSelection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBar.subviews[0].isHidden = true
    }
}

// MARK: - TabBar delegate
extension ViuPanelViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectedIndex = item.tag
    }
}

// MARK: - Setup Views
extension ViuPanelViewController {
    
    private func setupFilletView() {
        
        view.addSubview(filletView)
        filletView.translatesAutoresizingMaskIntoConstraints = false
        filletView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        filletView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        filletView.widthAnchor.constraint(equalToConstant: 1720).isActive = true
        contentHeightConstraint = filletView.heightAnchor.constraint(equalToConstant: 88)
        contentHeightConstraint.priority = .defaultLow
        contentHeightConstraint.isActive = true
        
        filletView.layer.masksToBounds = true
        filletView.layer.cornerRadius = ViuPlayerTabbarConfig.filletCornerRadius
        view.addSubview(filletView)
        
        setupVisualEffectView(filletView)
    }
    
    private func setupLineView(_ view: UIView) {
        let lineView = UIView()
        lineView.backgroundColor = .black
        filletView.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 0).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: ViuPlayerTabbarConfig.lineHeight).isActive = true
        lineView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        lineView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }
    
    /// 添加毛玻璃效果
    private func setupVisualEffectView(_ view: UIView) {
        /// 创建一个模糊效果
        let blurEffect = UIBlurEffect(style: .light)
        /// 创建一个承载模糊效果的视图
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    private func setupGestureRecognizer() {
        swipUp.addTarget(self, action: #selector(collapse(_ :)))
        swipUp.direction = .up
        view.addGestureRecognizer(swipUp)
        
        let tapMenu = UITapGestureRecognizer(target: self, action: #selector(tapMenuAction(_ :)))
        tapMenu.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(tapMenu)
    }
    
    private func setupTabbar() {
        
        tabBar.delegate = self
        filletView.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(tvOS 13.0, *) {
            tabBar.topAnchor.constraint(equalTo: filletView.topAnchor, constant: 20).isActive = true
        } else {
            tabBar.topAnchor.constraint(equalTo: filletView.topAnchor, constant: 0).isActive = true
        }
        
        tabBar.leftAnchor.constraint(equalTo: filletView.leftAnchor).isActive = true
        tabBar.rightAnchor.constraint(equalTo: filletView.rightAnchor).isActive = true
        tabBar.heightAnchor.constraint(equalToConstant: 88).isActive = true
    }
    
    private func setupContentView() {
        
        filletView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 2).isActive = true
        contentView.leftAnchor.constraint(equalTo: filletView.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: filletView.rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: filletView.bottomAnchor).isActive = true       
    }
    
    private func setupViewControllers() {
        
        let vc1 = PVInfoViewController()
        vc1.title = "Info"
        let model = PVIntroductionModel()
        model.buttonName = "简介"
        model.imageUrl = ""
        model.dramaTitle = "第15集 测试的播放器"
        model.dramaDescription = "测试的播放器导航栏的简介 测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介测试的播放器导航栏的简介"
        vc1.model = model
        
        let vc2 = PVSubtitleViewController()
        vc2.title = "Subtitle"
        let model2 = PVSubtitleModel()
        model2.buttonName = "语言"
//        model2.subtitles += ["中文", "繁体中文"]
        model2.subtitles += ["中文", "英文", "印度文", "日文", "韩文", "法文", "意大利文", "西班牙文", "繁体中文"]
        model2.delegate = self
        vc2.model = model2
        
        let vc3 = PVAudioViewController()
        vc3.title = "Audio"
        
        let collection = PVAudioCollectionModel()
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
        
        collection.collections.append(table)
        collection.collections.append(table2)
        collection.collections.append(table3)
        
        vc3.model = collection
        
        viewControllers = [vc1, vc2, vc3]
        contentView.layer.masksToBounds = true
    }
    
    private func updateTabBars() {
        guard viewIfLoaded != nil else {
            return
        }
        let items = viewControllers.enumerated().map {
            UITabBarItem(title: $1.title, image: nil, tag: $0)
        }
        tabBar.items = items
        tabBar.selectedItem = items[selectedIndex]
    }
    
    private func updateContentForSelection() {
        guard viewIfLoaded != nil else {
            return
        }
        let newViewController = viewControllers[selectedIndex]
        addChild(newViewController)
        
        if let oldViewController = currentViewController {
            newViewController.view.alpha = 0
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(newViewController.view)
            newViewController.view.constraintToSuperviewBottom(usingHeight: newViewController.preferredContentSize.height)
            self.view.layoutIfNeeded()
            contentHeightConstraint.constant = newViewController.preferredContentSize.height
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            oldViewController.view.alpha = 0
                            newViewController.view.alpha = 1
                            
                            self.view.layoutIfNeeded() // Animate height constraint
                            
            }, completion: { (_) in
                            oldViewController.removeFromParent()
                            oldViewController.view.removeFromSuperview()
                            oldViewController.view.alpha = 1
                            
            })
        } else {
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(newViewController.view)
            newViewController.view.constraintToSuperviewBottom(usingHeight: newViewController.preferredContentSize.height)
            newViewController.view.layoutIfNeeded()
            contentHeightConstraint.constant = newViewController.preferredContentSize.height
        }
        
        currentViewController = newViewController
        preferredContentSize = CGSize(width: 1720, height: newViewController.preferredContentSize.height + tabBar.frame.height)
    }
}

// MARK: - Actions
extension ViuPanelViewController {
   
    @objc func collapse(_ sender: Any) {
        
        //焦点在Cell时，手势上滑焦点为tabBar
        if isCellFocus {
            focusEnvironments = [tabBar]
            setNeedsFocusUpdate()
        } else {
            //焦点在Tabbar时，手势上滑触发退出
            dismiss(animated: true) { self.delegate?.panelViewControllerDidDismiss(self) }
        }
    }
    
    @objc func tapMenuAction(_ sender: Any) {
        dismiss(animated: true) { self.delegate?.panelViewControllerDidDismiss(self) }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
            
        if (context.nextFocusedItem as? PVAudioTableCell) != nil {
            // 焦点在PVAudioTableCell，上滑手势取消
            swipUp.removeTarget(self, action: #selector(collapse(_ :)))
        } else {
            swipUp.addTarget(self, action: #selector(collapse(_ :)))
        }
        
        // 判断焦点是否在Cell
        isCellFocus = (context.nextFocusedItem as? PVSubtitleCell) != nil
            || (context.nextFocusedItem as? PVAudioTableCell) != nil
    }
}

// MARK: - UIView extension
private extension UIView {
    func constraintToSuperviewBottom(usingHeight height: CGFloat) {
        guard let superview = self.superview else {
            return
        }
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 10).isActive = true
//        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }
}

extension ViuPanelViewController: PVAudioTableModelDelegate {
    
    func pvAudioTableSelectValue(_ string: String) {
        print(string)
    }
}

extension ViuPanelViewController: PVSubtitleModelDelegate {
    
    func pvSubtitleSelectValue(_ string: String) {
        print(string)
    }
}
