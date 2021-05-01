//
//  StageEntity+Mapping.swift
//  TasksKit
//
//  Created by Илья Харабет on 27.04.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import class Foundation.NSDate

public extension StageEntity {

    func map(from subtask: Stage) {
        self.id = subtask.id
        self.title = subtask.title
        self.isDone = subtask.isDone
        self.sortPosition = Int32(subtask.sortPosition)
        self.creationDate = subtask.creationDate
    }

}

extension StageEntity: IdentifiableEntity, ModifiableEntity, SyncableEntity, ChildEntity {
    public var parent: IdentifiableEntity? {
        return goal
    }
}
