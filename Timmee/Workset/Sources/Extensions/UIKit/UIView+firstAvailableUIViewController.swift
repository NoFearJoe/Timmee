//
//  UIView+firstAvailableUIViewController.swift
//  Workset
//
//  Created by i.kharabet on 15/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public extension UIView {
    
    func firstAvailableUIViewController() -> UIViewController? {
        if let nextViewControllerResponder = next as? UIViewController {
            return nextViewControllerResponder
        } else if let nextViewResponder = next as? UIView {
            return nextViewResponder.firstAvailableUIViewController()
        }
        
        return nil
    }
    
}
