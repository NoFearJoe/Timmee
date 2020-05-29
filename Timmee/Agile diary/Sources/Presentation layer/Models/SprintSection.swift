//
//  SprintSection.swift
//  Agile diary
//
//  Created by i.kharabet on 14.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

enum SprintSection: Int {
    case habits = 0
    case goals
    
    var title: String {
        switch self {
        case .goals: return "goals".localized
        case .habits: return "habits".localized
        }
    }
    
    var itemsKind: SprintItemKind {
        switch self {
        case .goals: return .goal
        case .habits: return .habit
        }
    }
}

enum SprintItemKind: String {
    case goal
    case habit
    
    var id: String {
        switch self {
        case .goal: return "goal"
        case .habit: return "habit"
        }
    }
    
    var section: SprintSection {
        switch self {
        case .goal: return .goals
        case .habit: return .habits
        }
    }
}
