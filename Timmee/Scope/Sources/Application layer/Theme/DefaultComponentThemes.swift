//
//  DefaultComponentThemes.swift
//  Scope
//
//  Created by i.kharabet on 27/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIComponents

let defaultCalendarDesign = CalendarDesign(defaultBackgroundColor: AppTheme.current.middlegroundColor,
                                           defaultTintColor: AppTheme.current.tintColor,
                                           selectedBackgroundColor: AppTheme.current.blueColor,
                                           selectedTintColor: AppTheme.current.backgroundTintColor,
                                           disabledBackgroundColor: AppTheme.current.panelColor,
                                           disabledTintColor: AppTheme.current.secondaryTintColor,
                                           weekdaysColor: AppTheme.current.backgroundColor,
                                           badgeBackgroundColor: AppTheme.current.redColor,
                                           badgeTintColor: AppTheme.current.backgroundTintColor)

let defaultTimePickerDesign = TimePickerDesign(tintColor: AppTheme.current.blueColor,
                                               secondaryTintColor: AppTheme.current.secondaryTintColor,
                                               thirdlyTintColor: AppTheme.current.middlegroundColor,
                                               timeFont: .systemFont(ofSize: 34, weight: .medium),
                                               hintsFont: .systemFont(ofSize: 13, weight: .medium))
