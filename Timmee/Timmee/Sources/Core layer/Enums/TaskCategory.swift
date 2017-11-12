//
//  TaskCategory.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIImage

enum TaskCategory: Int16 {
    case importantAndUrgent = 0
    case important = 1
    case urgent = 2
    case other = 3
    
    static let all: [TaskCategory] = [.importantAndUrgent, .important, .urgent, .other]
    
    init(categoryCode: Int) {
        switch categoryCode {
        case 0: self = .importantAndUrgent
        case 1: self = .important
        case 2: self = .urgent
        default: self = .other
        }
    }
}

extension TaskCategory {

    var title: String {
        switch self {
        case .importantAndUrgent: return "Важно и срочно"
        case .important: return "Важно"
        case .urgent: return "Срочно"
        case .other: return "Остальное"
        }
    }
    
    var icon: UIImage {
        switch self {
        case .importantAndUrgent: return UIImage(named: "important_and_urgent")!
        case .important: return UIImage(named: "important")!
        case .urgent: return UIImage(named: "urgent")!
        case .other: return UIImage(named: "other")!
        }
    }

}
