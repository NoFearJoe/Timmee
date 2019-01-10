//
//  Task.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset
import struct Foundation.Data
import struct Foundation.Date
import class Foundation.NSOrderedSet
import class Foundation.NSKeyedUnarchiver
import class CoreLocation.CLLocation

public protocol Copyable {
    associatedtype T
    var copy: T { get }
}

public protocol CustomEquatable {
    associatedtype T
    func isEqual(to item: T) -> Bool
}

public class Task: Copyable {

    public var id: String
    public var kind: Kind
    public var title: String
    public var isImportant: Bool
    public var notification: NotificationMask
    public var notificationDate: Date?
    public var notificationTime: (Int, Int)?
    public var note: String
    public var link: String
    public var repeating: RepeatMask
    public var repeatEndingDate: Date?
    public var dueDate: Date?
    public var location: CLLocation?
    public var address: String?
    public var shouldNotifyAtLocation: Bool
    private(set) var isDone: Bool
    public var inProgress: Bool
    public let creationDate: Date
    private(set) var doneDates: [Date]
    
    public var tags: [Tag] = []
    public var subtasks: [Subtask] = []
    
    public var timeTemplate: TimeTemplate?
    
    public var attachments: [String]
    
    public init(entity: TaskEntity) {
        id = entity.id!
        kind = entity.kind.flatMap(Kind.init(rawValue:)) ?? .single
        title = entity.title ?? ""
        isImportant = entity.isImportant
        notification = NotificationMask(mask: entity.notificationMask)
        notificationDate = entity.notificationDate
        if let notificationTimeUnits = entity.notificationTime?.split(separator: ":").compactMap({ Int($0) }), notificationTimeUnits.count == 2 {
            notificationTime = (notificationTimeUnits[0], notificationTimeUnits[1])
        } else {
            notificationTime = nil
        }
        note = entity.note ?? ""
        link = entity.link ?? ""
        repeating = RepeatMask(string: entity.repeatMask ?? "")
        dueDate = entity.dueDate as Date?
        repeatEndingDate = entity.repeatEndingDate as Date?
        
        if let data = entity.location as Data? {
            location = NSKeyedUnarchiver.unarchiveObject(with: data) as? CLLocation
        }
        address = entity.address
        
        shouldNotifyAtLocation = entity.shouldNotifyAtLocation
        isDone = entity.isDone
        inProgress = entity.inProgress
        creationDate = entity.creationDate! as Date
        
        tags = (Array(entity.tags as? Set<TagEntity> ?? Set())).map { Tag(entity: $0) }
        subtasks = (Array(entity.subtasks as? Set<SubtaskEntity> ?? Set())).map { Subtask(entity: $0) }
        
        if let template = entity.timeTemplate {
            timeTemplate = TimeTemplate(entity: template)
        }
        
        attachments = entity.attachments as? [String] ?? []
        doneDates = entity.doneDates as? [Date] ?? []
    }
    
    public init(id: String,
                kind: Kind,
                title: String,
                isImportant: Bool,
                notification: NotificationMask,
                notificationDate: Date?,
                notificationTime: (Int, Int)?,
                note: String,
                link: String,
                repeating: RepeatMask,
                repeatEndingDate: Date?,
                dueDate: Date?,
                location: CLLocation?,
                address: String?,
                shouldNotifyAtLocation: Bool,
                attachments: [String],
                isDone: Bool,
                inProgress: Bool,
                creationDate: Date,
                doneDates: [Date]) {
        self.id = id
        self.kind = kind
        self.title = title
        self.isImportant = isImportant
        self.notification = notification
        self.notificationDate = notificationDate
        self.notificationTime = notificationTime
        self.note = note
        self.link = link
        self.repeating = repeating
        self.repeatEndingDate = repeatEndingDate
        self.dueDate = dueDate
        self.location = location
        self.address = address
        self.shouldNotifyAtLocation = shouldNotifyAtLocation
        self.attachments = attachments
        self.isDone = isDone
        self.inProgress = inProgress
        self.creationDate = creationDate
        self.doneDates = doneDates
    }
    
   public convenience init(id: String,
                           title: String) {
        self.init(id: id,
                  kind: .single,
                  title: title,
                  isImportant: false,
                  notification: .doNotNotify,
                  notificationDate: nil,
                  notificationTime: nil,
                  note: "",
                  link: "",
                  repeating: .init(string: ""),
                  repeatEndingDate: nil,
                  dueDate: nil,
                  location: nil,
                  address: nil,
                  shouldNotifyAtLocation: false,
                  attachments: [],
                  isDone: false,
                  inProgress: false,
                  creationDate: Date(),
                  doneDates: [])
    }
    
    public var copy: Task {
        let task = Task(id: id,
                        kind: kind,
                        title: title,
                        isImportant: isImportant,
                        notification: notification,
                        notificationDate: notificationDate,
                        notificationTime: notificationTime,
                        note: note,
                        link: link,
                        repeating: repeating,
                        repeatEndingDate: repeatEndingDate,
                        dueDate: dueDate,
                        location: location,
                        address: address,
                        shouldNotifyAtLocation: shouldNotifyAtLocation,
                        attachments: attachments,
                        isDone: isDone,
                        inProgress: inProgress,
                        creationDate: creationDate,
                        doneDates: doneDates)
        
        task.tags = tags
        task.subtasks = subtasks
        
        task.timeTemplate = timeTemplate
        
        return task
    }
    
    public var nextDueDate: Date? {
        return getNextRepeatDate(of: dueDate)
    }
    
    public var nextNotificationDate: Date? {
        return getNextRepeatDate(of: notificationDate)
    }
    
    public func getNextRepeatDate(of date: Date?) -> Date? {
        guard var date = date else { return nil }
        
        let now = Date()
        
        while date <= now {
            switch repeating.type {
            case .every(let unit):
                switch unit {
                case .day: date = date + repeating.value.asDays as Date
                case .week: date = date + repeating.value.asWeeks as Date
                case .month: date = date + repeating.value.asMonths as Date
                case .year: date = date + repeating.value.asYears as Date
                }
            case .on(let unit):
                let dayNumbers = unit.dayNumbers.sorted()
                let currentDayNumber = DayUnit(weekday: date.weekday).number
                let currentDayNumberIndex = dayNumbers.index(of: currentDayNumber) ?? 0
                let nextDayNumberIndex = currentDayNumberIndex + 1 >= dayNumbers.count ? 0 : currentDayNumberIndex + 1
                let nextDayNumber = dayNumbers.item(at: nextDayNumberIndex) ?? dayNumbers.item(at: 0) ?? 0
                let dayNumbersDifference = nextDayNumberIndex >= currentDayNumberIndex ? nextDayNumber - currentDayNumber : (7 + nextDayNumber) - currentDayNumber
                
                date = date + dayNumbersDifference.asDays as Date
            case .never: return nil
            }
        }
        
        if case .never = repeating.type {
            return nil
        }
        
        return date
    }
    
    public func isDone(at date: Date?) -> Bool {
        switch kind {
        case .single:
            return isDone
        case .regular:
            guard let date = date?.startOfDay else { return false }
            return doneDates.contains(where: { date.isWithinSameDay(of: $0) })
        }
    }
    
    public func setDone(_ isDone: Bool, at date: Date?) {
        switch kind {
        case .single:
            return self.isDone = isDone
        case .regular:
            guard let date = date?.startOfDay else { return }
            isDone ? doneDates.append(date) : doneDates.remove(object: date)
        }
    }
    
    public func isFinished(at date: Date?) -> Bool {
        guard kind == .regular else { return false }
        return repeatEndingDate?.isLower(than: date ?? Date()) == true
    }

}

public extension Task {
    
    /// Тип задачи - обычная, регулярная...
    public enum Kind: String {
        case single, regular
    }
    
}

extension Task: CustomEquatable {
    
    public func isEqual(to item: Task) -> Bool {
        return id == item.id
    }
    
}

extension Task: Hashable {
    
    public static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
            && lhs.dueDate == rhs.dueDate
            && lhs.note == rhs.note
            && lhs.address == rhs.address
            && lhs.attachments == rhs.attachments
            && lhs.notification == rhs.notification
            && lhs.notificationDate == rhs.notificationDate
            && lhs.notificationTime?.0 == rhs.notificationTime?.0 && lhs.notificationTime?.1 == rhs.notificationTime?.1
            && lhs.repeatEndingDate == rhs.repeatEndingDate
            && lhs.repeating == rhs.repeating
            && lhs.kind == rhs.kind
            && lhs.title == rhs.title
            && lhs.subtasks == rhs.subtasks
            && lhs.tags == rhs.tags
            && lhs.timeTemplate == rhs.timeTemplate
            && lhs.doneDates == rhs.doneDates
            && lhs.isDone == rhs.isDone
            && lhs.inProgress == rhs.inProgress
            && lhs.isImportant == rhs.isImportant
    }
    
    public var hashValue: Int {
        return id.hashValue
    }
    
}

extension Task {
    
    public var shouldBeDoneToday: Bool {
        return shouldBeDone(at: Date())
    }
    
    public var shouldBeDoneTomorrow: Bool {
        return shouldBeDone(at: Date().nextDay)
    }
    
    // TODO: Учитывать isDone
    public var shouldBeDoneAtThisWeek: Bool {
        let startOfWeek = Date().startOfDay
        let endOfWeek = (Date() + 6.asDays).endOfDay
        switch kind {
        case .single:
            guard let dueDate = dueDate else { return false }
            return dueDate >= startOfWeek && dueDate <= endOfWeek
        case .regular:
            guard let startDate = dueDate?.startOfDay else { return false }
            switch repeating.type {
            case .never:
                return false
            case let .every(unit):
                switch unit {
                case .day, .week:
                    if let endDate = repeatEndingDate {
                        return startDate <= endOfWeek && endDate >= startOfWeek
                    } else {
                        return startDate <= endOfWeek
                    }
                case .month:
                    let dayOfMonth = startDate.dayOfMonth
                    let containsDay: Bool
                    if startOfWeek.month == endOfWeek.month {
                        containsDay = dayOfMonth >= startOfWeek.dayOfMonth && dayOfMonth <= endOfWeek.dayOfMonth
                    } else {
                        containsDay = dayOfMonth >= startOfWeek.dayOfMonth || dayOfMonth <= endOfWeek.dayOfMonth
                    }
                    if let endDate = repeatEndingDate {
                        return startDate <= endOfWeek && endDate >= startOfWeek && containsDay
                    } else {
                        return startDate <= endOfWeek && containsDay
                    }
                case .year:
                    let month = startDate.month
                    let dayOfMonth = startDate.dayOfMonth
                    let containsDay: Bool
                    if startOfWeek.month == endOfWeek.month {
                        containsDay = dayOfMonth >= startOfWeek.dayOfMonth && dayOfMonth <= endOfWeek.dayOfMonth
                    } else {
                        containsDay = dayOfMonth >= startOfWeek.dayOfMonth || dayOfMonth <= endOfWeek.dayOfMonth
                    }
                    let containsMonth = month >= startOfWeek.month && month <= endOfWeek.month
                    if let endDate = repeatEndingDate {
                        return startDate <= endOfWeek && endDate >= startOfWeek && containsMonth && containsDay
                    } else {
                        return startDate <= endOfWeek && containsMonth && containsDay
                    }
                }
            case .on:
                if let endDate = repeatEndingDate {
                    return startDate <= endOfWeek && endDate >= startOfWeek
                } else {
                    return startDate <= endOfWeek
                }
            }
        }
    }
    
    // TODO: Учитывать isDone
    private func shouldBeDone(at date: Date) -> Bool {
        switch kind {
        case .single:
            guard let dueDate = dueDate else { return false }
            return dueDate >= date.startOfDay && dueDate <= date.endOfDay
        case .regular:
            guard let startDate = dueDate?.startOfDay else { return false }
            switch repeating.type {
            case .never:
                return false
            case let .every(unit):
                switch unit {
                case .day:
                    if let endDate = repeatEndingDate {
                        return startDate <= date.startOfDay && endDate >= date.endOfDay
                    } else {
                        return startDate <= date.startOfDay
                    }
                case .week:
                    let isWeekdaysEqual = startDate.weekday == date.weekday
                    if let endDate = repeatEndingDate {
                        return startDate <= date.startOfDay && endDate >= date.endOfDay && isWeekdaysEqual
                    } else {
                        return startDate <= date.startOfDay && isWeekdaysEqual
                    }
                case .month:
                    let isDaysEqual = startDate.dayOfMonth == date.dayOfMonth
                    if let endDate = repeatEndingDate {
                        return startDate <= date.startOfDay && endDate >= date.endOfDay && isDaysEqual
                    } else {
                        return startDate <= date.startOfDay && isDaysEqual
                    }
                case .year:
                    let isDaysEqual = startDate.dayOfMonth == date.dayOfMonth
                    let isMonthsEqual = startDate.month == date.month
                    if let endDate = repeatEndingDate {
                        return startDate <= date.startOfDay && endDate >= date.endOfDay && isMonthsEqual && isDaysEqual
                    } else {
                        return startDate <= date.startOfDay && isMonthsEqual && isDaysEqual
                    }
                }
            case let .on(units):
                let day = DayUnit(weekday: date.weekday)
                if let endDate = repeatEndingDate {
                    return startDate <= date.startOfDay && endDate >= date.endOfDay && units.dayNumbers.contains(day.number)
                } else {
                    return startDate <= date.startOfDay && units.dayNumbers.contains(day.number)
                }
            }
        }
    }
    
}
