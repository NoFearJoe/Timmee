//
//  AppThemeApplier.swift
//  Agile diary
//
//  Created by Илья Харабет on 29/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIComponents

final class AppThemeApplier {
    
    static func applyTheme() {
        ScreenPlaceholderView.titleFont = AppTheme.current.fonts.bold(18)
        ScreenPlaceholderView.titleColor = AppTheme.current.colors.activeElementColor
        ScreenPlaceholderView.messageFont = AppTheme.current.fonts.regular(14)
        ScreenPlaceholderView.messageColor = AppTheme.current.colors.inactiveElementColor
        ScreenPlaceholderView.buttonFont = AppTheme.current.fonts.medium(16)
        ScreenPlaceholderView.buttonTextColor = AppTheme.current.colors.mainElementColor
    }
    
}
