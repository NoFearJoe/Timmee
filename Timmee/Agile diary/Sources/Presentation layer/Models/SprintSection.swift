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
    
    var title: String {
        switch self {
        case .targets: return "Цели"
        case .habits: return "Привычки"
        }
    }
    
    var itemsKind: SprintItemKind {
        switch self {
        case .targets: return .target
        case .habits: return .habit
        }
    }
}

enum SprintItemKind: String {
    case target
    case habit
    
    var id: String {
        switch self {
        case .target: return "target"
        case .habit: return "habit"
        }
    }
    
    var section: SprintSection {
        switch self {
        case .target: return .targets
        case .habit: return .habits
        }
    }
}
