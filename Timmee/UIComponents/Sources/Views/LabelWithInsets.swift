//
//  LabelWithInsets.swift
//  UIComponents
//
//  Created by Илья Харабет on 31/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

open class LabelWithInsets: UILabel {
    
    public var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public override func drawText(in rect: CGRect) {
        let rectWithInsets = rect.inset(by: insets)
        
        super.drawText(in: rectWithInsets)
    }
    
    open override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        
        return size
    }
    
}
