//
//  Habit.swift
//  TasksKit
//
//  Created by Илья Харабет on 15/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Workset
import struct Foundation.Data
import struct Foundation.Date
import class Foundation.NSOrderedSet
import class Foundation.NSKeyedUnarchiver
import class CoreLocation.CLLocation

public class Habit: Copyable {
    
    public var id: String
    public var title: String
    public var description: String
    public var value: Value?
    public var dueTime: Time?
    public var repeatEndingDate: Date?
    public var dueDays: [DayUnit]
    public var doneDates: [Date]
    public let creationDate: Date
    public var notification: Notification
    
    public init(habit: HabitEntity) {
        id = habit.id!
        title = habit.title ?? ""
        description = habit.link ?? ""
        value = habit.value.flatMap(Value.init(string:))
        dueTime = habit.dueTime.flatMap(Time.init(string:))
        repeatEndingDate = habit.repeatEndingDate as Date?
        dueDays = habit.dueDays?.split(separator: ",").map { DayUnit(string: String($0)) } ?? []
        doneDates = habit.doneDates as? [Date] ?? []
        creationDate = habit.creationDate! as Date
        
        let timeFromNotificationDate = (habit.notificationDate?.asTimeString).flatMap { Time(string: $0) }
        let notificationsTime = habit.notificationsTime?.split(separator: ",").compactMap({ Time(string: String($0)) }).first
            ?? timeFromNotificationDate
        
        notification = habit.notification.map(Notification.init(string:)) ?? notificationsTime.map { Notification.at($0) } ?? .none
    }
    
    public init(id: String,
                title: String,
                description: String,
                value: Value?,
                dueTime: Time?,
                notification: Notification,
                repeatEndingDate: Date?,
                dueDays: [DayUnit],
                doneDates: [Date],
                creationDate: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.value = value
        self.dueTime = dueTime
        self.repeatEndingDate = repeatEndingDate
        self.dueDays = dueDays
        self.doneDates = doneDates
        self.creationDate = creationDate
        self.notification = notification
    }
    
    public convenience init(id: String,
                            title: String) {
        self.init(id: id,
                  title: title,
                  description: "",
                  value: nil,
                  dueTime: nil,
                  notification: .none,
                  repeatEndingDate: nil,
                  dueDays: [],
                  doneDates: [],
                  creationDate: Date())
    }
    
    public convenience init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
              let title = json["title"] as? String,
              let dueDaysString = json["dueDays"] as? String
        else { return nil }
        
        let description = (json["link"] ?? json["description"]) as? String
        
        let dueTime = (json["dueTime"] as? String).flatMap(Time.init(string:))
        let value = (json["value"] as? String).flatMap(Value.init(string:))
        let dueDays = (dueDaysString.split(separator: ",").map { DayUnit(string: String($0)) })
        let notification = (json["notification"] as? String).flatMap(Notification.init(string:))
        
        self.init(id: id,
                  title: title,
                  description: description ?? "",
                  value: value,
                  dueTime: dueTime,
                  notification: notification ?? .none,
                  repeatEndingDate: nil,
                  dueDays: dueDays,
                  doneDates: [],
                  creationDate: Date())
    }
    
    public var copy: Habit {
        return Habit(id: id,
                     title: title,
                     description: description,
                     value: value,
                     dueTime: dueTime,
                     notification: notification,
                     repeatEndingDate: repeatEndingDate,
                     dueDays: dueDays,
                     doneDates: doneDates,
                     creationDate: creationDate)
    }
    
    public var notificationTime: Time? {
        switch notification {
        case .none: return nil
        case let .at(time):
            return time
        case let .before(minutes):
            guard let time = dueTime else { return nil }
            
            let notificationTime = time - minutes.rawValue.asMinutes
            
            return notificationTime
        }
    }
    
    public var nextNotificationDate: Date? {
        guard let notificationTime = notificationTime else { return nil }
        
        var notificationDate = Date()
        notificationDate => notificationTime.hours.asHours
        notificationDate => notificationTime.minutes.asMinutes
        
        return getNextRepeatDate(of: notificationDate)
    }
    
    private func getNextRepeatDate(of date: Date?) -> Date? {
        guard var date = date else { return nil }
        
        let now = Date()
        let dayNumbers = dueDays.map { $0.number }.sorted()

        while date <= now {
            let currentDayNumber = DayUnit(weekday: date.weekday).number
            let currentDayNumberIndex = dayNumbers.index(of: currentDayNumber) ?? 0
            let nextDayNumberIndex = currentDayNumberIndex + 1 >= dayNumbers.count ? 0 : currentDayNumberIndex + 1
            let nextDayNumber = dayNumbers.item(at: nextDayNumberIndex) ?? dayNumbers.item(at: 0) ?? 0
            let dayNumbersDifference = nextDayNumberIndex >= currentDayNumberIndex ? nextDayNumber - currentDayNumber : (7 + nextDayNumber) - currentDayNumber
            
            date = date + dayNumbersDifference.asDays as Date
        }
        
        if let repeatEndingDate = repeatEndingDate, date >= repeatEndingDate { return nil }
        
        return date
    }
    
    public func isDone(at date: Date) -> Bool {
        let date = date.startOfDay
        return doneDates.contains(where: { date.isWithinSameDay(of: $0) })
    }
    
    public func setDone(_ isDone: Bool, at date: Date) {
        let date = date.startOfDay
        isDone ? doneDates.append(date) : doneDates.remove(object: date)
    }

}

// MARK: - Value

extension Habit {
    
    public struct Value {
        public let amount: Int
        public let units: Unit
        
        public init(amount: Int, units: Unit) {
            self.amount = amount
            self.units = units
        }
    }
    
}

extension Habit.Value {
    
    public enum Unit: String, CaseIterable {
        case times, hours, minutes, kilograms, kilometers, liters
        
        public var localized: String {
            return "\(rawValue)".localized
        }
    }
    
    init?(string: String) {
        let valueComponents = string.split(separator: "|")
        guard !string.isEmpty, !valueComponents.isEmpty, valueComponents.count >= 2 else { return nil }
        guard let amount = Int(valueComponents[0]) else { return nil }
        guard let units = Unit(rawValue: String(valueComponents[1])) else { return nil }
        self.init(amount: amount, units: units)
    }
    
    var asString: String {
        return "\(amount)|\(units.rawValue)"
    }
    
    public var localized: String {
        return "\(amount) " + units.localized
    }
    
}

// MARK: - DayTime

extension Habit {
    
    public enum DayTime: String, CaseIterable {
        case morning, afternoon, evening, duringTheDay = "during_the_day"
        
        var sortID: String {
            switch self {
            case .morning: return "0"
            case .afternoon: return "1"
            case .evening: return "2"
            case .duringTheDay: return "3"
            }
        }
        
        public var localized: String {
            return "\(rawValue)".localized
        }
        
        /// Утром, днем, вечером
        public var localizedAt: String {
            return "\(rawValue)_at".localized
        }
        
        public init(hours: Int) {
            switch hours {
            case 4..<12: self = .morning
            case 12..<18: self = .afternoon
            default: self = .evening
            }
        }
        
        public init(sortID: String) {
            switch sortID {
            case "0": self = .morning
            case "1": self = .afternoon
            case "2": self = .evening
            default: self = .duringTheDay
            }
        }
    }
    
}

// MARK: - Notification

public extension Habit {
    
    enum Notification {
        
        public enum Before: Int {
            case zero = 0
            case ten = 10
            case thirty = 30
            case hour = 60
            
            var localized: String {
                switch self {
                case .zero: return "remind_just_in_time".localized
                case .ten: return "remind_10_minutes_before".localized
                case .thirty: return "remind_30_minutes_before".localized
                case .hour: return "remind_1_hour_before".localized
                }
            }
        }
        
        case none
        case at(Time)
        case before(_ minutes: Before)
        
        public init(string: String) {
            let stringParts = string.split(separator: "_")
            guard let prefix = stringParts.first else { self = .none; return }
            
            switch prefix {
            case "at":
                guard let time = Time(string: String(stringParts[1])) else { self = .none; return }
                self = .at(time)
            case "before":
                guard let minutes = Int(stringParts[1]) else { self = .none; return }
                guard let before = Before(rawValue: minutes) else { self = .none; return }
                self = .before(before)
            default:
                self = .none
            }
        }
        
        var string: String {
            switch self {
            case .none: return "none"
            case let .at(time): return "at_\(time.string)"
            case let .before(minutes): return "before_\(minutes.rawValue)"
            }
        }
        
        public var readableString: String {
            switch self {
            case .none: return "no_reminder".localized
            case let .at(time): return time.string
            case let .before(minutes): return minutes.localized
            }
        }
        
    }
    
}

extension Habit.Notification: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none): return true
        case let (.at(lhsTime), .at(rhsTime)): return lhsTime == rhsTime
        case let (.before(lhsBefore), .before(rhsBefore)): return lhsBefore.rawValue == rhsBefore.rawValue
        default: return false
        }
    }
    
}

// MARK: - Equatable

extension Habit.Value: Equatable {
    
    public static func == (lhs: Habit.Value, rhs: Habit.Value) -> Bool {
        return lhs.amount == rhs.amount && lhs.units == rhs.units
    }
    
}

// MARK: - Hashable

extension Habit: Hashable {
    
    public static func ==(lhs: Habit, rhs: Habit) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.value == rhs.value &&
        lhs.dueTime == rhs.dueTime &&
        lhs.notification == rhs.notification &&
        lhs.repeatEndingDate == rhs.repeatEndingDate &&
        lhs.dueDays == rhs.dueDays &&
        lhs.doneDates == rhs.doneDates
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

// MARK: - Custom equatable

extension Habit: CustomEquatable {
    
    public func isEqual(to item: Habit) -> Bool {
        id == item.id
    }
    
}

// MARK: - Comparable

extension Habit: Comparable {
 
    public static func < (lhs: Habit, rhs: Habit) -> Bool {
        if lhs.dueTime != nil, rhs.dueTime == nil {
            return true
        } else if lhs.dueTime == nil, rhs.dueTime != nil {
            return false
        }
        
        guard let lhsTime = lhs.dueTime,
              let rhsTime = rhs.dueTime
        else { return lhs.creationDate.isLower(than: rhs.creationDate) }
        
        return lhsTime < rhsTime && lhs.creationDate.isLower(than: rhs.creationDate)
    }
    
}
