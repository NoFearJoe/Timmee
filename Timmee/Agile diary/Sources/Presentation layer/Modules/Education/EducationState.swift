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
    
    // Экран с ответом на вопрос - что такое цели
    case goals
    
    // Экран с ответом на вопрос - что такое привычки
    case habits
    
    // Экран с предложением включить уведомления
    case notificationsSetupSuggestion
    
    // Экран с предложением включить защиту паролем
    case pinCodeSetupSuggestion
    
    // Экран создания пин кода
    case pinCodeCreation
    
    // Последний экран обучения
    case final
}

final class EducationState {
    
    private var isEducationShown: Bool {
        return UserProperty.isEducationShown.bool()
    }
    
    lazy var screensToShow: [EducationScreen] = {
        if !isEducationShown {
            return [.initial, .goals, .habits, .notificationsSetupSuggestion, .pinCodeSetupSuggestion, .pinCodeCreation, .final]
        }
        return []
    }()
    
}
