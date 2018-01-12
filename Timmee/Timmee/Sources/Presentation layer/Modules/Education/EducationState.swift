//
//  EducationState.swift
//  Timmee
//
//  Created by i.kharabet on 12.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

enum EducationScreen {
    // Стартовый экран
    case initial
    
    // Экран с основными фичами
    case features
    
    // Экран с предложением включить защиту паролем
    case pinCodeSetupSuggestion
    
    // Экран создания пин кода
    case pinCodeCreation
}

final class EducationState {
    
    private static var isEducationShown: Bool {
        return UserProperty.isEducationShown.bool()
    }
    
    static var screensToShow: [EducationScreen] {
        if !isEducationShown {
            return [.initial, .features, .pinCodeSetupSuggestion, .pinCodeCreation]
        }
        return []
    }
    
}
