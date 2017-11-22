//
//  Calendar.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date

/// Представляет собой ограниченный отрезок времени, который можно использовать для построения календаря
final class Calendar {
    
    struct Entry {
        let dayName: String
        let dayNumber: Int
        let isEnabled: Bool
        let isWeekend: Bool
    }
    
    struct MonthEntry {
        let name: String
        let daysCount: Int
    }
    
    fileprivate var dates: DateRange
    
    fileprivate var startDate: Date
    fileprivate var shift: Int
    fileprivate var daysCount: Int
    
    /**
     Создает календарь
     
     - Parameters:
     - start: Дата начала календаря
     - shift: Сдвиг даты начала
     - daysCount: Количество дней в календаре
     */
    init(start: Date, shift: Int, daysCount: Int) {
        self.startDate = start
        self.shift = shift
        self.daysCount = daysCount
        self.dates = Calendar.build(start: start, shift: shift, daysCount: daysCount)
    }
    
    
    /**
     Перестраивает календарь с новой датой начала, но с предыдущим сдвигом и количеством дней
     
     - Parameter startDate: Новая дата начала календаря
     */
    func changeStartDate(to startDate: Date) {
        self.startDate = startDate
        dates = Calendar.build(start: startDate, shift: shift, daysCount: daysCount)
    }
    
    
    /**
     Возвращает массив Calendar.Entry
     
     - Returns: Массив Calendar.Entry
     */
    func dataSource() -> [Calendar.Entry] {
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
    
    var entriesCount: Int {
        return dates.count
    }
    
    func entry(at index: Int) -> Calendar.Entry? {
        let date = dates[index]
        
        return Calendar.Entry(dayName: date.asShortWeekday,
                              dayNumber: date.dayOfMonth,
                              isEnabled: isEnabled(day: date),
                              isWeekend: isWeekend(day: date))
    }
    
    func monthDataSource() -> [Calendar.MonthEntry] {
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
    func date(by dayNumber: Int) -> Date {
        return dates[dayNumber]
    }
    
    /**
     Возвращает номер дня в календаре по заданной дате
     
     - Parameter date: Дата
     
     - Returns: Номер дня в календаре
     */
    func index(of date: Date) -> Int {
        return dates.index(of: date.startOfDay) ?? -1
    }
    
    
    fileprivate class func build(start: Date, shift: Int, daysCount: Int) -> DateRange {
        var first = start
        if shift < 0 {
            first = first + shift.asDays
        } else if shift > 0 {
            first = first - shift.asDays
        }
        
        return DateRange(startDate: first.startOfDay, daysCount: daysCount)
    }
    
    
    fileprivate func isEnabled(day date: Date) -> Bool {
        return date >= startDate.startOfDay
    }
    
    fileprivate func isWeekend(day date: Date) -> Bool {
        return date.weekday > 5
    }
    
}


fileprivate struct DateRange: Collection {
    
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
