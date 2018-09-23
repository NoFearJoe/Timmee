//
//  WaterControl.swift
//  TasksKit
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.Date

public final class WaterControl {
    public var neededVolume: Int
    public var drunkVolume: [Date: Int]
    public var lastConfiguredSprintID: String
    public var notificationsEnabled: Bool
    public var notificationsInterval: Int
    public var notificationsStartTime: Date
    public var notificationsEndTime: Date
    
    public init(neededVolume: Int,
                drunkVolume: [Date: Int],
                lastConfiguredSprintID: String,
                notificationsEnabled: Bool,
                notificationsInterval: Int,
                notificationsStartTime: Date,
                notificationsEndTime: Date) {
        self.neededVolume = neededVolume
        self.drunkVolume = drunkVolume
        self.lastConfiguredSprintID = lastConfiguredSprintID
        self.notificationsEnabled = notificationsEnabled
        self.notificationsInterval = notificationsInterval
        self.notificationsStartTime = notificationsStartTime
        self.notificationsEndTime = notificationsEndTime
    }
    
    public init(entity: WaterControlEntity) {
        neededVolume = Int(entity.neededVolume)
        drunkVolume = entity.drunkVolumes as? [Date: Int] ?? [:]
        lastConfiguredSprintID = entity.lastConfiguredSprintID ?? ""
        notificationsEnabled = entity.notificationsEnabled
        notificationsInterval = Int(entity.notificationsInterval)
        notificationsStartTime = entity.notificationsStartTime ?? Date()
        notificationsEndTime = entity.notificationsEndTime ?? Date()
    }
}
