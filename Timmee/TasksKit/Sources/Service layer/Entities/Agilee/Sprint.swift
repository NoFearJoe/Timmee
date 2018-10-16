//
//  Sprint.swift
//  TasksKit
//
//  Created by Илья Харабет on 15/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSPredicate
import class UIKit.UIColor
import class UIKit.UIImage
import class CoreData.NSFetchRequest

public class Sprint {
    public var id: String
    public var number: Int
    public var title: String
    public var startDate: Date
    public var endDate: Date
    public var isReady: Bool
    
    public init(sprintEntity: SprintEntity) {
        id = sprintEntity.id!
        number = Int(sprintEntity.number)
        title = sprintEntity.title ?? ""
        startDate = sprintEntity.startDate! as Date
        endDate = sprintEntity.endDate! as Date
        isReady = sprintEntity.isReady
    }
    
    public init(id: String,
                number: Int,
                title: String,
                startDate: Date,
                endDate: Date,
                isReady: Bool) {
        self.id = id
        self.number = number
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isReady = isReady
    }
    
    public var copy: Sprint {
        return Sprint(id: id,
                      number: number,
                      title: title,
                      startDate: startDate,
                      endDate: endDate,
                      isReady: isReady)
    }
    
//    public var tasksFetchPredicate: NSPredicate? {
//        return NSPredicate(format: "sprint.id == %@", self.id)
//    }
}

//public extension Sprint {
//    public final var tasksFetchRequest: NSFetchRequest<TaskEntity> {
//        let fetchRequest = NSFetchRequest<TaskEntity>(entityName: "Task")
//        fetchRequest.predicate = tasksFetchPredicate
//        return fetchRequest
//    }
//}

extension Sprint: Equatable {
    public static func ==(lhs: Sprint, rhs: Sprint) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Sprint: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}
