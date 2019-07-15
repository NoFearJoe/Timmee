//
//  UIWindow+Snapshot.swift
//  Workset
//
//  Created by i.kharabet on 15/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public extension UIWindow {
    
    var snapshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, screen.scale)
        drawHierarchy(in: frame, afterScreenUpdates: false)
        guard let snapshotImage = UIGraphicsGetImageFromCurrentImageContext() else {
            assert(false, "Can't create snapshot()")
            return UIImage()
        }
        UIGraphicsEndImageContext()
        
        return snapshotImage
    }
    
}
