//
//  DatesKit.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Foundation

// MARK: - Date components

public extension Date {
    
    public var year: Int {
        return Foundation.Calendar.current.component(.year, from: self)
    }
    
    public var month: Int {
        return Foundation.Calendar.current.component(.month, from: self)
    }
    
    public var weekOfYear: Int {
        return Foundation.Calendar.current.component(.weekOfYear, from: self)
    }
    
    public var weekday: Int {
        return Foundation.Calendar.current.ordinality(of: .weekday, in: .weekOfYear, for: self) ?? 1
    }
    
    public var dayOfMonth: Int {
        return Foundation.Calendar.current.component(.day, from: self)
    }
    
    public var hours: Int {
        return Foundation.Calendar.current.component(.hour, from: self)
    }
    
    public var minutes: Int {
        return Foundation.Calendar.current.component(.minute, from: self)
    }
    
}

// MARK: - Date operators

infix operator =>

public extension Date {
    
    public static func +(date: Date, dateUnit: Years) -> Date {
        return date.setupComponents { $0.year = dateUnit.value }
    }
    
    public static func -(date: Date, dateUnit: Years) -> Date {
        return date.setupComponents { $0.year = -dateUnit.value }
    }
    
    public static func +(date: Date, dateUnit: Months) -> Date {
        return date.setupComponents { $0.month = dateUnit.value }
    }
    
    public static func -(date: Date, dateUnit: Months) -> Date {
        return date.setupComponents { $0.month = -dateUnit.value }
    }
    
    public static func +(date: Date, dateUnit: Weeks) -> Date {
        return date.setupComponents { $0.weekOfYear = dateUnit.value }
    }
    
    public static func -(date: Date, dateUnit: Weeks) -> Date {
        return date.setupComponents { $0.weekOfYear = -dateUnit.value }
    }
    
    public static func +(date: Date, dateUnit: Days) -> Date {
        return date.setupComponents { $0.day = dateUnit.value }
    }
    
    public static func -(date: Date, dateUnit: Days) -> Date {
        return date.setupComponents { $0.day = -dateUnit.value }
    }
    
    public static func +(date: Date, dateUnit: Hours) -> Date {
        return date.setupComponents { $0.hour = dateUnit.value }
    }
    
    public static func -(date: Date, dateUnit: Hours) -> Date {
        return date.setupComponents { $0.hour = -dateUnit.value }
    }
    
    public static func +(date: Date, dateUnit: Minutes) -> Date {
        return date.setupComponents { $0.minute = dateUnit.value }
    }
    
    public static func -(date: Date, dateUnit: Minutes) -> Date {
        return date.setupComponents { $0.minute = -dateUnit.value }
    }
    
    
    public static func =>(date: inout Date, dateUnit: Years) {
        date = date.changeComponents { $0.year = dateUnit.value }
    }
    
    public static func =>(date: inout Date, dateUnit: Months) {
        date = date.changeComponents { $0.month = dateUnit.value }
    }
    
    public static func =>(date: inout Date, dateUnit: Weeks) {
        date = date.changeComponents { $0.weekOfYear = dateUnit.value }
    }
    
    public static func =>(date: inout Date, dateUnit: Hours) {
        date = date.changeComponents { $0.hour = dateUnit.value }
    }
    
    public static func =>(date: inout Date, dateUnit: Minutes) {
        date = date.changeComponents { $0.minute = dateUnit.value }
    }
    
    
    func setupComponents(_ componentsConfiguration: (inout DateComponents) -> Void) -> Date {
        var components = Date.emptyComponents
        
        componentsConfiguration(&components)
        
        return Foundation.Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    private static var emptyComponents: DateComponents {
        return DateComponents(calendar: Foundation.Calendar.current, timeZone: TimeZone.current, era: 0, year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, nanosecond: 0, weekday: 0, weekdayOrdinal: 0, quarter: 0, weekOfMonth: 0, weekOfYear: 0, yearForWeekOfYear: 0)
    }
    
}

public extension Optional where Wrapped == Date {
    
    public static func +(date: Date?, dateUnit: Years) -> Date? {
        return date?.setupComponents { $0.year = dateUnit.value }
    }
    
    public static func -(date: Date?, dateUnit: Years) -> Date? {
        return date?.setupComponents { $0.year = -dateUnit.value }
    }
    
    public static func +(date: Date?, dateUnit: Months) -> Date? {
        return date?.setupComponents { $0.month = dateUnit.value }
    }
    
    public static func -(date: Date?, dateUnit: Months) -> Date? {
        return date?.setupComponents { $0.month = -dateUnit.value }
    }
    
    public static func +(date: Date?, dateUnit: Weeks) -> Date? {
        return date?.setupComponents { $0.weekOfYear = dateUnit.value }
    }
    
    public static func -(date: Date?, dateUnit: Weeks) -> Date? {
        return date?.setupComponents { $0.weekOfYear = -dateUnit.value }
    }
    
    public static func +(date: Date?, dateUnit: Days) -> Date? {
        return date?.setupComponents { $0.day = dateUnit.value }
    }
    
    public static func -(date: Date?, dateUnit: Days) -> Date? {
        return date?.setupComponents { $0.day = -dateUnit.value }
    }
    
    public static func +(date: Date?, dateUnit: Hours) -> Date? {
        return date?.setupComponents { $0.hour = dateUnit.value }
    }
    
    public static func -(date: Date?, dateUnit: Hours) -> Date? {
        return date?.setupComponents { $0.hour = -dateUnit.value }
    }
    
    public static func +(date: Date?, dateUnit: Minutes) -> Date? {
        return date?.setupComponents { $0.minute = dateUnit.value }
    }
    
    public static func -(date: Date?, dateUnit: Minutes) -> Date? {
        return date?.setupComponents { $0.minute = -dateUnit.value }
    }
    
    public static func =>(date: inout Date?, dateUnit: Years) {
        date = date?.changeComponents { $0.year = dateUnit.value }
    }
    
    public static func =>(date: inout Date?, dateUnit: Months) {
        date = date?.changeComponents { $0.month = dateUnit.value }
    }
    
    public static func =>(date: inout Date?, dateUnit: Weeks) {
        date = date?.changeComponents { $0.weekOfYear = dateUnit.value }
    }
    
    public static func =>(date: inout Date?, dateUnit: Hours) {
        date = date?.changeComponents { $0.hour = dateUnit.value }
    }
    
    public static func =>(date: inout Date?, dateUnit: Minutes) {
        date = date?.changeComponents { $0.minute = dateUnit.value }
    }
    
}

// MARK: - Date shortcuts

public extension Date {
    
    public var startOfDay: Date {
        return changeComponents { components in
            components.hour = 0
            components.minute = 0
            components.second = 0
            components.nanosecond = 0
        }
    }
    
    public var endOfDay: Date {
        return changeComponents { components in
            components.hour = 23
            components.minute = 59
            components.second = 59
            components.nanosecond = 9
        }
    }
    
    public var nextDay: Date {
        return changeComponents { components in
            if components.day != nil {
                components.day! += 1
            }
        }
    }
    
    public var previousDay: Date {
        return changeComponents { components in
            if components.day != nil {
                components.day! -= 1
            }
        }
    }
    
    
    public var startOfHour: Date {
        return changeComponents { components in
            components.minute = 0
            components.second = 0
            components.nanosecond = 0
        }
    }
    
    
    public var startOfMinute: Date {
        return changeComponents { components in
            components.second = 0
            components.nanosecond = 0
        }
    }
    
    public var startOfMonth: Date {
        return changeComponents { components in
            components.day = 0
        }
    }
    
    public var endOfMonth: Date {
        return changeComponents { components in
            components.day = daysInMonth
        }
    }
    
    public var daysInMonth: Int {
        return Foundation.Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 0
    }
    
    
    fileprivate func changeComponents(_ componentsConfiguration: (inout DateComponents) -> Void) -> Date {
        var components = Foundation.Calendar.current.dateComponents(in: TimeZone.current, from: self)
        
        componentsConfiguration(&components)
        
        return Foundation.Calendar.current.date(from: components) ?? self
    }
    
}

// MARK: - Dates comparision

public extension Date {
    
    public static func ==(lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == .orderedSame
    }
    
    public static func >=(lhs: Date, rhs: Date) -> Bool {
        switch lhs.compare(rhs) {
        case .orderedSame, .orderedDescending: return true
        case .orderedAscending: return false
        }
    }
    
    public static func <=(lhs: Date, rhs: Date) -> Bool {
        switch lhs.compare(rhs) {
        case .orderedSame, .orderedAscending: return true
        case .orderedDescending: return false
        }
    }
    
    public static func >(lhs: Date, rhs: Date) -> Bool {
        switch lhs.compare(rhs) {
        case .orderedDescending: return true
        default: return false
        }
    }
    
    public static func <(lhs: Date, rhs: Date) -> Bool {
        switch lhs.compare(rhs) {
        case .orderedAscending: return true
        default: return false
        }
    }
    
    
    public func isWithinSameDay(of date: Date) -> Bool {
        return self.year == date.year && self.month == date.month && self.dayOfMonth == date.dayOfMonth
    }
    
    public func isWithinSameHour(of date: Date) -> Bool {
        return self.isWithinSameDay(of: date) && self.hours == date.hours
    }
    
}

// MARK: - Date intervals

public extension Date {
    
    public func minutes(before date: Date) -> Int {
        return Foundation.Calendar.current.dateComponents([.minute], from: self, to: date).minute ?? 0
    }
    
    public func hours(before date: Date) -> Int {
        return Foundation.Calendar.current.dateComponents([.hour], from: self, to: date).hour ?? 0
    }
    
    public func days(before date: Date) -> Int {
        return Foundation.Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }
    
    public func weeks(before date: Date) -> Int {
        return Foundation.Calendar.current.dateComponents([.weekOfMonth], from: self, to: date).weekOfMonth ?? 0
    }
    
    public func months(before date: Date) -> Int {
        return Foundation.Calendar.current.dateComponents([.month], from: self, to: date).month ?? 0
    }
    
    public func years(before date: Date) -> Int {
        return Foundation.Calendar.current.dateComponents([.year], from: self, to: date).year ?? 0
    }
    
}

// MARK: - Date strings

public extension Date {
    
    public func asString(format: String, localized: Bool = false) -> String {
        let formatter = DateFormatter()
        if localized {
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: Locale.current)
        } else {
            formatter.dateFormat = format
        }
        
        return formatter.string(from: self)
    }
    
}

// MARK: - Date units

public class DateUnit<ValueType> {
    let value: ValueType
    
    init(value: ValueType) {
        self.value = value
    }
}

public final class Years: DateUnit<Int> {}
public final class Months: DateUnit<Int> {}
public final class Weeks: DateUnit<Int> {}
public final class Days: DateUnit<Int> {}
public final class Hours: DateUnit<Int> {}
public final class Minutes: DateUnit<Int> {}
public final class Seconds: DateUnit<Int> {}

public extension Int {
    
    public var asYears: Years {
        return Years(value: self)
    }
    
    public var asMonths: Months {
        return Months(value: self)
    }
    
    public var asWeeks: Weeks {
        return Weeks(value: self)
    }
    
    public var asDays: Days {
        return Days(value: self)
    }
    
    public var asHours: Hours {
        return Hours(value: self)
    }
    
    public var asMinutes: Minutes {
        return Minutes(value: self)
    }
    
    public var asSeconds: Seconds {
        return Seconds(value: self)
    }
    
}
