//
//  ModalPresentingViewController.swift
//  Timmee
//
//  Created by i.kharabet on 24.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class ModalPresentationTransitionHandler: NSObject, UIViewControllerTransitioningDelegate {
    
    let dismissTransitionController = InteractiveDismissTransition()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalDismissalTransition()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissTransitionController.hasStarted ? dismissTransitionController : nil
    }
    
}

final class FadePresentationTransitionHandler: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInBackgroundModalTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeOutBackgroundModalTransition()
    }
    
}
