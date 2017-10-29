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
    let creationDate: Date
    
    var tags: [Tag] = []
    var subtasks: [Subtask] = []
    
    init(task: TaskEntity) {
        id = task.id!
        title = task.title ?? ""
        isImportant = task.isImportant
        notification = NotificationMask(mask: task.notificationMask)
        note = task.note ?? ""
        repeating = RepeatMask(string: task.repeatMask ?? "")
        dueDate = task.dueDate as Date?
        repeatEndingDate = task.repeatEndingDate as Date?
        
        // TODO: handle location
        if let data = task.location as Data? {
            location = NSKeyedUnarchiver.unarchiveObject(with: data) as? CLLocation
        }
        address = task.address
        
        shouldNotifyAtLocation = task.shouldNotifyAtLocation
        isDone = task.isDone
        creationDate = task.creationDate! as Date
        
        tags = (Array(task.tags as? Set<TagEntity> ?? Set())).map { Tag(entity: $0) }
        subtasks = (task.subtasks!.array as! [SubtaskEntity]).map { Subtask(entity: $0) }
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
         isDone: Bool,
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
        self.isDone = isDone
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
                  isDone: false,
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
                        isDone: isDone,
                        creationDate: creationDate)
        
        task.tags = tags
        task.subtasks = subtasks
        
        return task
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
