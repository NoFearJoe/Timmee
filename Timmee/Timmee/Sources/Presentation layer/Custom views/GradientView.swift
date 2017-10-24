//
//  GradientView.swift
//  Test
//
//  Created by i.kharabet on 22.08.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

@IBDesignable final class GradientView: UIView {
    
    @IBInspectable var startAlpha: CGFloat = 0.25 {
        didSet { updateColors() }
    }
    @IBInspectable var color: UIColor = .white {
        didSet {
            updateColors()
        }
    }
    @IBInspectable var startLocation: CGFloat = 0 {
        didSet { updateLocations() }
    }
    @IBInspectable var endLocation: CGFloat = 1 {
        didSet { updateLocations() }
    }
    @IBInspectable var isVertical: Bool = true {
        didSet { updatePoints() }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLocations()
        updatePoints()
    }
}
