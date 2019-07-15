//
//  TCSStackViewContainer.swift
//  TinkoffUIKit
//
//  Created by n.sidiropulo on 29/11/16.
//  Copyright © 2016 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

/// Scrollable container for stack view
final public class TCSStackViewContainer: UIScrollView, ITCSStackViewContainer {
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet var placeholderView: UIView!
    @IBOutlet private weak var additionalSpaceHeighEqualConstraint: NSLayoutConstraint!
    
    public var shouldAvoidContentInsetTouches = false
    public var shouldFillRemainingSpace: Bool {
        set {
            guard shouldFillRemainingSpace != newValue else { return }
            if newValue {
                stackView.insertArrangedSubview(placeholderView, at: numberOfViews)
            } else {
                placeholderView.removeFromSuperview()
            }
        }
        get {
            return placeholderView.superview != nil
        }
    }
    
    /// Определяет должен ли скролл bounce-иться с контентом меньше размеров экрана
    public var shouldBounceAlways = true {
        didSet {
            updateHeighEqualConstraint()
        }
    }
    
    // MARK: - Lifecycle
    
    override public func awakeAfter(using aDecoder: NSCoder) -> Any? {
        return super.awakeAfter(using: aDecoder)
//        return tcs.awakeAfterCoder()
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var checkPoint = point
        if shouldAvoidContentInsetTouches {
            checkPoint.y += min(0, contentOffset.y)
        }
        return super.point(inside: checkPoint, with: event)
    }
    
    override public var contentInset: UIEdgeInsets {
        didSet {
            updateHeighEqualConstraint()
            scrollIndicatorInsets.top = contentInset.top
        }
    }
    
    // MARK: - IStackViewContainer
    
    public func addView(_ view: UIView) {
        self.stackView.insertArrangedSubview(view, at: numberOfViews)
    }
    
    public func removeView(_ view: UIView) {
        view.removeFromSuperview()
    }

    public func removeAllViews() {
        for view in stackView.arrangedSubviews where view != placeholderView {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    public func insertView(_ view: UIView, at index: Int) {
        guard index <= numberOfViews else {
            return
        }
        
        self.stackView.insertArrangedSubview(view, at: index)
    }
    
    public func replaceView(_ oldView: UIView, with newView: UIView) {
        guard let indexOfOld = self.stackView.arrangedSubviews.index(of: oldView) else {
            return
        }
        
        if let indexOfNew = self.stackView.arrangedSubviews.index(of: newView) {
            self.stackView.exchangeSubview(at: indexOfOld, withSubviewAt: indexOfNew)
        } else {
            self.stackView.insertArrangedSubview(newView, at: indexOfOld)
            oldView.removeFromSuperview()
        }
    }
    
    public func placeController(_ controller: UIViewController, isHidden: Bool = false) {
        guard let parentViewController = firstAvailableUIViewController() else { assert(false); return }
        
        parentViewController.addChild(controller)
        self.addView(controller.view)
        controller.didMove(toParent: controller.parent)
        controller.view.isHidden = isHidden
    }
    
    public var numberOfViews: Int {
        if shouldFillRemainingSpace {
            return self.stackView.arrangedSubviews.count - 1
        }
        return self.stackView.arrangedSubviews.count
    }
    
    // MARK: - Private
    
    private func updateHeighEqualConstraint() {
        var newValue = -(contentInset.top + contentInset.bottom)
        if shouldBounceAlways {
            newValue += 1
        }
        
        additionalSpaceHeighEqualConstraint.constant = newValue
    }
}
