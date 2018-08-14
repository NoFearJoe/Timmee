//
//  UIFont+Avenir.swift
//  Agile diary
//
//  Created by i.kharabet on 14.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

extension UIFont {
    
    public static func avenirNextRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: size) ?? .systemFont(ofSize: size)
    }
    
    public static func avenirNextMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }
    
    public static func avenirNextBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }
    
}
