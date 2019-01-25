//
//  GoalEntity+Mapping.swift
//  TasksKit
//
//  Created by Илья Харабет on 15/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

public extension GoalEntity {
    
    public func map(from entity: Goal) {
        id = entity.id
        title = entity.title
        note = entity.note
        isDone = entity.isDone
        creationDate = entity.creationDate
    }
    
}

extension GoalEntity: IdentifiableEntity, ModifiableEntity, SyncableEntity {}
