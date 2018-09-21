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
    public var drunkVolume: [(Date, Int)]
    public var lastConfiguredSprintID: String
    
    public init(neededVolume: Int,
                drunkVolume: [(Date, Int)],
                lastConfiguredSprintID: String) {
        self.neededVolume = neededVolume
        self.drunkVolume = drunkVolume
        self.lastConfiguredSprintID = lastConfiguredSprintID
    }
    
    public init(entity: WaterControlEntity) {
        neededVolume = Int(entity.neededVolume)
        drunkVolume = entity.drunkVolumes as? [(Date, Int)] ?? []
        lastConfiguredSprintID = entity.lastConfiguredSprintID ?? ""
    }
}
