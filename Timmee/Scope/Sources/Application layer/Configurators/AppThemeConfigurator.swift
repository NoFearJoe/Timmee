//
//  AppThemeConfigurator.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class AppThemeConfigurator {

    static func setupInitialThemeIfNeeded() {
        if UserProperty.appTheme.value() == nil {
            UserProperty.appTheme.setInt(AppTheme.white.code)
        }
    }

}
