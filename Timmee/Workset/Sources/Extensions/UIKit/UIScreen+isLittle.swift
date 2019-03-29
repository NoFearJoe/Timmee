//
//  UIScreen+isLittle.swift
//  Workset
//
//  Created by Илья Харабет on 29/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

extension UIScreen {
    
    public var isLittle: Bool {
        return bounds.width <= 320
    }
    
}
