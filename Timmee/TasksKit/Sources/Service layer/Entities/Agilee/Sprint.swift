//
//  Sprint.swift
//  TasksKit
//
//  Created by Илья Харабет on 15/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSPredicate
import class UIKit.UIColor
import class UIKit.UIImage
import class CoreData.NSFetchRequest

public class Sprint {
    public var id: String
    public var number: Int
    public var startDate: Date
    public var endDate: Date
    public var duration: Int
    public var notifications: Notifications
    public var habitsCount: Int
    public var goalsCount: Int
    
    public var title: String {
        return "Sprint".localized + " #\(number)"
    }
    
    public init(sprintEntity: SprintEntity) {
        id = sprintEntity.id ?? ""
        number = Int(sprintEntity.number)
        startDate = sprintEntity.startDate! as Date
        endDate = sprintEntity.endDate! as Date
        duration = Int(sprintEntity.duration)
        notifications = Notifications(sprint: sprintEntity)
        habitsCount = sprintEntity.habits?.count ?? 0
        goalsCount = sprintEntity.goals?.count ?? 0
    }
    
    public init(id: String,
                number: Int,
                startDate: Date,
                endDate: Date,
                duration: Int,
                notifications: Notifications) {
        self.id = id
        self.number = number
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.notifications = notifications
        self.habitsCount = 0
        self.goalsCount = 0
    }
    
    public var copy: Sprint {
        return Sprint(id: id,
                      number: number,
                      startDate: startDate,
                      endDate: endDate,
                      duration: duration,
                      notifications: notifications)
    }

}

extension Sprint: Equatable {
    public static func ==(lhs: Sprint, rhs: Sprint) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Sprint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Sprint {
    public struct Notifications {
        public var isEnabled: Bool
        public var days: [DayUnit]?
        public var time: (Int, Int)?
        
        public init() {
            isEnabled = false
            days = nil
            time = nil
        }
        
        init(sprint: SprintEntity) {
            isEnabled = sprint.notificationsEnabled
            days = sprint.notificationsDays?.split(separator: ",").map { DayUnit(string: String($0)) }
            if let notificationTime = sprint.notificationsTime?.split(separator: ":"), notificationTime.count == 2,
               let hours = Int(notificationTime[0]), let minutes = Int(notificationTime[1]) {
                time = (hours, minutes)
            } else {
                time = nil
            }
        }
    }
}

extension Sprint {
    public enum Tense {
        case past
        case current
        case future
        
        public var localized: String {
            switch self {
            case .past: return "past_sprint".localized
            case .current: return "current_sprint".localized
            case .future: return "future_sprint".localized
            }
        }
    }
    
    public var tense: Tense {
        if Date().startOfDay < startDate {
            return .future
        } else if Date().startOfDay > endDate {
            return .past
        } else {
            return .current
        }
    }
}
