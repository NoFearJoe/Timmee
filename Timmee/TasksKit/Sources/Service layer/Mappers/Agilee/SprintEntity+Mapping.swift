//
//  SprintEntity+Mapping.swift
//  TasksKit
//
//  Created by Илья Харабет on 15/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

public extension SprintEntity {
    
    func map(from entity: Sprint) {
        id = entity.id
        number = Int32(entity.number)
        startDate = entity.startDate
        endDate = entity.endDate
        duration = Int16(entity.duration)
        isReady = entity.isReady
        notificationsEnabled = entity.notifications.isEnabled
        notificationsDays = entity.notifications.days?.map { $0.string }.joined(separator: ",")
        notificationsTime = entity.notifications.time.flatMap { "\($0.0):\($0.1)" }
    }
    
}

extension SprintEntity: IdentifiableEntity, ModifiableEntity, SyncableEntity {}
