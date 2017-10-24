//
//  SmartList.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSDate
import class Foundation.NSPredicate
import class Foundation.NSCompoundPredicate
import MTDates

enum SmartListType {
    case all
    case today
    case tomorrow
    case week
    
    static let allValues: [SmartListType] = [.all, .today, .tomorrow, .week]
    
    static func isSmartListID(_ id: String) -> Bool {
        return SmartListType.allValues.first(where: { $0.id == id }) != nil
    }
    
    init(id: String) {
        switch id {
        case SmartListType.today.id: self = .today
        case SmartListType.tomorrow.id: self = .tomorrow
        case SmartListType.week.id: self = .week
        default: self = .all
        }
    }
    
    var id: String {
        switch self {
        case .all: return "Smart.All"
        case .today: return "Smart.Today"
        case .tomorrow: return "Smart.Tomorrow"
        case .week: return "Smart.Week"
        }
    }
    
    var fetchPredicate: NSPredicate? {
        let now = NSDate()
        switch self {
        case .all: return nil
        case .today: return NSPredicate(format: "dueDate >= %@ && dueDate <= %@",
                                        now.mt_startOfCurrentDay() as NSDate,
                                        now.mt_endOfCurrentDay() as NSDate)
        case .tomorrow: return NSPredicate(format: "dueDate >= %@ && dueDate <= %@",
                                           now.mt_startOfNextDay() as NSDate,
                                           now.mt_endOfNextDay() as NSDate)
        case .week: return NSPredicate(format: "dueDate >= %@ && dueDate <= %@",
                                       now.mt_startOfCurrentDay() as NSDate,
                                       (now.mt_oneWeekNext() as NSDate).mt_endOfCurrentDay() as NSDate)
        }
    }
}

final class SmartList: List {

    let smartListType: SmartListType
    
    convenience init(type: SmartListType) {
        switch type {
        case .all:
            self.init(id: type.id,
                      title: "all_tasks".localized,
                      icon: .default,
                      creationDate: Date(),
                      smartListType: .all)
        case .today:
            self.init(id: type.id,
                      title: "today".localized,
                      icon: .default,
                      creationDate: Date(),
                      smartListType: .today)
        case .tomorrow:
            self.init(id: type.id,
                      title: "tomorrow".localized,
                      icon: .default,
                      creationDate: Date(),
                      smartListType: .tomorrow)
        case .week:
            self.init(id: type.id,
                      title: "week".localized,
                      icon: .default,
                      creationDate: Date(),
                      smartListType: .week)
        }
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

extension List: Equatable {

    static func ==(lhs: List, rhs: List) -> Bool {
        return lhs.id == rhs.id
    }

}

extension List: Hashable {

    var hashValue: Int {
        return id.hashValue
    }

}
