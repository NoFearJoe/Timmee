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
            
            toViewController.view.alpha = 0
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations:
                {
                    toViewController.view.alpha = 1
                    backgroundView.backgroundColor = AppTheme.current.backgroundColor.withAlphaComponent(0.8)
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
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration,
                       animations:
            {
                fromViewController.view.alpha = 0
                backgroundView.backgroundColor = .clear
            },
            completion: { (complete) in
                backgroundView.removeFromSuperview()
                fromViewController.dismiss(animated: false, completion: nil)
                transitionContext.completeTransition(complete)
            }
        )
    }
    
    private func findBackgroundView(in view: UIView) -> UIView {
        return view.viewWithTag(902)!
    }
    
}
