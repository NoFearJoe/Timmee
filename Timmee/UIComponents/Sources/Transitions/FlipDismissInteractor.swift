//
//  FlipDismissInteractor.swift
//  Timmee
//
//  Created by i.kharabet on 23.07.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public final class FlipDismissInteractor: NSObject {
    
    public let interactor = Interactor()
    
    public func interactWith(panGestureRecognizer recognizer: UIPanGestureRecognizer, onClose: (() -> Void)?, onCancel: (() -> Void)?) {
        let treshold: CGFloat = 0.4
        
        let translation = recognizer.translation(in: recognizer.view)
        let verticalMovement = translation.y / (recognizer.view?.bounds.height ?? 1)
        let progress = max(0, min(1, verticalMovement))
        
        switch recognizer.state {
        case .began:
            interactor.hasStarted = true
            onClose?()
        case .changed:
            interactor.shouldFinish = progress > treshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
            onCancel?()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
            onCancel?()
        default:
            break
        }
    }
    
    public class Interactor: UIPercentDrivenInteractiveTransition {
        public var hasStarted = false
        public var shouldFinish = false
    }
    
}

extension FlipDismissInteractor: UIViewControllerTransitioningDelegate {
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
}
