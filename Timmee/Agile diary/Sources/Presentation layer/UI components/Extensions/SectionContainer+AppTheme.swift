//
//  SectionContainer+AppTheme.swift
//  Agile diary
//
//  Created by Илья Харабет on 31/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIComponents

extension SectionContainer {
    
    func setupAppearance() {
        contentContainer.backgroundColor = AppTheme.current.colors.foregroundColor
        
        titleLabel.font = AppTheme.current.fonts.bold(24)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        
        disclaimerLabel.font = AppTheme.current.fonts.regular(13)
        disclaimerLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
}
