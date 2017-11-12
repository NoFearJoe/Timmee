//
//  PassthrowView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 07.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

class PassthrowView: UIView {

    var shouldPassTouches = true
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard shouldPassTouches else { return true }
        return pointInside(point, inside: subviews, with: event)
    }
    
    fileprivate func pointInside(_ point: CGPoint,
                                 inside subviews: [UIView],
                                 with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview is PassthrowView {
                return pointInside(self.convert(point, to: subview),
                                   inside: subview.subviews,
                                   with: event)
            } else {
                if !subview.isHidden && subview.point(inside: self.convert(point,
                                                                           to: subview),
                                                      with: event) {
                    return true
                }
                continue
            }
        }
        return false
    }

}
