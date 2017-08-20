//
//  TaskCategory.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

enum TaskCategory: Int16 {
    case ImportantAndUrgent = 0
    case Important = 1
    case Urgent = 2
    case Other = 3
    
    init(categoryCode: Int) {
        switch categoryCode {
        case 0: self = .ImportantAndUrgent
        case 1: self = .Important
        case 2: self = .Urgent
        default: self = .Other
        }
    }
}

extension TaskCategory {

    var title: String {
        switch self {
        case .ImportantAndUrgent: return "Важно и срочно"
        case .Important: return "Важно"
        case .Urgent: return "Срочно"
        case .Other: return "Остальное"
        }
    }

}
