//
//  UIDevice+Idiom.swift
//  Timmee
//
//  Created by i.kharabet on 31.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public extension UIDevice {
    
    public var isIpad: Bool {
        return userInterfaceIdiom == .pad
    }
    
    public var isPhone: Bool {
        return userInterfaceIdiom == .phone
    }
    
}
