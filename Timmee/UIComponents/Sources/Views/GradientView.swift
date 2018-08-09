//
//  GradientView.swift
//  Test
//
//  Created by i.kharabet on 22.08.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

@IBDesignable public final class GradientView: UIView {
    
    @IBInspectable public var startAlpha: CGFloat = 0.25 {
        didSet { updateColors() }
    }
    @IBInspectable public var color: UIColor = .white {
        didSet {
            updateColors()
        }
    }
    @IBInspectable public var startLocation: CGFloat = 0 {
        didSet { updateLocations() }
    }
    @IBInspectable public var endLocation: CGFloat = 1 {
        didSet { updateLocations() }
    }
    @IBInspectable public var isVertical: Bool = true {
        didSet { updatePoints() }
    }
    
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    public var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    func updatePoints() {
        gradientLayer.startPoint = isVertical ? CGPoint(x: 0, y: 0) : CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = isVertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [color.withAlphaComponent(startAlpha).cgColor, color.cgColor]
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLocations()
        updatePoints()
    }
}
