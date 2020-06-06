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
    public var note: String
    public var link: String
    public var value: Value?
    public var dayTime: DayTime?
    public var repeatEndingDate: Date?
    public var dueDays: [DayUnit]
    public var doneDates: [Date]
    public let creationDate: Date
    
    public var notificationsTime: [Time] {
        get {
            _notificationsTime
        }
        set {
            _notificationsTime = newValue.unique.sorted()
        }
    }
    private var _notificationsTime: [Time] = []
    
    public init(habit: HabitEntity) {
        id = habit.id!
        title = habit.title ?? ""
        note = habit.note ?? ""
        link = habit.link ?? ""
        value = habit.value.flatMap(Value.init(string:))
        dayTime = habit.dayTime.flatMap(DayTime.init(rawValue:))
        repeatEndingDate = habit.repeatEndingDate as Date?
        dueDays = habit.dueDays?.split(separator: ",").map { DayUnit(string: String($0)) } ?? []
        doneDates = habit.doneDates as? [Date] ?? []
        creationDate = habit.creationDate! as Date
        
        let timeFromNotificationDate = (habit.notificationDate?.asTimeString).flatMap { Time(string: $0) }
        notificationsTime = habit.notificationsTime?.split(separator: ",").compactMap { Time(string: String($0)) }
            ?? timeFromNotificationDate.map { [$0] }
            ?? []
    }
    
    public init(id: String,
                title: String,
                note: String,
                link: String,
                value: Value?,
                dayTime: DayTime?,
                notificationsTime: [Time],
                repeatEndingDate: Date?,
                dueDays: [DayUnit],
                doneDates: [Date],
                creationDate: Date) {
        self.id = id
        self.title = title
        self.note = note
        self.link = link
        self.value = value
        self.dayTime = dayTime
        self.repeatEndingDate = repeatEndingDate
        self.dueDays = dueDays
        self.doneDates = doneDates
        self.creationDate = creationDate
        self.notificationsTime = notificationsTime
    }
    
    public convenience init(id: String,
                            title: String) {
        self.init(id: id,
                  title: title,
                  note: "",
                  link: "",
                  value: nil,
                  dayTime: .duringTheDay,
                  notificationsTime: [],
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
        
        let note = json["note"] as? String
        let link = json["link"] as? String
        
        let dayTime = (json["dayTime"] as? String).flatMap(DayTime.init(rawValue:))
        let value = (json["value"] as? String).flatMap(Value.init(string:))
        let dueDays = (dueDaysString.split(separator: ",").map { DayUnit(string: String($0)) })
        
        self.init(id: id,
                  title: title,
                  note: note ?? "",
                  link: link ?? "",
                  value: value,
                  dayTime: dayTime,
                  notificationsTime: [],
                  repeatEndingDate: nil,
                  dueDays: dueDays,
                  doneDates: [],
                  creationDate: Date())
    }
    
    public var copy: Habit {
        return Habit(id: id,
                     title: title,
                     note: note,
                     link: link,
                     value: value,
                     dayTime: dayTime,
                     notificationsTime: notificationsTime,
                     repeatEndingDate: repeatEndingDate,
                     dueDays: dueDays,
                     doneDates: doneDates,
                     creationDate: creationDate)
    }
    
    public var nextNotificationDate: Date? {
        let now = Time(Date().hours, Date().minutes)
        let closestTime = notificationsTime
            .filter { $0 > now }
            .min { $0 < $1 }
        
        var notificationDate = Date()
        notificationDate => (closestTime?.hours ?? 0).asHours
        notificationDate => (closestTime?.minutes ?? 0).asMinutes
        
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
    
    /// Возвращает время суток если свойство dayTime не nil или возвращает время суток на основе notificationDate.hours
    public var calculatedDayTime: DayTime {
        if let dayTime = dayTime {
            return dayTime
        } else {
            return .duringTheDay
        }
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
        lhs.note == rhs.note &&
        lhs.link == rhs.link &&
        lhs.value == rhs.value &&
        lhs.dayTime == rhs.dayTime &&
        lhs.notificationsTime == rhs.notificationsTime &&
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
