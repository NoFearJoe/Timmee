//
//  PlaceholderView+appearance.swift
//  Timmee
//
//  Created by i.kharabet on 09.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

extension PlaceholderView: Customizable {
    
    public func applyAppearance() {
        iconView.tintColor = AppTheme.current.secondaryTintColor
        titleLabel.textColor = AppTheme.current.tintColor
        subtitleLabel.textColor = AppTheme.current.secondaryTintColor
    }
    
}
