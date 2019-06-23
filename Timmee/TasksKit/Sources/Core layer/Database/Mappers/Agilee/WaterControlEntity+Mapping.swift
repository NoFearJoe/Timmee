//
//  WaterControlEntity+Mapping.swift
//  TasksKit
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class Foundation.NSArray

public extension WaterControlEntity {
    
    func map(from waterControl: WaterControl) {
        id = waterControl.id
        neededVolume = Int32(waterControl.neededVolume)
        drunkVolumes = waterControl.drunkVolume as NSDictionary
        notificationsEnabled = waterControl.notificationsEnabled
        notificationsInterval = Int16(waterControl.notificationsInterval)
        notificationsStartTime = waterControl.notificationsStartTime
        notificationsEndTime = waterControl.notificationsEndTime
    }
    
}

extension WaterControlEntity: IdentifiableEntity, ModifiableEntity, SyncableEntity, ChildEntity {
    public var parent: IdentifiableEntity? {
        return sprint
    }
}
