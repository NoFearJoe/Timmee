//
//  Task.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Data
import struct Foundation.Date
import class Foundation.NSOrderedSet
import class Foundation.NSKeyedUnarchiver
import class CoreLocation.CLLocation

class Task {

    var id: String
    var title: String
    var isImportant: Bool
    var notification: NotificationMask
    var note: String
    var repeating: RepeatMask
    var repeatEndingDate: Date?
    var dueDate: Date?
    var location: CLLocation?
    var address: String?
    var shouldNotifyAtLocation: Bool
    var isDone: Bool
    var inProgress: Bool
    let creationDate: Date
    
    var tags: [Tag] = []
    var subtasks: [Subtask] = []
    
    var timeTemplate: TimeTemplate?
    
    var attachments: [String]
    
    init(task: TaskEntity) {
        id = task.id!
        title = task.title ?? ""
        isImportant = task.isImportant
        notification = NotificationMask(mask: task.notificationMask)
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
        subtasks = (task.subtasks!.array as! [SubtaskEntity]).map { Subtask(entity: $0) }
        
        if let template = task.timeTemplate {
            timeTemplate = TimeTemplate(entity: template)
        }
        
        attachments = task.attachments as? [String] ?? []
    }
    
    init(id: String,
         title: String,
         isImportant: Bool,
         notification: NotificationMask,
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
    
    convenience init(id: String,
                     title: String) {
        self.init(id: id,
                  title: title,
                  isImportant: false,
                  notification: .doNotNotify,
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
    
    var copy: Task {
        let task = Task(id: id,
                        title: title,
                        isImportant: isImportant,
                        notification: notification,
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
    
    var nextDueDate: Date? {
        guard var dueDate = dueDate else { return nil }
        
        let now = Date()
        
        while dueDate <= now {
            switch repeating.type {
            case .every(let unit):
                switch unit {
                case .day: dueDate = dueDate + repeating.value.asDays as Date
                case .week: dueDate = dueDate + repeating.value.asWeeks as Date
                case .month: dueDate = dueDate + repeating.value.asMonths as Date
                case .year: dueDate = dueDate + repeating.value.asYears as Date
                }
            case .on(let unit):
                let dayNumbers = unit.dayNumbers.sorted()
                let currentDayNumber = dueDate.weekday - 1
                let currentDayNumberIndex = dayNumbers.index(of: currentDayNumber) ?? 0
                let nextDayNumberIndex = currentDayNumberIndex + 1 >= dayNumbers.count ? 0 : currentDayNumberIndex + 1
                let nextDayNumber = dayNumbers.item(at: nextDayNumberIndex) ?? dayNumbers.item(at: 0) ?? 0
                let dayNumbersDifference = nextDayNumberIndex >= currentDayNumberIndex ? nextDayNumber - currentDayNumber : (7 + nextDayNumber) - currentDayNumber
                
                dueDate = dueDate + dayNumbersDifference.asDays as Date
            case .never: return nil
            }
        }
        
        if case .never = repeating.type {
            return nil
        }
        
        return dueDate
    }

}

extension Task: Hashable {
    
    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
    
}
