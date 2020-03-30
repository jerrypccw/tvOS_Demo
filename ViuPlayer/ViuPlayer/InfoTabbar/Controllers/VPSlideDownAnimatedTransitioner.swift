//
//  SlideDownAnimatedTransitioner.swift
//  tvOS_demo
//
//  Created by Jerry He on 2020/3/10.
//  Copyright © 2020 jerry. All rights reserved.
//

import UIKit

private let animatonDuration = 0.5

// MARK: SlideDown
class VPSlideDownAnimatedTransitioner: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animatonDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let secondVCView = transitionContext.view(forKey: .to),
            let secondVC = transitionContext.viewController(forKey: .to) else {
                return
        }
        let firstVCView = transitionContext.containerView
        firstVCView.addSubview(secondVCView)
        secondVCView.frame.origin.y = -secondVC.preferredContentSize.height

        UIView.animate(withDuration: animatonDuration,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: .allowUserInteraction, animations: {
                        secondVCView.frame.origin.y = 0 },
                       completion: { _ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)})
        
    }
}

// MARK: SlideUp
class VPSlideUpAnimatedTransitioner: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animatonDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let secondVCView = transitionContext.view(forKey: .from),
         let secondVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        secondVCView.frame.origin.y = 0
        UIView.animate(withDuration: animatonDuration,
                       delay: 0.0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: .allowUserInteraction,
                       animations: { secondVCView.frame.origin.y = -secondVC.preferredContentSize.height  },
                       completion: { _ in
                        secondVCView.removeFromSuperview()
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)})
    }
}
