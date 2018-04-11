//
//  RepeatMask.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset
import class Foundation.NSCalendar

public enum RepeatType {
    case never
    case every(RepeatUnit)
    case on(WeekRepeatUnit)
    
    public init(string: String, repeatUnit: String) {
        switch string.lowercased() {
        case "every": self = .every(RepeatUnit(string: repeatUnit))
        case "on": self = .on(WeekRepeatUnit(string: repeatUnit))
        default: self = .never
        }
    }
    
    public var string: String {
        switch self {
        case .never: return "no_repeat".localized
        case .every: return "every".localized
        case .on: return "on".localized
        }
    }
    
    public var localized: String {
        switch self {
        case .never: return "no_repeat".localized
        case .every(let unit):
            switch unit {
            case .day: return "everyday".localized
            case .week: return "weekly".localized
            case .month: return "monthly".localized
            case .year: return "every_year".localized
            }
        case .on(let unit): return "on".localized + " " + unit.localized
        }
    }
    
    public var isNever: Bool {
        if case .never = self {
            return true
        }
        return false
    }
}

extension RepeatType: Hashable {
    public static func ==(lhs: RepeatType, rhs: RepeatType) -> Bool {
        switch (lhs, rhs) {
        case (.never, .never): return true
        case (.every(let unit1), .every(let unit2)): return unit1.hashValue == unit2.hashValue
        case (.on(let unit1), .on(let unit2)): return unit1.string == unit2.string
        default: return false
        }
    }
    
    public var hashValue: Int {
        switch self {
        case .never: return string.hashValue
        case .every(let unit): return string.hashValue + unit.hashValue
        case .on(let unit): return string.hashValue + unit.string.hashValue
        }
    }
}

public enum RepeatUnit: String {
    case day
    case week
    case month
    case year
    
    public init(string: String) {
        switch string.lowercased() {
        case "week": self = .week
        case "month": self = .month
        case "year": self = .year
        default: self = .day
        }
    }
    
    public var string: String {
        switch self {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        }
    }
    
    public var localized: String {
        switch self {
        case .day: return "day".localized
        case .week: return "week".localized
        case .month: return "month".localized
        case .year: return "year".localized
        }
    }
    
    public func localized(with number: Int) -> String {
        switch self {
        case .day: return "n_days".localized(with: number)
        case .week: return "n_weeks".localized(with: number)
        case .month: return "n_months".localized(with: number)
        case .year: return "n_years".localized(with: number)
        }
    }
    
    public var calendarUnit: NSCalendar.Unit {
        switch self {
        case .day: return .day
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        }
    }
}

public enum WeekRepeatUnit {
    case weekdays
    case weekends
    case custom(Set<DayUnit>)
    
    public init(string: String) {
        switch string {
        case "weekdays": self = .weekdays
        case "weekends": self = .weekends
        case let s:
            let dayUnits = Set(s.components(separatedBy: ",").map({ DayUnit(string: $0) }))
            self = .custom(dayUnits)
        }
    }
    
    public var string: String {
        switch self {
        case .weekdays: return "weekdays"
        case .weekends: return "weekends"
        case .custom(let dayUnits):
            return dayUnits.map({ $0.string }).joined(separator: ",")
        }
    }
    
    public var localized: String {
        switch self {
        case .weekdays: return "weekdays".localized
        case .weekends: return "weekends".localized
        case .custom(let dayUnits):
            func localizedDay(dayUnit: DayUnit) -> String {
                // Проблема с "Повтор в суббота"
//                if dayUnits.count == 1 {
//                    return dayUnit.localized
//                } else {
                    return dayUnit.localizedShort
//                }
            }
            
            if isEveryday {
                return "everyday".localized
            } else if containsWeekdays {
                let otherDaysString = Array(dayUnits.sorted(by: { $0.number < $1.number }).dropFirst(5)).map(localizedDay).joined(separator: ", ")
                return "weekdays".localized + " \("and".localized) " + otherDaysString
            } else if containsWeekends {
                let otherDaysString = Array(dayUnits.sorted(by: { $0.number < $1.number }).dropLast(2)).map(localizedDay).joined(separator: ", ")
                return otherDaysString + " \("and".localized) " + "weekends".localized
            }
            return dayUnits.sorted(by: { $0.number < $1.number }).map(localizedDay).joined(separator: ", ")
        }
    }
    
    public var isEveryday: Bool {
        if case .custom(let days) = self { return days.count == 7 }
        return false
    }
    
    public var containsWeekdays: Bool {
        if case .custom(let dayUnits) = self { return Set(dayUnits.map { $0.number }).isSuperset(of: [0, 1, 2, 3, 4]) }
        return false
    }
    
    public var containsWeekends: Bool {
        if case .custom(let dayUnits) = self { return Set(dayUnits.map { $0.number }).isSuperset(of: [5, 6]) }
        return false
    }
    
    public var dayNumbers: [Int] {
        switch self {
        case .weekdays: return (0...4).map { $0 }
        case .weekends: return (5...6).map { $0 }
        case .custom(let dayUnits):
            return dayUnits.map { $0.number }
        }
    }
}

public enum DayUnit: String {
    case monthday
    case tuesday
    case wednesday
    case thusday
    case friday
    case saturday
    case sunday
    
    public init(string: String) {
        switch string.lowercased() {
        case "tue": self = .tuesday
        case "wed": self = .wednesday
        case "thu": self = .thusday
        case "fri": self = .friday
        case "sat": self = .saturday
        case "sun": self = .sunday
        default: self = .monthday
        }
    }
    
    public init(number: Int) {
        switch number {
        case 1: self = .tuesday
        case 2: self = .wednesday
        case 3: self = .thusday
        case 4: self = .friday
        case 5: self = .saturday
        case 6: self = .sunday
        default: self = .monthday
        }
    }
    
    public var string: String {
        switch self {
        case .monthday: return "mon"
        case .tuesday: return "tue"
        case .wednesday: return "wed"
        case .thusday: return "thu"
        case .friday: return "fri"
        case .saturday: return "sat"
        case .sunday: return "sun"
        }
    }
    
    public var number: Int {
        switch self {
        case .monthday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thusday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }
    
    public var localized: String {
        switch self {
        case .monthday: return "monday".localized
        case .tuesday: return "tuesday".localized
        case .wednesday: return "wednesday".localized
        case .thusday: return "thursday".localized
        case .friday: return "friday".localized
        case .saturday: return "saturday".localized
        case .sunday: return "sunday".localized
        }
    }
    
    public var localizedShort: String {
        switch self {
        case .monthday: return "mon".localized
        case .tuesday: return "tue".localized
        case .wednesday: return "wed".localized
        case .thusday: return "thu".localized
        case .friday: return "fri".localized
        case .saturday: return "sat".localized
        case .sunday: return "sun".localized
        }
    }
}

public struct RepeatMask {
    public let type: RepeatType
    public let value: Int
    
    public init(string: String) {
        let components = string.components(separatedBy: "|")
        
        switch components.count {
        case 2:
            type = RepeatType(string: components[0], repeatUnit: components[1])
            value = 1
        case 3:
            type = RepeatType(string: components[0], repeatUnit: components[2])
            value = Int(components[1]) ?? 1
        default:
            type = .never
            value = 0
        }
    }
    
    public init(type: RepeatType, value: Int = 1) {
        self.type = type
        self.value = value
    }
    
    public var string: String {
        switch type {
        case .never: return type.string
        case .every(let unit): return type.string + "|" + String(value) + "|" + unit.string
        case .on(let unit): return type.string + "|" + unit.string
        }
    }
    
    public var localized: String {
        switch type {
        case .never: return type.localized
        case .every(let unit):
            if value == 1 {
                switch unit {
                case .day: return "everyday".localized
                case .week: return "weekly".localized
                case .month: return "monthly".localized
                case .year: return "every_year".localized
                }
            } else {
                return "every_n_units".localized(with: value)
                    + " \(value) "
                    + unit.localized(with: value)
            }
        case .on(let unit):
            return unit.localized
        }
    }
}
