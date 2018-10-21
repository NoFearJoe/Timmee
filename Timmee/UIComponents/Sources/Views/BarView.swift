//
//  BarView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 07.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

open class BarView: UIView {

    @IBInspectable open var cornerRadius: CGFloat = 8
    
    open var shadowRadius: CGFloat = 4 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    open var showShadow: Bool = false {
        didSet {
            layer.shadowColor = showShadow ? UIColor.black.cgColor : UIColor.clear.cgColor
            layer.shadowOffset = CGSize(width: 0, height: -1)
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = 0.4
        }
    }
    
    open var roundedCorners: UIRectCorner = [.topRight, .topLeft]
    
    private let containerLayer = CALayer()
    
    open override var backgroundColor: UIColor? {
        didSet {
            containerLayer.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(containerLayer, at: 0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.insertSublayer(containerLayer, at: 0)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius
        containerLayer.frame = layer.bounds
        
        if showShadow {
            layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                            byRoundingCorners: roundedCorners,
                                            cornerRadii: CGSize(width: 8, height: 8)).cgPath
        } else {
            layer.shadowPath = nil
        }
        
        applyRoundCornersMask()
    }
    
    private func applyRoundCornersMask() {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: roundedCorners,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        if layer.mask == nil {
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            
            containerLayer.mask = maskLayer
        } else {
            guard let maskLayer = containerLayer.mask as? CAShapeLayer else { return }
            if let animation = layer.animation(forKey: "bounds.size")?.copy() as? CABasicAnimation {
                animation.keyPath = "path"
                animation.fromValue = maskLayer.path
                animation.toValue = maskPath.cgPath
                maskLayer.path = maskPath.cgPath
                maskLayer.add(animation, forKey: "path")
            } else {
                maskLayer.path = maskPath.cgPath
            }
        }
    }

}

public final class RoundedViewWithShadow: UIView {
    
    @IBInspectable public var cornerRadius: CGFloat = 8 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable public var shadowRadius: CGFloat = 8 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable public var shadowOpacity: Float = 0.2 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.2
    }
    
}
