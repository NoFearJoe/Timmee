//
//  UIViewController+Extensions.swift
//  UIComponents
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    public func performAppearanceTransition(isAppearing: Bool, animated: Bool = false, action: () -> Void) {
        beginAppearanceTransition(isAppearing, animated: animated)
        action()
        endAppearanceTransition()
    }
    
}
