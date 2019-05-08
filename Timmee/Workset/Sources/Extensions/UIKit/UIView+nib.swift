//
//  UIView+nib.swift
//  Timmee
//
//  Created by Ilya Kharabet on 21.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

public extension UIView {
    
    static func loadedFromNib(named name: String? = nil) -> Self {
        return self.loadFromNib(named: name)
    }
    
    private static func loadFromNib<T: UIView>(named name: String? = nil) -> T {
        let nibName = name ?? String(describing: T.classForCoder())
        return UINib(nibName: nibName,
                     bundle: Bundle(for: T.self))
            .instantiate(withOwner: nil,
                         options: nil)
            .first as! T
    }
    
}
