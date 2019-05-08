//
//  HintPopoverView.swift
//  UIComponents
//
//  Created by i.kharabet on 04.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public final class HintPopoverView: UIView {
    
    public var textLabel: UILabel?
    
    // Change leftInset and rightInset only before calling `show` method
    public var leftInset: CGFloat = 15.0 {
        willSet {
            assert(self.superview == nil, "leftInset should be changed before showing TipsPopoverView")
        }
    }
    public var rightInset: CGFloat = 15.0 {
        willSet {
            assert(self.superview == nil, "rightInset should be changed before showing TipsPopoverView")
        }
    }
    
    public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 12,
                                                         left: 16,
                                                         bottom: 12,
                                                         right: 9) {
        didSet {
            self.updateInsets()
        }
    }
    
    public var maximumWidth: CGFloat = 0 {
        didSet {
            if maximumWidth > 0 {
                if let constraint = self.widthContraint {
                    constraint.constant = maximumWidth
                } else {
                    self.widthContraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: maximumWidth)
                    self.addConstraint(self.widthContraint!)
                }
                
            } else if let constraint = self.widthContraint {
                self.removeConstraint(constraint)
                self.widthContraint = nil
            }
            self.layoutIfNeeded()
        }
    }
    
    public var willCloseBlock: (() -> Void)?
    public var didCloseBlock: (() -> Void)?
    
    private static var roundedViewCornerRadius: CGFloat = 6.0
    
    private var roundedView: UIView!
    private var triangleView: UIImageView!
    private var contentView: UIView?
    private weak var holderView: UIView?
    private weak var assignedView: UIView?
    private var distanceToAssignedView: CGFloat = 0
    
    private var leftInsetConstraint: NSLayoutConstraint!
    private var rightInsetConstraint: NSLayoutConstraint!
    private var topInsetConstraint: NSLayoutConstraint!
    private var bottomInsetConstraint: NSLayoutConstraint!
    private var triangleHorisontalPositionConstraint: NSLayoutConstraint!
    private var triangleVerticalPositionConstraint: NSLayoutConstraint!
    private var widthContraint: NSLayoutConstraint?
    
    private var statusBarSelectedObserver: NSObjectProtocol?
    
    private var showing = false
    
    private var popoverViewTopSpaceConstraint: NSLayoutConstraint?
    
    /// Выходит ли view за нижнюю границу.
    /// Присваивается перед показом
    /// Нужно для правильного отображения triangleView
    private var isBeyondBottom: Bool = false
    
    private static var messageLabel: UILabel {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        return textLabel
    }
    
    private func defaultSetup() {
        self.textLabel = UILabel()
        self.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.roundedView = UIView()
        self.roundedView.translatesAutoresizingMaskIntoConstraints = false
        self.roundedView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        self.roundedView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        self.triangleView = UIImageView(image: UIImage(named: "popoverTriangle"))
        self.triangleView.translatesAutoresizingMaskIntoConstraints = false
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
    
    @objc private func onTap() {
        hide()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.defaultSetup()
        
        self.customizeSelf()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("public init(coder:) has not been implemented")
    }
    
    public init(contentView: UIView) {
        super.init(frame: .zero)
        
        self.defaultSetup()
        
        self.contentView = contentView
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.customizeSelf()
    }
    
    public func updateTopSpace() {
        guard let view = self.assignedView,
            let superview = view.superview,
            let holder = self.holderView else { return }
        
        let position = superview.convert(view.center, to: holder)
        
        if position.y + self.estimatedHeight + self.distanceToAssignedView >= holder.bounds.height {
            self.isBeyondBottom = true
            self.popoverViewTopSpaceConstraint?.constant = position.y - self.distanceToAssignedView - self.triangleView.bounds.height
        } else {
            self.isBeyondBottom = false
            self.popoverViewTopSpaceConstraint?.constant = position.y + self.distanceToAssignedView
        }
    }
    
    public func updateTrianglePosition() {
        guard let view = self.assignedView,
            let superview = view.superview,
            let holder = self.holderView else { return }
        
        if let prevConstraint = self.triangleHorisontalPositionConstraint {
            self.removeConstraint(prevConstraint)
        }
        
        if let prevConstraint = self.triangleVerticalPositionConstraint {
            self.removeConstraint(prevConstraint)
        }
        
        self.updateTopSpace()
        
        let position = superview.convert(view.center, to: holder)
        
        if position.x <= self.leftInset {
            self.triangleHorisontalPositionConstraint = NSLayoutConstraint(item: self.triangleView!,
                                                                           attribute: .leading,
                                                                           relatedBy: .equal,
                                                                           toItem: self,
                                                                           attribute: .leading,
                                                                           multiplier: 1,
                                                                           constant: 0)
            self.triangleVerticalPositionConstraint = NSLayoutConstraint(item: self.roundedView!,
                                                                         attribute: .top,
                                                                         relatedBy: .equal,
                                                                         toItem: self.triangleView,
                                                                         attribute: .centerY,
                                                                         multiplier: 1,
                                                                         constant: 0)
            self.triangleView.image = #imageLiteral(resourceName: "popoverCornerTriangle")//.rotated(with: .down)
        } else if holder.bounds.width - position.x - HintPopoverView.roundedViewCornerRadius <= self.rightInset {
            self.triangleHorisontalPositionConstraint = NSLayoutConstraint(item: self.triangleView!,
                                                                           attribute: .trailing,
                                                                           relatedBy: .equal,
                                                                           toItem: self,
                                                                           attribute: .trailing,
                                                                           multiplier: 1,
                                                                           constant: 0)
            self.triangleVerticalPositionConstraint = NSLayoutConstraint(item: self.roundedView!,
                                                                         attribute: .top,
                                                                         relatedBy: .equal,
                                                                         toItem: self.triangleView,
                                                                         attribute: .centerY,
                                                                         multiplier: 1,
                                                                         constant: 0)
            self.triangleView.image = #imageLiteral(resourceName: "popoverCornerTriangle")
        } else if self.isBeyondBottom{
            self.triangleHorisontalPositionConstraint = NSLayoutConstraint(item: self.triangleView!,
                                                                           attribute: .centerX,
                                                                           relatedBy: .equal,
                                                                           toItem: self,
                                                                           attribute: .left,
                                                                           multiplier: 1,
                                                                           constant: position.x - self.leftInset)
            self.triangleVerticalPositionConstraint = NSLayoutConstraint(item: self.triangleView!,
                                                                         attribute: .top,
                                                                         relatedBy: .equal,
                                                                         toItem: self.roundedView,
                                                                         attribute: .bottom,
                                                                         multiplier: 1,
                                                                         constant: 0)
            self.triangleView.image = #imageLiteral(resourceName: "popoverTriangle")//.rotated(with: .down)
        } else {
            self.triangleHorisontalPositionConstraint = NSLayoutConstraint(item: self.triangleView!,
                                                                           attribute: .centerX,
                                                                           relatedBy: .equal,
                                                                           toItem: self,
                                                                           attribute: .left,
                                                                           multiplier: 1,
                                                                           constant: position.x - self.leftInset)
            self.triangleVerticalPositionConstraint = NSLayoutConstraint(item: self.roundedView!,
                                                                         attribute: .top,
                                                                         relatedBy: .equal,
                                                                         toItem: self.triangleView,
                                                                         attribute: .bottom,
                                                                         multiplier: 1,
                                                                         constant: 0)
            self.triangleView.image = #imageLiteral(resourceName: "popoverTriangle")
        }
        
        self.addConstraint(self.triangleHorisontalPositionConstraint)
        self.addConstraint(self.triangleVerticalPositionConstraint)
    }
    
    private func customizeSelf() {
        self.backgroundColor = UIColor.clear
        
        self.addSubview(self.triangleView)
        self.addSubview(self.roundedView)
        
        self.roundedView.layer.cornerRadius = HintPopoverView.roundedViewCornerRadius
        self.roundedView.backgroundColor = UIColor.white
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[rounded]-(0)-|",
                                                           options: [],
                                                           metrics: nil,
                                                           views: ["rounded": self.roundedView!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[rounded]-(0)-|",
                                                           options: [],
                                                           metrics: nil,
                                                           views: ["rounded": self.roundedView!]))
        
        self.updateTrianglePosition()
        
        if let contentView = self.contentView {
            self.roundedView.addSubview(contentView)
            
            self.leftInsetConstraint = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self.roundedView, attribute: .leading, multiplier: 1, constant: self.contentInset.left)
            self.roundedView.addConstraint(self.leftInsetConstraint)
            
            self.rightInsetConstraint = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self.roundedView, attribute: .trailing, multiplier: 1, constant: -self.contentInset.right)
            self.roundedView.addConstraint(self.rightInsetConstraint)
            
            self.topInsetConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self.roundedView, attribute: .top, multiplier: 1, constant: self.contentInset.top)
            self.roundedView.addConstraint(self.topInsetConstraint)
            
            self.bottomInsetConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self.roundedView, attribute: .bottom, multiplier: 1, constant: -self.contentInset.bottom)
            self.roundedView.addConstraint(self.bottomInsetConstraint)
        } else if let textLabel = self.textLabel {
            self.roundedView.addSubview(textLabel)
            
            self.leftInsetConstraint = NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal, toItem: self.roundedView, attribute: .leading, multiplier: 1, constant: self.contentInset.left)
            self.roundedView.addConstraint(self.leftInsetConstraint)
            
            self.rightInsetConstraint = NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal, toItem: self.roundedView, attribute: .trailing, multiplier: 1, constant: -self.contentInset.right)
            self.roundedView.addConstraint(self.rightInsetConstraint)
            
            self.topInsetConstraint = NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: self.roundedView, attribute: .top, multiplier: 1, constant: self.contentInset.top)
            self.roundedView.addConstraint(self.topInsetConstraint)
            
            self.bottomInsetConstraint = NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: self.roundedView, attribute: .bottom, multiplier: 1, constant: -self.contentInset.bottom)
            self.roundedView.addConstraint(self.bottomInsetConstraint)
        }
        
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 6.0
    }
    
    private func updateInsets() {
        self.leftInsetConstraint.constant = self.contentInset.left
        self.rightInsetConstraint.constant = -self.contentInset.right
        self.topInsetConstraint.constant = self.contentInset.top
        self.bottomInsetConstraint.constant = -self.contentInset.bottom
        self.layoutIfNeeded()
    }
    
    public func hide() {
        guard self.showing else { return }
        
        self.willCloseBlock?()
        self.showing = false
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.didCloseBlock?()
        }
    }
    
    public func show(from view: UIView,
                     distance: CGFloat,
                     holderView: UIView?) {
        guard !self.showing else { return }
        
        self.holderView = holderView
        self.assignedView = view
        self.distanceToAssignedView = distance
        
        guard let viewToAdd = self.holderView  else { return }
        self.showing = true
        
        self.alpha = 0
        self.removeFromSuperview()
        viewToAdd.addSubview(self)
        viewToAdd.bringSubviewToFront(self)
        
        viewToAdd.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: viewToAdd, attribute: .left, multiplier: 1, constant: self.leftInset))
        viewToAdd.addConstraint(NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: viewToAdd, attribute: .right, multiplier: 1, constant: -self.rightInset))
        
        let topSpaceConstraint = NSLayoutConstraint(item: self.triangleView!, attribute: .top, relatedBy: .equal, toItem: viewToAdd, attribute: .top, multiplier: 1, constant: 0)
        self.popoverViewTopSpaceConstraint = topSpaceConstraint
        self.updateTopSpace()
        
        viewToAdd.addConstraint(topSpaceConstraint)
        
        viewToAdd.layoutIfNeeded()
        
        self.updateTrianglePosition()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [UIView.AnimationOptions.allowUserInteraction], animations: {
            self.alpha = 1
        }, completion: nil)
    }
}

extension HintPopoverView {
    
    @discardableResult
    public class func showPopover(with message: String? = nil,
                                  attributedString: NSAttributedString? = nil,
                                  from view: UIView,
                                  holderView: UIView,
                                  leftInset: CGFloat = 15,
                                  rightInset: CGFloat = 15) -> HintPopoverView {
        HintPopoverView.roundedViewCornerRadius = 6.0
        let targetDistance: CGFloat = 20.0
        let label = HintPopoverView.messageLabel
        
        if let message = message {
            label.text = message
        } else if let attributed = attributedString {
            label.attributedText = attributed
        }
        
        return self.showPopoverView(with: label,
                                    from: view,
                                    holderView: holderView,
                                    targetDistance: targetDistance,
                                    leftInset: leftInset,
                                    rightInset: rightInset)
    }
    
    private class func showPopoverView(with contentView: UIView,
                                       from view: UIView,
                                       holderView: UIView,
                                       targetDistance: CGFloat,
                                       leftInset: CGFloat = 15,
                                       rightInset: CGFloat = 15) -> HintPopoverView {
        let popoverView = HintPopoverView(contentView: contentView)
        
        popoverView.didCloseBlock = { (view as? UIButton)?.isSelected = false }
        
        popoverView.maximumWidth = holderView.bounds.width - (leftInset + rightInset)
        popoverView.leftInset = leftInset
        popoverView.rightInset = rightInset
        
        popoverView.contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 15, right: 16)
        popoverView.show(from: view, distance: targetDistance, holderView: holderView)
        
        return popoverView
    }
    
}

private extension HintPopoverView {
    
    var estimatedHeight: CGFloat {
        return self.roundedView.systemLayoutSizeFitting(CGSize(width: self.maximumWidth, height: CGFloat.greatestFiniteMagnitude)).height + self.triangleView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
    
}
