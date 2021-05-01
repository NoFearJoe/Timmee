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
    
    public var habits: [Habit] = []
    public var stages: [Stage] = []
        
    public init(goal: GoalEntity) {
        id = goal.id ?? ""
        title = goal.title ?? ""
        note = goal.note ?? ""
        isDone = goal.isDone
        creationDate = goal.creationDate! as Date
        
        stages = (Array(goal.stages as? Set<StageEntity> ?? Set())).map { Stage(entity: $0) }
        habits = (Array(goal.habits as? Set<HabitEntity> ?? Set())).map { Habit(habit: $0) }
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
        goal.habits = habits
        return goal
    }
    
}

extension Goal: Hashable {
    
    public static func ==(lhs: Goal, rhs: Goal) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.note == rhs.note &&
            lhs.isDone == rhs.isDone &&
            lhs.stages == rhs.stages &&
            lhs.habits == rhs.habits
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

extension Goal: CustomEquatable {
    
    public func isEqual(to item: Goal) -> Bool {
        id == item.id
    }
    
}
