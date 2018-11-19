//
//  SprintEntity+Mapping.swift
//  TasksKit
//
//  Created by Илья Харабет on 15/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

public extension SprintEntity {
    
    public func map(from entity: Sprint) {
        id = entity.id
        number = Int32(entity.number)
        title = entity.title
        startDate = entity.startDate
        endDate = entity.endDate
        isReady = entity.isReady
        notificationsEnabled = entity.notifications.isEnabled
        notificationsDays = entity.notifications.days?.map { $0.string }.joined(separator: ",")
        notificationsTime = entity.notifications.time.flatMap { "\($0.0):\($0.1)" }
    }
    
}
