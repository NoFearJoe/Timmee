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

public class Task {

    public var id: String
    public var title: String
    public var isImportant: Bool
    public var notification: NotificationMask
    public var notificationDate: Date?
    public var note: String
    public var repeating: RepeatMask
    public var repeatEndingDate: Date?
    public var dueDate: Date?
    public var location: CLLocation?
    public var address: String?
    public var shouldNotifyAtLocation: Bool
    public var isDone: Bool
    public var inProgress: Bool
    public let creationDate: Date
    
    public var tags: [Tag] = []
    public var subtasks: [Subtask] = []
    
    public var timeTemplate: TimeTemplate?
    
    public var attachments: [String]
    
    public init(task: TaskEntity) {
        id = task.id!
        title = task.title ?? ""
        isImportant = task.isImportant
        notification = NotificationMask(mask: task.notificationMask)
        notificationDate = task.notificationDate
        note = task.note ?? ""
        repeating = RepeatMask(string: task.repeatMask ?? "")
        dueDate = task.dueDate as Date?
        repeatEndingDate = task.repeatEndingDate as Date?
        
        if let data = task.location as Data? {
            location = NSKeyedUnarchiver.unarchiveObject(with: data) as? CLLocation
        }
        address = task.address
        
        shouldNotifyAtLocation = task.shouldNotifyAtLocation
        isDone = task.isDone
        inProgress = task.inProgress
        creationDate = task.creationDate! as Date
        
        tags = (Array(task.tags as? Set<TagEntity> ?? Set())).map { Tag(entity: $0) }
        subtasks = (Array(task.subtasks as? Set<SubtaskEntity> ?? Set())).map { Subtask(entity: $0) }
        
        if let template = task.timeTemplate {
            timeTemplate = TimeTemplate(entity: template)
        }
        
        attachments = task.attachments as? [String] ?? []
    }
    
    public init(id: String,
                title: String,
                isImportant: Bool,
                notification: NotificationMask,
                notificationDate: Date?,
                note: String,
                repeating: RepeatMask,
                repeatEndingDate: Date?,
                dueDate: Date?,
                location: CLLocation?,
                address: String?,
                shouldNotifyAtLocation: Bool,
                attachments: [String],
                isDone: Bool,
                inProgress: Bool,
                creationDate: Date) {
        self.id = id
        self.title = title
        self.isImportant = isImportant
        self.notification = notification
        self.notificationDate = notificationDate
        self.note = note
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
    }
    
   public convenience init(id: String,
                           title: String) {
        self.init(id: id,
                  title: title,
                  isImportant: false,
                  notification: .doNotNotify,
                  notificationDate: nil,
                  note: "",
                  repeating: .init(string: ""),
                  repeatEndingDate: nil,
                  dueDate: nil,
                  location: nil,
                  address: nil,
                  shouldNotifyAtLocation: false,
                  attachments: [],
                  isDone: false,
                  inProgress: false,
                  creationDate: Date())
    }
    
    public var copy: Task {
        let task = Task(id: id,
                        title: title,
                        isImportant: isImportant,
                        notification: notification,
                        notificationDate: notificationDate,
                        note: note,
                        repeating: repeating,
                        repeatEndingDate: repeatEndingDate,
                        dueDate: dueDate,
                        location: location,
                        address: address,
                        shouldNotifyAtLocation: shouldNotifyAtLocation,
                        attachments: attachments,
                        isDone: isDone,
                        inProgress: inProgress,
                        creationDate: creationDate)
        
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
    
    private func getNextRepeatDate(of date: Date?) -> Date? {
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
                let currentDayNumber = date.weekday - 1
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

}

extension Task: Hashable {
    
    public static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var hashValue: Int {
        return id.hashValue
    }
    
}
