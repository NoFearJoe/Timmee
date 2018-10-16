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

public class Habit {
    
    public var id: String
    public var title: String
    public var note: String
    public var link: String
    public var notificationDate: Date?
    public var repeatEndingDate: Date?
    public var dueDays: [DayUnit]
    public var doneDates: [Date]
    public let creationDate: Date
    
    public init(habit: HabitEntity) {
        id = habit.id!
        title = habit.title ?? ""
        note = habit.note ?? ""
        link = habit.link ?? ""
        notificationDate = habit.notificationDate
        repeatEndingDate = habit.repeatEndingDate as Date?
        dueDays = habit.dueDays?.split(separator: ",").map { DayUnit(string: String($0)) } ?? []
        doneDates = habit.doneDates as? [Date] ?? []
        creationDate = habit.creationDate! as Date
    }
    
    public init(id: String,
                title: String,
                note: String,
                link: String,
                notificationDate: Date?,
                repeatEndingDate: Date?,
                dueDays: [DayUnit],
                doneDates: [Date],
                creationDate: Date) {
        self.id = id
        self.title = title
        self.note = note
        self.link = link
        self.notificationDate = notificationDate
        self.repeatEndingDate = repeatEndingDate
        self.dueDays = dueDays
        self.doneDates = doneDates
        self.creationDate = creationDate
    }
    
    public convenience init(id: String,
                            title: String) {
        self.init(id: id,
                  title: title,
                  note: "",
                  link: "",
                  notificationDate: nil,
                  repeatEndingDate: nil,
                  dueDays: [],
                  doneDates: [],
                  creationDate: Date())
    }
    
    public var copy: Habit {
        return Habit(id: id,
                     title: title,
                     note: note,
                     link: link,
                     notificationDate: notificationDate,
                     repeatEndingDate: repeatEndingDate,
                     dueDays: dueDays,
                     doneDates: doneDates,
                     creationDate: creationDate)
    }
    
    public var nextNotificationDate: Date? {
        return getNextRepeatDate(of: notificationDate)
    }
    
    private func getNextRepeatDate(of date: Date?) -> Date? {
        guard var date = date else { return nil }
        
        let now = Date()
        let dayNumbers = dueDays.map { $0.number }.sorted()

        while date <= now {
            let currentDayNumber = date.weekday - 1
            let currentDayNumberIndex = dayNumbers.index(of: currentDayNumber) ?? 0
            let nextDayNumberIndex = currentDayNumberIndex + 1 >= dayNumbers.count ? 0 : currentDayNumberIndex + 1
            let nextDayNumber = dayNumbers.item(at: nextDayNumberIndex) ?? dayNumbers.item(at: 0) ?? 0
            let dayNumbersDifference = nextDayNumberIndex >= currentDayNumberIndex ? nextDayNumber - currentDayNumber : (7 + nextDayNumber) - currentDayNumber
            
            date = date + dayNumbersDifference.asDays as Date
        }
        
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

extension Habit: Hashable {
    
    public static func ==(lhs: Habit, rhs: Habit) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var hashValue: Int {
        return id.hashValue
    }
    
}