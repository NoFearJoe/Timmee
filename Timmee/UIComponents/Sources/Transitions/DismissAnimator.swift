//
//  DismissAnimator.swift
//  Timmee
//
//  Created by i.kharabet on 18.07.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public final class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                delay: 0,
                                options: .calculationModeLinear,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: 0.33,
                                                       animations: {
                                                           source.view.transform = CGAffineTransform(translationX: 0, y: 48)
                                                       })
                                    UIView.addKeyframe(withRelativeStartTime: 0.33,
                                                       relativeDuration: 0.67,
                                                       animations: {
                                                           source.view.transform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.frame.height)
                                                       })
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled && finished)
        }
    }
    
}
