//
//  ModalPresentingViewController.swift
//  Timmee
//
//  Created by i.kharabet on 24.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public final class ModalPresentationTransitionHandler: NSObject, UIViewControllerTransitioningDelegate {
    
    public let dismissTransitionController = InteractiveDismissTransition()
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationTransition()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalDismissalTransition()
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissTransitionController.hasStarted ? dismissTransitionController : nil
    }
    
}

public final class FadePresentationTransitionHandler: NSObject, UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInBackgroundModalTransition()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeOutBackgroundModalTransition()
    }
    
}
