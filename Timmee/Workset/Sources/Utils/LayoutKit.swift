//
//  LayoutKit.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct UIKit.CGFloat
import class UIKit.UIView
import enum UIKit.NSLayoutRelation
import enum UIKit.NSLayoutAttribute
import class UIKit.NSLayoutConstraint

public struct Constraint {
    let view: UIView
    let attribute1: NSLayoutConstraint.Attribute
    let attribute2: NSLayoutConstraint.Attribute
    let relation: NSLayoutConstraint.Relation
    let multiplier: CGFloat
    let constant: CGFloat
    
    init(view: UIView,
         attribute1: NSLayoutConstraint.Attribute,
         attribute2: NSLayoutConstraint.Attribute,
         relation: NSLayoutConstraint.Relation = .equal,
         multiplier: CGFloat = 1,
         constant: CGFloat = 0) {
        self.view = view
        self.attribute1 = attribute1
        self.attribute2 = attribute2
        self.relation = relation
        self.multiplier = multiplier
        self.constant = constant
    }
}

public extension Constraint {
    
    @discardableResult
    func to(_ view: UIView, addTo containerView: UIView? = nil) -> NSLayoutConstraint {
        self.view.translatesAutoresizingMaskIntoConstraints = false

        let constraint = NSLayoutConstraint(item: self.view,
                                            attribute: attribute1,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: attribute2,
                                            multiplier: multiplier,
                                            constant: constant)
        
        if let containerView = containerView {
            containerView.addConstraint(constraint)
        } else {
            view.addConstraint(constraint)
        }
        
        return constraint
    }
    
    @discardableResult
    func toSuperview() -> NSLayoutConstraint? {
        guard let superview = view.superview else { return nil }
        return to(superview)
    }
    
    @discardableResult
    func to(_ guide: UILayoutGuide, addTo containerView: UIView? = nil) -> NSLayoutConstraint? {
        view.translatesAutoresizingMaskIntoConstraints = false

        let constraint = NSLayoutConstraint(item: view,
                                            attribute: attribute1,
                                            relatedBy: .equal,
                                            toItem: guide,
                                            attribute: attribute2,
                                            multiplier: multiplier,
                                            constant: constant)

        if let containerView = containerView {
            containerView.addConstraint(constraint)
        } else {
            view.superview?.addConstraint(constraint)
        }

        return constraint
    }
    
}

public extension Array where Element == Constraint {
    
    @discardableResult
    func to(_ view: UIView, addTo containerView: UIView? = nil) -> [NSLayoutConstraint] {
        map { constraint in
            constraint.to(view, addTo: containerView)
        }
    }
    
    @discardableResult
    func toSuperview() -> [NSLayoutConstraint] {
        compactMap { constraint in
            constraint.toSuperview()
        }
    }
    
    @discardableResult
    func to(_ guide: UILayoutGuide, addTo containerView: UIView? = nil) -> [NSLayoutConstraint] {
        compactMap {
            $0.to(guide, addTo: containerView)
        }
    }
    
}

public extension UIView {
    
    // MARK: - Sides
    
    func top(_ offset: CGFloat = 0) -> Constraint {
        return Constraint(view: self, attribute1: .top, attribute2: .top, relation: .equal, constant: offset)
    }
    
    func bottom(_ offset: CGFloat = 0) -> Constraint {
        return Constraint(view: self, attribute1: .bottom, attribute2: .bottom, relation: .equal, multiplier: 1, constant: -offset)
    }
    
    func leading(_ offset: CGFloat = 0) -> Constraint {
        return Constraint(view: self, attribute1: .leading, attribute2: .leading, relation: .equal, multiplier: 1, constant: offset)
    }
    
    func trailing(_ offset: CGFloat = 0) -> Constraint {
        return Constraint(view: self, attribute1: .trailing, attribute2: .trailing, relation: .equal, multiplier: 1, constant: -offset)
    }
    
    
    func topToBottom(_ offset: CGFloat = 0) -> Constraint {
        return Constraint(view: self, attribute1: .top, attribute2: .bottom, constant: offset)
    }
    
    func bottomToTop(_ offset: CGFloat = 0) -> Constraint {
        return Constraint(view: self, attribute1: .bottom, attribute2: .top, constant: offset)
    }
    
    func leadingToTrailing(_ offset: CGFloat = 0) -> Constraint {
        return Constraint(view: self, attribute1: .leading, attribute2: .trailing, constant: offset)
    }
    
    func trailingToLeading(_ offset: CGFloat = 0) -> Constraint {
        return Constraint(view: self, attribute1: .trailing, attribute2: .leading, constant: offset)
    }
    
    
    func allEdges(_ offset: CGFloat = 0) -> [Constraint] {
        return [
            top(offset),
            bottom(offset),
            trailing(offset),
            leading(offset)
        ]
    }
    
    // MARK: - Center
    
    func centerX() -> Constraint {
        return Constraint(view: self, attribute1: .centerX, attribute2: .centerX)
    }
    
    func centerY() -> Constraint {
        return Constraint(view: self, attribute1: .centerY, attribute2: .centerY)
    }
    
    // MARK: - Size
    
    private func size(_ attribute: NSLayoutConstraint.Attribute, constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: relation,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1,
                                            constant: constant)
        
        self.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    func width(_ constant: CGFloat) -> NSLayoutConstraint {
        return size(.width, constant: constant)
    }
    
    @discardableResult
    func width(lessOrEqual constant: CGFloat) -> NSLayoutConstraint {
        return size(.width, constant: constant, relation: .lessThanOrEqual)
    }
    
    @discardableResult
    func width(greatherOrEqual constant: CGFloat) -> NSLayoutConstraint {
        return size(.width, constant: constant, relation: .greaterThanOrEqual)
    }
    
    @discardableResult
    func height(_ constant: CGFloat) -> NSLayoutConstraint {
        return size(.height, constant: constant)
    }
    
    @discardableResult
    func height(lessOrEqual constant: CGFloat) -> NSLayoutConstraint {
        return size(.height, constant: constant, relation: .lessThanOrEqual)
    }
    
    @discardableResult
    func height(greatherOrEqual constant: CGFloat) -> NSLayoutConstraint {
        return size(.height, constant: constant, relation: .greaterThanOrEqual)
    }
    
    @discardableResult
    func aspectRatio() -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .width,
                                            multiplier: 1,
                                            constant: 0)
        
        self.addConstraint(constraint)
        
        return constraint
    }
    
}
