//
//  FadeTransition.swift
//  UIComponents
//
//  Created by i.kharabet on 21/10/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class FadeInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
                        
        transitionContext.containerView.addSubview(toViewController.view)
        
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        toViewController.view.alpha = 0
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                toViewController.view.alpha = 1
            },
            completion: { complete in
                transitionContext.completeTransition(complete)
            }
        )
    }
    
}

public final class FadeOutTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            animations: {
                fromViewController.view.alpha = 0
            },
            completion: { (complete) in
//                fromViewController.dismiss(animated: false, completion: nil)
                transitionContext.completeTransition(complete)
            }
        )
    }
    
    
}
