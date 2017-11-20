//
//  DatesKit.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Foundation

// MARK: - Date components

extension Date {
    
    var year: Int {
        return Foundation.Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Foundation.Calendar.current.component(.month, from: self)
    }
    
    var weekday: Int {
        return Foundation.Calendar.current.ordinality(of: .weekday, in: .weekOfYear, for: self) ?? 0
    }
    
    var dayOfMonth: Int {
        return Foundation.Calendar.current.component(.day, from: self)
    }
    
    var hours: Int {
        return Foundation.Calendar.current.component(.hour, from: self)
    }
    
    var minutes: Int {
        return Foundation.Calendar.current.component(.minute, from: self)
    }
    
}

// MARK: - Date operators

infix operator =>

extension Date {
    
    static func +(date: Date, dateUnit: Years) -> Date {
        return date.setupComponents { $0.year = dateUnit.value }
    }
    
    static func -(date: Date, dateUnit: Years) -> Date {
        return date.setupComponents { $0.year = -dateUnit.value }
    }
    
    static func +(date: Date, dateUnit: Months) -> Date {
        return date.setupComponents { $0.month = dateUnit.value }
    }
    
    static func -(date: Date, dateUnit: Months) -> Date {
        return date.setupComponents { $0.month = -dateUnit.value }
    }
    
    static func +(date: Date, dateUnit: Weeks) -> Date {
        return date.setupComponents { $0.weekOfYear = dateUnit.value }
    }
    
    static func -(date: Date, dateUnit: Weeks) -> Date {
        return date.setupComponents { $0.weekOfYear = -dateUnit.value }
    }
    
    static func +(date: Date, dateUnit: Days) -> Date {
        return date.setupComponents { $0.day = dateUnit.value }
    }
    
    static func -(date: Date, dateUnit: Days) -> Date {
        return date.setupComponents { $0.day = -dateUnit.value }
    }
    
    static func +(date: Date, dateUnit: Hours) -> Date {
        return date.setupComponents { $0.hour = dateUnit.value }
    }
    
    static func -(date: Date, dateUnit: Hours) -> Date {
        return date.setupComponents { $0.hour = -dateUnit.value }
    }
    
    static func +(date: Date, dateUnit: Minutes) -> Date {
        return date.setupComponents { $0.minute = dateUnit.value }
    }
    
    static func -(date: Date, dateUnit: Minutes) -> Date {
        return date.setupComponents { $0.minute = -dateUnit.value }
    }
    
    
    static func =>(date: inout Date, dateUnit: Years) {
        date = date.changeComponents { $0.year = dateUnit.value }
    }
    
    static func =>(date: inout Date, dateUnit: Months) {
        date = date.changeComponents { $0.month = dateUnit.value }
    }
    
    static func =>(date: inout Date, dateUnit: Weeks) {
        date = date.changeComponents { $0.weekOfYear = dateUnit.value }
    }
    
    static func =>(date: inout Date, dateUnit: Hours) {
        date = date.changeComponents { $0.hour = dateUnit.value }
    }
    
    static func =>(date: inout Date, dateUnit: Minutes) {
        date = date.changeComponents { $0.minute = dateUnit.value }
    }
    
    
    fileprivate func setupComponents(_ componentsConfiguration: (inout DateComponents) -> Void) -> Date {
        var components = Date.emptyComponents
        
        componentsConfiguration(&components)
        
        return Foundation.Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    private static var emptyComponents: DateComponents {
        return DateComponents(calendar: Foundation.Calendar.current, timeZone: TimeZone.current, era: 0, year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, nanosecond: 0, weekday: 0, weekdayOrdinal: 0, quarter: 0, weekOfMonth: 0, weekOfYear: 0, yearForWeekOfYear: 0)
    }
    
}

extension Optional where Wrapped == Date {
    
    static func +(date: Date?, dateUnit: Years) -> Date? {
        return date?.setupComponents { $0.year = dateUnit.value }
    }
    
    static func -(date: Date?, dateUnit: Years) -> Date? {
        return date?.setupComponents { $0.year = -dateUnit.value }
    }
    
    static func +(date: Date?, dateUnit: Months) -> Date? {
        return date?.setupComponents { $0.month = dateUnit.value }
    }
    
    static func -(date: Date?, dateUnit: Months) -> Date? {
        return date?.setupComponents { $0.month = -dateUnit.value }
    }
    
    static func +(date: Date?, dateUnit: Weeks) -> Date? {
        return date?.setupComponents { $0.weekOfYear = dateUnit.value }
    }
    
    static func -(date: Date?, dateUnit: Weeks) -> Date? {
        return date?.setupComponents { $0.weekOfYear = -dateUnit.value }
    }
    
    static func +(date: Date?, dateUnit: Days) -> Date? {
        return date?.setupComponents { $0.day = dateUnit.value }
    }
    
    static func -(date: Date?, dateUnit: Days) -> Date? {
        return date?.setupComponents { $0.day = -dateUnit.value }
    }
    
    static func +(date: Date?, dateUnit: Hours) -> Date? {
        return date?.setupComponents { $0.hour = dateUnit.value }
    }
    
    static func -(date: Date?, dateUnit: Hours) -> Date? {
        return date?.setupComponents { $0.hour = -dateUnit.value }
    }
    
    static func +(date: Date?, dateUnit: Minutes) -> Date? {
        return date?.setupComponents { $0.minute = dateUnit.value }
    }
    
    static func -(date: Date?, dateUnit: Minutes) -> Date? {
        return date?.setupComponents { $0.minute = -dateUnit.value }
    }
    
    static func =>(date: inout Date?, dateUnit: Years) {
        date = date?.changeComponents { $0.year = dateUnit.value }
    }
    
    static func =>(date: inout Date?, dateUnit: Months) {
        date = date?.changeComponents { $0.month = dateUnit.value }
    }
    
    static func =>(date: inout Date?, dateUnit: Weeks) {
        date = date?.changeComponents { $0.weekOfYear = dateUnit.value }
    }
    
    static func =>(date: inout Date?, dateUnit: Hours) {
        date = date?.changeComponents { $0.hour = dateUnit.value }
    }
    
    static func =>(date: inout Date?, dateUnit: Minutes) {
        date = date?.changeComponents { $0.minute = dateUnit.value }
    }
    
}

// MARK: - Date shortcuts

extension Date {
    
    var startOfDay: Date {
        return changeComponents { components in
            components.hour = 0
            components.minute = 0
            components.second = 0
            components.nanosecond = 0
        }
    }
    
    var endOfDay: Date {
        return changeComponents { components in
            components.hour = 23
            components.minute = 59
            components.second = 59
            components.nanosecond = 9
        }
    }
    
    var nextDay: Date {
        return changeComponents { components in
            if components.day != nil {
                components.day! += 1
            }
        }
    }
    
    var previousDay: Date {
        return changeComponents { components in
            if components.day != nil {
                components.day! -= 1
            }
        }
    }
    
    
    var startOfHour: Date {
        return changeComponents { components in
            components.minute = 0
            components.second = 0
            components.nanosecond = 0
        }
    }
    
    
    fileprivate func changeComponents(_ componentsConfiguration: (inout DateComponents) -> Void) -> Date {
        var components = Foundation.Calendar.current.dateComponents(in: TimeZone.current, from: self)
        
        componentsConfiguration(&components)
        
        return Foundation.Calendar.current.date(from: components) ?? self
    }
    
}

// MARK: - Dates comparision

extension Date {
    
    static func ==(lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == .orderedSame
    }
    
    static func >=(lhs: Date, rhs: Date) -> Bool {
        switch lhs.compare(rhs) {
        case .orderedSame, .orderedDescending: return true
        case .orderedAscending: return false
        }
    }
    
    static func <=(lhs: Date, rhs: Date) -> Bool {
        switch lhs.compare(rhs) {
        case .orderedSame, .orderedAscending: return true
        case .orderedDescending: return false
        }
    }
    
    static func >(lhs: Date, rhs: Date) -> Bool {
        switch lhs.compare(rhs) {
        case .orderedDescending: return true
        default: return false
        }
    }
    
    static func <(lhs: Date, rhs: Date) -> Bool {
        switch lhs.compare(rhs) {
        case .orderedAscending: return true
        default: return false
        }
    }
    
    
    func isWithinSameDay(of date: Date) -> Bool {
        return self.year == date.year && self.month == date.month && self.dayOfMonth == date.dayOfMonth
    }
    
    func isWithinSameHour(of date: Date) -> Bool {
        return self.isWithinSameDay(of: date) && self.hours == date.hours
    }
    
}

// MARK: - Date strings

extension Date {
    
    func asString(format: String, localized: Bool = false) -> String {
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

class DateUnit<ValueType> {
    let value: ValueType
    
    init(value: ValueType) {
        self.value = value
    }
}

final class Years: DateUnit<Int> {}
final class Months: DateUnit<Int> {}
final class Weeks: DateUnit<Int> {}
final class Days: DateUnit<Int> {}
final class Hours: DateUnit<Int> {}
final class Minutes: DateUnit<Int> {}
final class Seconds: DateUnit<Int> {}

extension Int {
    
    var asYears: Years {
        return Years(value: self)
    }
    
    var asMonths: Months {
        return Months(value: self)
    }
    
    var asWeeks: Weeks {
        return Weeks(value: self)
    }
    
    var asDays: Days {
        return Days(value: self)
    }
    
    var asHours: Hours {
        return Hours(value: self)
    }
    
    var asMinutes: Minutes {
        return Minutes(value: self)
    }
    
    var asSeconds: Seconds {
        return Seconds(value: self)
    }
    
}
