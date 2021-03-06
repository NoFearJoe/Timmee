//
//  String+Placeholder.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSAttributedString
import struct UIKit.NSAttributedStringKey

public extension String {
    
    var asPlaceholder: NSAttributedString {
        let attributes = [NSAttributedString.Key.foregroundColor: AppTheme.current.backgroundTintColor.withAlphaComponent(0.5)]
        return NSAttributedString(string: self,
                                  attributes: attributes)
    }
    
    var asForegroundPlaceholder: NSAttributedString {
        let attributes = [NSAttributedString.Key.foregroundColor: AppTheme.current.secondaryTintColor]
        return NSAttributedString(string: self,
                                  attributes: attributes)
    }
    
}
