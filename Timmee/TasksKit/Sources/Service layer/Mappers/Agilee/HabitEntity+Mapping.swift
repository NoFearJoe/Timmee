//
//  HabitEntity+Mapping.swift
//  TasksKit
//
//  Created by Илья Харабет on 15/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class Foundation.NSArray

public extension HabitEntity {
    
    func map(from entity: Habit) {
        id = entity.id
        title = entity.title
        link = entity.description
        value = entity.value?.asString
        dueTime = entity.dueTime?.string
        notification = entity.notification.string
        repeatEndingDate = entity.repeatEndingDate
        dueDays = entity.dueDays.map { $0.string }.joined(separator: ",")
        doneDates = entity.doneDates as NSArray
        creationDate = entity.creationDate
    }
    
}

extension HabitEntity: IdentifiableEntity, ModifiableEntity, SyncableEntity, ChildEntity {
    public var parent: IdentifiableEntity? {
        return sprint
    }
}
