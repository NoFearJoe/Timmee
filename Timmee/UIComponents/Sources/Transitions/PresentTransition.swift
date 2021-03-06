//
//  PresentTransition.swift
//  Timmee
//
//  Created by Ilya Kharabet on 16.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

public final class ModalPresentationTransition: NSObject, UIViewControllerAnimatedTransitioning {

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            
            let backgroundView = makeClearView(size: UIScreen.main.bounds.size)
            transitionContext.containerView.addSubview(backgroundView)
            
            transitionContext.containerView.addSubview(toViewController.view)
            
            let duration = self.transitionDuration(using: transitionContext)
            let frameHeight = fromViewController.view.frame.height
            
            toViewController.view.transform = CGAffineTransform(translationX: 0, y: frameHeight)
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations:
                {
                    backgroundView.backgroundColor = .black
                    toViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
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
        view.tag = 901
        return view
    }

}

public final class ModalDismissalTransition: NSObject, UIViewControllerAnimatedTransitioning {

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            
            guard let backgroundView = findBackgroundView(in: transitionContext.containerView) else { return }
            
            transitionContext.containerView.insertSubview(toViewController.view,
                                                          belowSubview: backgroundView)
            
            let duration = self.transitionDuration(using: transitionContext)
            let frameHeight = fromViewController.view.frame.height
            
            fromViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
            UIView.animate(withDuration: duration,
                           animations:
                {
                    backgroundView.backgroundColor = .clear
                    fromViewController.view.transform = CGAffineTransform(translationX: 0, y: frameHeight)
                },
                completion: { finished in
                    if !transitionContext.transitionWasCancelled, finished {
                        backgroundView.removeFromSuperview()
                    }
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled && finished)
                }
            )
        }
    }
    
    private func findBackgroundView(in view: UIView) -> UIView? {
        return view.viewWithTag(901)
    }

}
