//
//  SmartList.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSPredicate
import class Foundation.NSCompoundPredicate

enum SmartListType {
    
    // Все задачи
    case all
    
    // Сегодня
    case today
    
    // Завтра
    case tomorrow
    
    // На этой неделе
    case week
    
    // В процессе
    case inProgress
    
    // Просроченные задачи
    case overdue
    
    // Важные задачи
    case important
    
    // Звонки
    // TODO
//    case calls
    
    //Последние измененные
    // TODO добавить поле modifyDate в TaskEntity
//    case lastModified
    
    static let allValues: [SmartListType] = [all, today, tomorrow, week, inProgress, overdue, important]
    
    static func isSmartListID(_ id: String) -> Bool {
        return SmartListType.allValues.contains(where: { $0.id == id })
    }
    
    init(id: String) {
        switch id {
        case SmartListType.today.id: self = .today
        case SmartListType.tomorrow.id: self = .tomorrow
        case SmartListType.week.id: self = .week
        case SmartListType.inProgress.id: self = .inProgress
        case SmartListType.overdue.id: self = .overdue
        case SmartListType.important.id: self = .important
        default: self = .all
        }
    }
    
    var id: String {
        switch self {
        case .all: return "Smart.All"
        case .today: return "Smart.Today"
        case .tomorrow: return "Smart.Tomorrow"
        case .week: return "Smart.Week"
        case .inProgress: return "Smart.InProgress"
        case .overdue: return "Smart.Overdue"
        case .important: return "Smart.Important"
        }
    }
    
    var sortPosition: Int {
        switch self {
        case .all: return 0
        case .today: return 1
        case .tomorrow: return 2
        case .week: return 3
        case .inProgress: return 4
        case .overdue: return 5
        case .important: return 6
        }
    }
    
    var canDelete: Bool {
        return self != .all
    }
    
    var fetchPredicate: NSPredicate? {
        let now = Date()
        switch self {
        case .all: return nil
        case .today:
            return NSPredicate(format: "dueDate >= %@ && dueDate <= %@",
                               now.startOfDay.nsDate,
                               now.endOfDay.nsDate)
        case .tomorrow:
            return NSPredicate(format: "dueDate >= %@ && dueDate <= %@",
                               (now.startOfDay + 1.asDays).nsDate,
                               (now.endOfDay + 1.asDays).nsDate)
        case .week:
            return NSPredicate(format: "dueDate >= %@ && dueDate <= %@",
                               now.startOfDay.nsDate,
                               (now.endOfDay + 1.asWeeks).nsDate)
        case .inProgress:
            return NSPredicate(format: "inProgress == true && isDone == false")
        case .overdue:
            return NSPredicate(format: "dueDate < %@", now.nsDate)
        case .important:
            return NSPredicate(format: "isImportant == true")
        }
    }
}

final class SmartList: List {

    let smartListType: SmartListType
    
    convenience init(type: SmartListType) {
        let title: String
        let icon: ListIcon
        switch type {
        case .all:
            title = "all_tasks".localized
            icon = .default
        case .today:
            title = "today".localized
            icon = .default
        case .tomorrow:
            title = "tomorrow".localized
            icon = .default
        case .week:
            title = "week".localized
            icon = .default
        case .inProgress:
            title = "in_progress".localized
            icon = .mail
        case .overdue:
            title = "overdue".localized
            icon = .lock
        case .important:
            title = "important".localized
            icon = .lock
        }
        
        self.init(id: type.id,
                  title: title,
                  icon: icon,
                  creationDate: Date(),
                  smartListType: type)
    }
    
    fileprivate init(id: String,
                     title: String,
                     icon: ListIcon,
                     creationDate: Date,
                     smartListType: SmartListType) {
        self.smartListType = smartListType
        super.init(id: id,
                   title: title,
                   icon: icon,
                   creationDate: creationDate)
    }
    
    override var tasksFetchPredicate: NSPredicate? {
        return smartListType.fetchPredicate
    }

}
