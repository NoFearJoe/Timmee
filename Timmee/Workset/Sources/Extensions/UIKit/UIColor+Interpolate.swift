//
//  UIColor+Interpolate.swift
//  Alias
//
//  Created by Ilya Kharabet on 05.02.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIColor
import CoreGraphics


public extension UIColor {

    class func interpolate(from: UIColor, to: UIColor, fraction: CGFloat) -> UIColor {
        let f: CGFloat = min(1, max(0, fraction))
        
        if let fromColorComponents = from.cgColor.components,
           let toColorComponents = to.cgColor.components {
            let red = fromColorComponents[0] + (toColorComponents[0] - fromColorComponents[0]) * f
            let green = fromColorComponents[1] + (toColorComponents[1] - fromColorComponents[1]) * f
            let blue = fromColorComponents[2] + (toColorComponents[2] - fromColorComponents[2]) * f
            let alpha = fromColorComponents[3] + (toColorComponents[3] - fromColorComponents[3]) * f
            
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        return from
    }

}
