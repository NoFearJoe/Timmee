//
//  UISearchBar+barBackgroundColor.swift
//  Workset
//
//  Created by i.kharabet on 29/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public extension UISearchBar {
    
    var barBackgroundColor: UIColor? {
        get {
            return findTextField()?.backgroundColor
        }
        set {
            findTextField()?.backgroundColor = newValue
        }
    }
    
    private func findTextField() -> UITextField? {
        for view in subviews {
            for subview in view.subviews {
                guard subview.isKind(of: UITextField.self) else { continue }
                return subview as? UITextField
            }
        }
        return nil
    }
    
}
