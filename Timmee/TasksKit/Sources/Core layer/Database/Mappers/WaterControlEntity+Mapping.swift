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
        drunkVolumes = waterControl.drunkVolume as NSArray
        lastConfiguredSprintID = waterControl.lastConfiguredSprintID
    }
    
}
