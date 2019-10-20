//
//  CalendarPresentationController.swift
//  UIComponents
//
//  Created by Илья Харабет on 20/10/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class CalendarPresentationController: UIPresentationController {
    
    private unowned let sourceView: UIView
    
    private let dimmingView = UIView()
    
    private var calendarViewController: CalendarViewController {
        return presentedViewController as! CalendarViewController
    }
    
    public init(calendarViewController: CalendarViewController, presentingViewController: UIViewController?, sourceView: UIView) {
        self.sourceView = sourceView
        
        super.init(presentedViewController: calendarViewController, presenting: presentingViewController)
        
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapToBackground))
        tapRecognizer.delegate = self
        dimmingView.addGestureRecognizer(tapRecognizer)
        
        calendarViewController.view.layer.cornerRadius = 8
        calendarViewController.view.clipsToBounds = true
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        let containerSize = containerView?.frame.size ?? .zero
        
        let sourceViewRect = sourceView.convert(sourceView.frame, to: containerView)
        
        let y: CGFloat = sourceViewRect.maxY + 20
        
        if UIDevice.current.isPhone {
            calendarViewController.view.frame.size.width = containerSize.width - 40
            
            calendarViewController.view.layoutIfNeeded()
            
            return CGRect(x: 20, y: y, width: containerSize.width - 40, height: calendarViewController.maximumHeight)
        } else {
            calendarViewController.view.frame.size.width = 375
            
            calendarViewController.view.layoutIfNeeded()
            
            return CGRect(x: (containerSize.width - 375) / 2, y: y, width: 375, height: calendarViewController.maximumHeight)
        }
    }
    
    public override func presentationTransitionWillBegin() {
        guard
            let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator
        else { return }
        
        dimmingView.alpha = 0
        dimmingView.frame = container.bounds
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)
        
        coordinator.animate(
            alongsideTransition: { [weak self] _ in
                guard let self = self else { return }
            
                self.dimmingView.alpha = 1
            },
            completion: nil
        )
    }
    
    public override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(
            alongsideTransition: { [weak self] _ in
                guard let `self` = self else { return }
            
                self.dimmingView.alpha = 0
            },
            completion: nil
        )
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }
        dimmingView.removeFromSuperview()
    }
    
    @objc private func onTapToBackground() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
}

extension CalendarPresentationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === dimmingView
    }
    
}
