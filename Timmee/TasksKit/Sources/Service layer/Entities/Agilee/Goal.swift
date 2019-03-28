//
//  Goal.swift
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

public class Goal: Copyable {
    
    public var id: String
    public var title: String
    public var note: String
    public var isDone: Bool
    public let creationDate: Date
    
    public var stages: [Subtask] = []
    
    public init(goal: GoalEntity) {
        id = goal.id ?? ""
        title = goal.title ?? ""
        note = goal.note ?? ""
        isDone = goal.isDone
        creationDate = goal.creationDate! as Date
        
        stages = (Array(goal.stages as? Set<SubtaskEntity> ?? Set())).map { Subtask(entity: $0) }
    }
    
    public init(id: String,
                title: String,
                note: String,
                isDone: Bool,
                creationDate: Date) {
        self.id = id
        self.title = title
        self.note = note
        self.isDone = isDone
        self.creationDate = creationDate
    }
    
    public convenience init(id: String,
                            title: String) {
        self.init(id: id,
                  title: title,
                  note: "",
                  isDone: false,
                  creationDate: Date())
    }
    
    public var copy: Goal {
        let goal = Goal(id: id,
                        title: title,
                        note: note,
                        isDone: isDone,
                        creationDate: creationDate)
        goal.stages = stages
        return goal
    }
    
}

extension Goal: Hashable {
    
    public static func ==(lhs: Goal, rhs: Goal) -> Bool {
        return lhs.isEqual(to: rhs)
    }
    
    public var hashValue: Int {
        return id.hashValue
    }
    
}

extension Goal: CustomEquatable {
    
    public func isEqual(to item: Goal) -> Bool {
        return id == item.id &&
            title == item.title &&
            note == item.note &&
            isDone == item.isDone &&
            stages == item.stages
    }
    
}
