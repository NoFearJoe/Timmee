//
//  Calendar.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date

/// Представляет собой ограниченный отрезок времени, который можно использовать для построения календаря
public final class Calendar {
    
    public struct Entry {
        public let dayName: String
        public let dayNumber: Int
        public let isEnabled: Bool
        public let isWeekend: Bool
    }
    
    public struct MonthEntry {
        public let name: String
        public let daysCount: Int
    }
    
    private var dates: DateRange
    
    private var startDate: Date
    private var shift: Int
    private var daysCount: Int
    
    /**
     Создает календарь
     
     - Parameters:
     - start: Дата начала календаря
     - shift: Сдвиг даты начала
     - daysCount: Количество дней в календаре
     */
    public init(start: Date, shift: Int, daysCount: Int) {
        self.startDate = start
        self.shift = shift
        self.daysCount = daysCount
        self.dates = Calendar.build(start: start, shift: shift, daysCount: daysCount)
    }
    
    
    /**
     Перестраивает календарь с новой датой начала, но с предыдущим сдвигом и количеством дней
     
     - Parameter startDate: Новая дата начала календаря
     */
    public func changeStartDate(to startDate: Date) {
        self.startDate = startDate
        dates = Calendar.build(start: startDate, shift: shift, daysCount: daysCount)
    }
    
    
    /**
     Возвращает массив Calendar.Entry
     
     - Returns: Массив Calendar.Entry
     */
    public func dataSource() -> [Calendar.Entry] {
        return dates.map {
            let dayName = $0.asShortWeekday
            let dayNumber = $0.dayOfMonth
            let isEnabled = self.isEnabled(day: $0)
            let isWeekend = self.isWeekend(day: $0)
            
            return Calendar.Entry(dayName: dayName,
                                  dayNumber: dayNumber,
                                  isEnabled: isEnabled,
                                  isWeekend: isWeekend)
        }
    }
    
    public var entriesCount: Int {
        return dates.count
    }
    
    public func entry(at index: Int) -> Calendar.Entry? {
        let date = dates[index]
        
        return Calendar.Entry(dayName: date.asShortWeekday,
                              dayNumber: date.dayOfMonth,
                              isEnabled: isEnabled(day: date),
                              isWeekend: isWeekend(day: date))
    }
    
    public func monthDataSource() -> [Calendar.MonthEntry] {
        let allMonths = dates.map { $0.asMonth }
        
        var acc: [(String, Int)] = []
        var previousValue: String = ""
        var currentCount = 0
        allMonths.forEach { month in
            if previousValue == month {
                currentCount += 1
            } else if previousValue == "" {
                previousValue = month
                currentCount += 1
            } else {
                acc.append((previousValue, currentCount))
                currentCount = 1
                previousValue = month
            }
        }
        return acc.map { MonthEntry(name: $0.0, daysCount: $0.1) }
    }
    
    /**
     Возвращает дату дня по номеру дня в календаре
     
     - Parameter dayNumber: Номер дня в календаре
     
     - Returns: Дата дня
     */
    public func date(by dayNumber: Int) -> Date {
        return dates[dayNumber]
    }
    
    /**
     Возвращает номер дня в календаре по заданной дате
     
     - Parameter date: Дата
     
     - Returns: Номер дня в календаре
     */
    public func index(of date: Date) -> Int {
        return dates.index(of: date.startOfDay) ?? -1
    }
    
    
    private class func build(start: Date, shift: Int, daysCount: Int) -> DateRange {
        var first = start
        if shift < 0 {
            first = first + shift.asDays
        } else if shift > 0 {
            first = first - shift.asDays
        }
        
        return DateRange(startDate: first.startOfDay, daysCount: daysCount)
    }
    
    
    private func isEnabled(day date: Date) -> Bool {
        return date >= startDate.startOfDay
    }
    
    private func isWeekend(day date: Date) -> Bool {
        return date.weekday > 5
    }
    
}


private struct DateRange: Collection {
    
    typealias Index = Int
    typealias Iterator = DateRangeIterator
    
    var startDate: Date
    var daysCount: Int
    
}

extension DateRange {
    
    var startIndex: Index {
        return 0
    }
    
    var endIndex: Index {
        return daysCount
    }
    
    subscript(index: Index) -> Iterator.Element {
        return startDate + index.asDays
    }
    
    public func index(after i: Int) -> Int {
        return Swift.max(startIndex, Swift.min(i + 1, endIndex))
    }
    
}

extension DateRange: Sequence {
    
    fileprivate func makeIterator() -> DateRangeIterator {
        return DateRangeIterator(range: self)
    }
    
    
    struct DateRangeIterator: IteratorProtocol {
        
        var range: DateRange
        private var index = 0
        
        init(range: DateRange) {
            self.range = range
        }
        
        mutating func next() -> Date? {
            guard index >= range.daysCount else { return nil }
            
            let nextDate = range.startDate + index.asDays
            
            index += 1
            
            return nextDate
        }
        
    }
    
}
