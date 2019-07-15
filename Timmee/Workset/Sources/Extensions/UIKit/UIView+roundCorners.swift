//
//  UIView+roundCorners.swift
//  Workset
//
//  Created by i.kharabet on 15/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public extension UIView {
    
    @discardableResult
    func roundCorners(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let shape = CAShapeLayer()
        
        let cornerRadiiSize = CGSize(width: radius, height: radius)
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: cornerRadiiSize)
        
        shape.path = path.cgPath
        layer.mask = shape
        layer.masksToBounds = true
        
        return shape
    }
    
}
