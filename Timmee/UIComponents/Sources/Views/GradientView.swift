//
//  GradientView.swift
//  Test
//
//  Created by i.kharabet on 22.08.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

open class GradientView: UIView {
    
    @IBInspectable public var startColor: UIColor = .white {
        didSet {
            self.updateColors()
        }
    }
    @IBInspectable public var endColor: UIColor = .black {
        didSet {
            self.updateColors()
        }
    }
    
    @IBInspectable public var startLocation: CGFloat = 0 {
        didSet {
            self.updateLocations()
        }
    }
    @IBInspectable public var endLocation: CGFloat = 1 {
        didSet {
            self.updateLocations()
        }
    }
    
    @IBInspectable public var startPoint: CGPoint = .zero {
        didSet {
            self.gradientLayer.startPoint = startPoint
        }
    }
    @IBInspectable public var endPoint: CGPoint = CGPoint(x: 0, y: 1) {
        didSet {
            self.gradientLayer.endPoint = endPoint
        }
    }
    
    override open static var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    public var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.updateLocations()
    }
}

private extension GradientView {
    
    func updateLocations() {
        self.gradientLayer.locations = [self.startLocation as NSNumber, self.endLocation as NSNumber]
    }
    
    func updateColors() {
        self.gradientLayer.colors = [self.startColor.cgColor, self.endColor.cgColor]
    }
    
}

