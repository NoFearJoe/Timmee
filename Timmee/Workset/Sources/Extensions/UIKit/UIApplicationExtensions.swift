//
//  UIApplicationExtensions.swift
//  Workset
//
//  Created by i.kharabet on 15/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    static var sharedInExtension: UIApplication? = {
        let sharedApplicationSelector = NSSelectorFromString("sharedApplication")
        guard UIApplication.responds(to: sharedApplicationSelector) else {
            return nil
        }
        let sharedApplication = UIApplication.perform(sharedApplicationSelector)
        return sharedApplication?.takeUnretainedValue() as? UIApplication
    }()

    var activeWindowSnapshot: UIImage {
        return keyWindow?.snapshot ?? UIImage()
    }
    
}
