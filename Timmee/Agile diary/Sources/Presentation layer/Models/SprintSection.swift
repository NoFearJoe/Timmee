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
    case activity
    
    var title: String {
        switch self {
        case .goals: return "goals".localized
        case .habits: return "habits".localized
        case .activity: return "activity".localized
        }
    }
    
    var itemsKind: SprintItemKind {
        switch self {
        case .goals: return .goal
        case .habits: return .habit
        case .activity: return .activity
        }
    }
}

enum SprintItemKind: String {
    case goal
    case habit
    case activity
    
    var id: String {
        switch self {
        case .goal: return "goal"
        case .habit: return "habit"
        case .activity: return "activity"
        }
    }
    
    var section: SprintSection {
        switch self {
        case .goal: return .goals
        case .habit: return .habits
        case .activity: return .activity
        }
    }
}
