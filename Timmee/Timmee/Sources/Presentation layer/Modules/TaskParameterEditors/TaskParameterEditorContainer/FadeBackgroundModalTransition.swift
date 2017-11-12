//
//  FadeBackgroundModalTransition.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class FadeInBackgroundModalTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            
            let backgroundView = makeClearView(size: UIScreen.main.bounds.size)
            transitionContext.containerView.addSubview(backgroundView)
            
            transitionContext.containerView.addSubview(toViewController.view)
            
            let duration = self.transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations:
                {
                    backgroundView.backgroundColor = AppTheme.current.secondaryTintColor
                },
                completion: { (complete) in
                    transitionContext.completeTransition(complete)
                }
            )
        }
    }
    
    private func makeClearView(size: CGSize) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: size))
        view.backgroundColor = .clear
        view.tag = 902
        return view
    }
    
}

final class FadeOutBackgroundModalTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let backgroundView = findBackgroundView(in: transitionContext.containerView)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration,
                       animations:
            {
                backgroundView.backgroundColor = .clear
            },
            completion: { (complete) in
                backgroundView.removeFromSuperview()
                transitionContext.completeTransition(complete)
            }
        )
    }
    
    private func findBackgroundView(in view: UIView) -> UIView {
        return view.viewWithTag(902)!
    }
    
}
