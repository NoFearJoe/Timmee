//
//  UIView+Extensions.swift
//  UIComponents
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func configureShadow(radius: CGFloat, opacity: Float, color: UIColor = .black, offset: CGSize = .zero) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
    
}