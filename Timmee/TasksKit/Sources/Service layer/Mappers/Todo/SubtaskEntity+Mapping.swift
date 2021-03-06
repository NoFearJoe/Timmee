//
//  SubtaskEntity+Mapping.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSDate

public extension SubtaskEntity {

    func map(from subtask: Subtask) {
        self.id = subtask.id
        self.title = subtask.title
        self.isDone = subtask.isDone
        self.sortPosition = Int32(subtask.sortPosition)
        self.creationDate = subtask.creationDate
    }

}

extension SubtaskEntity: IdentifiableEntity, ModifiableEntity, SyncableEntity, ChildEntity {
    public var parent: IdentifiableEntity? {
        return goal // ?? task
    }
}
