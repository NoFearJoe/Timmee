//
//  CalendarDesign.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public struct CalendarDesign {
    
    public let defaultBackgroundColor: UIColor
    public let defaultTintColor: UIColor
    public let selectedBackgroundColor: UIColor
    public let selectedTintColor: UIColor
    public let disabledBackgroundColor: UIColor
    public let disabledTintColor: UIColor
    public let weekdaysColor: UIColor
    public let badgeBackgroundColor: UIColor
    public let badgeTintColor: UIColor
    
    public init(defaultBackgroundColor: UIColor,
                defaultTintColor: UIColor,
                selectedBackgroundColor: UIColor,
                selectedTintColor: UIColor,
                disabledBackgroundColor: UIColor,
                disabledTintColor: UIColor,
                weekdaysColor: UIColor,
                badgeBackgroundColor: UIColor,
                badgeTintColor: UIColor) {
        self.defaultBackgroundColor = defaultBackgroundColor
        self.defaultTintColor = defaultTintColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.selectedTintColor = selectedTintColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.disabledTintColor = disabledTintColor
        self.weekdaysColor = weekdaysColor
        self.badgeBackgroundColor = badgeBackgroundColor
        self.badgeTintColor = badgeTintColor
    }
    
}
