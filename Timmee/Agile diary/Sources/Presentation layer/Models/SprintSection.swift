//
//  SprintSection.swift
//  Agile diary
//
//  Created by i.kharabet on 14.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

enum SprintSection: Int {
    case habits = 0
    case targets
    case water
    
    var title: String {
        switch self {
        case .targets: return "Цели" // TODO: Localize
        case .habits: return "Привычки"
        case .water: return "Вода"
        }
    }
    
    var itemsKind: SprintItemKind {
        switch self {
        case .targets: return .target
        case .habits: return .habit
        case .water: return .water
        }
    }
}

enum SprintItemKind: String {
    case target
    case habit
    case water
    
    var id: String {
        switch self {
        case .target: return "target"
        case .habit: return "habit"
        case .water: return "water"
        }
    }
    
    var section: SprintSection {
        switch self {
        case .target: return .targets
        case .habit: return .habits
        case .water: return .water
        }
    }
}
