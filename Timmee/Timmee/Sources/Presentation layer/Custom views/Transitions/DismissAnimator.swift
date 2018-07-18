//
//  DismissAnimator.swift
//  Timmee
//
//  Created by i.kharabet on 18.07.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
//        guard let sourceViewSnapshot = source.view.snapshotView(afterScreenUpdates: true) else { return }
        
//        transitionContext.containerView.addSubview(sourceViewSnapshot)
//        source.view.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                           source.view.transform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.frame.height)
                       }) { finished in
                           guard !transitionContext.transitionWasCancelled, finished else {
                            print("!completed")
                            transitionContext.completeTransition(false)
                            return
                        }
//                           source.view.isHidden = false
//                           sourceViewSnapshot.removeFromSuperview()
                           print("completed")
                           source.removeFromParentViewController()
                           transitionContext.completeTransition(true)
                       }
    }
    
}
