//
//  WaterControl.swift
//  TasksKit
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.Date

public final class WaterControl {
    public static let defaultID: String = "water_control"
    
    public var id: String
    public var sprintID: String
    public var neededVolume: Int
    public var drunkVolume: [Date: Int]
    public var notificationsEnabled: Bool
    public var notificationsInterval: Int
    public var notificationsStartTime: Date
    public var notificationsEndTime: Date
    public var weight: Double = 65
    public var activity: Activity = .medium
    public var gender: Gender = .male
    
    public init(id: String,
                neededVolume: Int,
                drunkVolume: [Date: Int],
                sprintID: String,
                notificationsEnabled: Bool,
                notificationsInterval: Int,
                notificationsStartTime: Date,
                notificationsEndTime: Date) {
        self.id = id
        self.sprintID = sprintID
        self.neededVolume = neededVolume
        self.drunkVolume = drunkVolume
        self.notificationsEnabled = notificationsEnabled
        self.notificationsInterval = notificationsInterval
        self.notificationsStartTime = notificationsStartTime
        self.notificationsEndTime = notificationsEndTime
    }
    
    public init(entity: WaterControlEntity) {
        id = entity.id ?? WaterControl.defaultID
        sprintID = entity.sprint?.id ?? ""
        neededVolume = Int(entity.neededVolume)
        drunkVolume = entity.drunkVolumes as? [Date: Int] ?? [:]
        notificationsEnabled = entity.notificationsEnabled
        notificationsInterval = Int(entity.notificationsInterval)
        notificationsStartTime = entity.notificationsStartTime ?? Date()
        notificationsEndTime = entity.notificationsEndTime ?? Date()
        weight = entity.weight
        activity = Activity(rawValue: Int(entity.activity)) ?? .medium
        gender = Gender(rawValue: Int(entity.gender)) ?? .male
    }
}
