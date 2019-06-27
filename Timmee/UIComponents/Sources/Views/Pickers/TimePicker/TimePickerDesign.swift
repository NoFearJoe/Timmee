//
//  TimePickerDesign.swift
//  UIComponents
//
//  Created by i.kharabet on 26/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public struct TimePickerDesign {
    
    let tintColor: UIColor
    let secondaryTintColor: UIColor
    let thirdlyTintColor: UIColor
    
    let timeFont: UIFont
    let hintsFont: UIFont
    
    public init(tintColor: UIColor,
                secondaryTintColor: UIColor,
                thirdlyTintColor: UIColor,
                timeFont: UIFont,
                hintsFont: UIFont) {
        self.tintColor = tintColor
        self.secondaryTintColor = secondaryTintColor
        self.thirdlyTintColor = thirdlyTintColor
        self.timeFont = timeFont
        self.hintsFont = hintsFont
    }
    
}
