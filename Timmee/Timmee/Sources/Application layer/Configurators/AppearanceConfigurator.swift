//
//  AppearanceConfigurator.swift
//  Timmee
//
//  Created by i.kharabet on 12.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class AppearanceConfigurator {
    
    static func setupAppearance() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = AppTheme.current.panelColor
    }
    
}
