//
//  UIViewController+Extensions.swift
//  UIComponents
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func performAppearanceTransition(isAppearing: Bool, animated: Bool = false, action: () -> Void) {
        beginAppearanceTransition(isAppearing, animated: animated)
        action()
        endAppearanceTransition()
    }
    
}

public extension UIWindow {
    
    var topViewController: UIViewController? {
        rootViewController?.topViewController
    }
    
}

private extension UIViewController {

    var topViewController: UIViewController? {
        if let presented = self.presentedViewController {
            return presented.topViewController
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topViewController ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topViewController ?? tab
        }
        
        return self
    }

}
