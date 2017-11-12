//
//  UIView+nib.swift
//  Timmee
//
//  Created by Ilya Kharabet on 21.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

extension UIView {
    
    static func loadedFromNib<T: UIView>(named name: String? = nil) -> T {
        let nibName = name ?? String(describing: T.classForCoder())
        return UINib(nibName: nibName,
                     bundle: nil)
            .instantiate(withOwner: nil,
                         options: nil)
            .first as! T
    }
    
}
