//
//  WaterControlEntity+Mapping.swift
//  TasksKit
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class Foundation.NSArray

public extension WaterControlEntity {
    
    public func map(from waterControl: WaterControl) {
        neededVolume = Int32(waterControl.neededVolume)
        drunkVolumes = waterControl.drunkVolume as NSDictionary
        lastConfiguredSprintID = waterControl.lastConfiguredSprintID
        notificationsEnabled = waterControl.notificationsEnabled
        notificationsInterval = Int16(waterControl.notificationsInterval)
        notificationsStartTime = waterControl.notificationsStartTime
        notificationsEndTime = waterControl.notificationsEndTime
    }
    
}
