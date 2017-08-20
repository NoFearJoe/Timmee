//
//  UIImage+tint.swift
//  Alias
//
//  Created by Ilya Kharabet on 09.01.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct CoreGraphics.CGRect
import class UIKit.UIImage
import class UIKit.UIColor
import func UIKit.UIGraphicsBeginImageContextWithOptions
import func UIKit.UIGraphicsGetCurrentContext
import func UIKit.UIGraphicsGetImageFromCurrentImageContext
import func UIKit.UIGraphicsEndImageContext

extension UIImage {
    
    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.setBlendMode(.normal)
        
        let rect = CGRect(origin: .zero, size: size)
        context?.clip(to: rect, mask: cgImage!)
        color.setFill()
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func translucent() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let bounds = CGRect(origin: .zero, size: size)
        
        draw(in: bounds, blendMode: .screen, alpha: 1)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
