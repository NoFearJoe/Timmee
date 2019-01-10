//
//  SmartList.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset
import struct Foundation.Date
import class Foundation.NSPredicate
import class Foundation.NSCompoundPredicate

public enum SmartListType {
    
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
    
    public static let allValues: [SmartListType] = [all, today, tomorrow, week, inProgress, overdue, important]
    
    public static func isSmartListID(_ id: String) -> Bool {
        return SmartListType.allValues.contains(where: { $0.id == id })
    }
    
    public init(id: String) {
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
    
    public var id: String {
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
    
    public var sortPosition: Int {
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
    
    public var canDelete: Bool {
        return self != .all
    }
    
    public var fetchPredicate: NSPredicate? {
        let now = Date()
        switch self {
        case .all, .today, .tomorrow, .week: return nil
        case .inProgress:
            return NSPredicate(format: "inProgress == true && isDone == false")
        case .overdue:
            return NSPredicate(format: "kind == \(Task.Kind.single.rawValue) && dueDate < %@", now.nsDate)
        case .important:
            return NSPredicate(format: "isImportant == true")
        }
    }
    
    public var filter: ((Task) -> Bool)? {
        switch self {
        case .today: return { $0.shouldBeDoneToday }
        case .tomorrow: return { $0.shouldBeDoneTomorrow }
        case .week: return { $0.shouldBeDoneAtThisWeek }
        default: return nil
        }
    }
}

public final class SmartList: List {

    public let smartListType: SmartListType
    
    public convenience init(type: SmartListType) {
        let title: String
        let icon: ListIcon
        switch type {
        case .all:
            title = "all_tasks".localized
            icon = .allTasks
        case .today:
            title = "today".localized
            icon = .today
        case .tomorrow:
            title = "tomorrow".localized
            icon = .tomorrow
        case .week:
            title = "week".localized
            icon = .week
        case .inProgress:
            title = "in_progress".localized
            icon = .inProgress
        case .overdue:
            title = "overdue".localized
            icon = .overdue
        case .important:
            title = "important".localized
            icon = .important
        }
        
        self.init(id: type.id,
                  title: title,
                  icon: icon,
                  creationDate: Date(),
                  smartListType: type)
    }
    
    private init(id: String,
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
    
    public override var tasksFetchPredicate: NSPredicate? {
        return smartListType.fetchPredicate
    }
    
    override public var defaultDueDate: Date? {
        switch smartListType {
        case .today: return (Date().startOfHour + 1.asHours)
        case .tomorrow: return (Date().nextDay.startOfHour + 1.asHours)
        case .week: return (Date().startOfHour + 6.asDays)
        default: return nil
        }
    }

}
