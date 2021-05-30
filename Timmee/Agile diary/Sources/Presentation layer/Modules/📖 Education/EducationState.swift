//
//  EducationState.swift
//  Agile diary
//
//  Created by i.kharabet on 17.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

enum EducationScreen {
    // Стартовый экран
    case initial
    
    // Экран с объяснением, что спринты нельзя изменять
    case immutableSprints
    
    // Экран с предложением включить уведомления
    case notificationsSetupSuggestion
    
    // Экран с предложением включить защиту паролем
    case pinCodeSetupSuggestion
    
    // Экран создания пин кода
    case pinCodeCreation
    
    // Экран информации о подписке
    case subscriptionPromo
    
    // Последний экран обучения
    case final
}

final class EducationState {
    
    private var isEducationShown: Bool {
        return UserProperty.isEducationShown.bool()
    }
    
    lazy var screensToShow: [EducationScreen] = {
        if !isEducationShown {
            return [.initial, .immutableSprints,
                    .notificationsSetupSuggestion, .pinCodeSetupSuggestion, .pinCodeCreation,
                    .subscriptionPromo, .final]
        }
        return []
    }()
    
}
