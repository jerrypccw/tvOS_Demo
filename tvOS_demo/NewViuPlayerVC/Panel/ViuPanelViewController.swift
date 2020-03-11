//
//  ViuPanelViewController.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/10.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit
import Foundation

class ViuPanelViewController: UIViewController {

    var tabBar: ViuFocusTabbar = ViuFocusTabbar()
//    var contentView: UIView!
//    var backgroundTopConstraint: NSLayoutConstraint!
//    var contentHeightConstraint: NSLayoutConstraint!
    
    private var currentViewController: UIViewController?
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
            
        }
    }

    private lazy var focusEnvironments: [UIFocusEnvironment] = [self.tabBar]
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return focusEnvironments
    }

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabbar()
        setupViewControllers()
        updateContentForSelection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tabBar.subviews[0].isHidden = true
//        backgroundTopConstraint.constant = -tabBar.frame.height
    }
    
    func setupTabbar() {
        
        view.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tabBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tabBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tabBar.heightAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    func setupViewControllers() {
        
        let vc1 = UIViewController()
        vc1.title = "Info"
        
        let vc2 = UIViewController()
        vc2.title = "Subtitle"
        
        let vc3 = UIViewController()
        vc3.title = "Audio"
        
        viewControllers = [vc1, vc2, vc3]
//        contentView.layer.masksToBounds = true
    }
    
    func updateTabBars() {
        guard viewIfLoaded != nil else {
            return
        }
        let items = viewControllers.enumerated().map { UITabBarItem(title: $1.title, image: nil, tag: $0) }
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
            
//            contentView.addSubview(newViewController.view)
            newViewController.view.constraintToSuperviewBottom(usingHeight: newViewController.preferredContentSize.height)
            self.view.layoutIfNeeded() // Force layout the previous constraints to avoid them to animate
            
//            self.contentHeightConstraint.constant = newViewController.preferredContentSize.height
            
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
//            contentView.addSubview(newViewController.view)
            newViewController.view.constraintToSuperviewBottom(usingHeight: newViewController.preferredContentSize.height)
            newViewController.view.layoutIfNeeded()
//            self.contentHeightConstraint.constant = newViewController.preferredContentSize.height
            
        }
        
        currentViewController = newViewController
        preferredContentSize = CGSize(width: 1920, height: newViewController.preferredContentSize.height + tabBar
            .frame.height)
    }
}

// MARK: - TabBar delegate
extension ViuPanelViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectedIndex = item.tag
    }
}

// MARK: - Actions
extension ViuPanelViewController {
   
    func collapse(_ sender: Any) {
        dismiss(animated: true) {

        }
    }

    func focusOnTabBar(_ sender: Any) {
        focusEnvironments = [tabBar]
        setNeedsFocusUpdate()
    }

    func focusOnContentView(_ sender: Any) {
        if let currentViewController = currentViewController {
            focusEnvironments = currentViewController.preferredFocusEnvironments
        } else {
            focusEnvironments = []
        }
        setNeedsFocusUpdate()
    }
}

// MARK: - UIView extension
private extension UIView {
    func constraintToSuperviewBottom(usingHeight height: CGFloat) {
        guard let superview = self.superview else {
            return
        }
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }
}
