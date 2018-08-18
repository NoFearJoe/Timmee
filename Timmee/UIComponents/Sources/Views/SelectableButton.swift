//
//  SelectableButton.swift
//  UIComponents
//
//  Created by i.kharabet on 17.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

open class SelectableButton: UIButton {
    
    @IBInspectable open var selectedBackgroundColor: UIColor = .black
    @IBInspectable open var defaultBackgroundColor: UIColor = .black
    
    open override var isSelected: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    private func updateBackgroundColor() {
        backgroundColor = isSelected || isHighlighted ? selectedBackgroundColor : defaultBackgroundColor
    }
    
}
