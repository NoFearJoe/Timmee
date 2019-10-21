//
//  CalendarTransitionHandler.swift
//  UIComponents
//
//  Created by Илья Харабет on 20/10/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class CalendarTransitionHandler: NSObject, UIViewControllerTransitioningDelegate {
    
    private unowned let sourceView: UIView
    
    public init(sourceView: UIView) {
        self.sourceView = sourceView
    }
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInTransition()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeOutTransition()
    }
    
    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        guard let calendar = presented as? CalendarViewController else { return nil }
        
        return CalendarPresentationController(calendarViewController: calendar,
                                              presentingViewController: presenting,
                                              sourceView: sourceView)
    }
    
}
