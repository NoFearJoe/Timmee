//
//  WaterControlService.swift
//  TasksKit
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Workset
import struct Foundation.Date
import class Foundation.NSPredicate
import class Foundation.NSSortDescriptor
import class Foundation.DispatchQueue
import class CoreData.NSManagedObjectContext
import class CoreData.NSFetchRequest

public protocol WaterControlProvider: class {
    func createWaterControl() -> WaterControl
    func fetchWaterControl() -> WaterControl?
}

public protocol WaterControlEntityBackgroundProvider: class {
    func createWaterControlEntity() -> WaterControlEntity?
    func fetchWaterControlEntityInBakground() -> WaterControlEntity?
}

public protocol WaterControlManager: class {
    func createOrUpdateWaterControl(_ waterControl: WaterControl, completion: (() -> Void)?)
}

public final class WaterControlService {}

extension WaterControlService: WaterControlProvider {
    
    public func createWaterControl() -> WaterControl {
        return WaterControl(neededVolume: 0,
                            drunkVolume: [],
                            lastConfiguredSprintID: "",
                            notificationsEnabled: false,
                            notificationsInterval: 2,
                            notificationsStartTime: Date(),
                            notificationsEndTime: Date())
    }
    
    public func fetchWaterControl() -> WaterControl? {
        return WaterControlService.waterControlEntityFetchRequest().execute().map { WaterControl(entity: $0) }.first
    }
    
}

extension WaterControlService: WaterControlManager {
    
    public func createOrUpdateWaterControl(_ waterControl: WaterControl, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingWaterControl = self.fetchWaterControlEntityInBakground() {
                existingWaterControl.map(from: waterControl)
                save()
            } else if let newWaterControl = self.createWaterControlEntity() {
                newWaterControl.map(from: waterControl)
                save()
            } else {
                DispatchQueue.main.async { completion?() }
            }
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
}

extension WaterControlService: WaterControlEntityBackgroundProvider {
    
    public func createWaterControlEntity() -> WaterControlEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchWaterControlEntityInBakground() -> WaterControlEntity? {
        return WaterControlService.waterControlEntityFetchRequest().executeInBackground().first
    }
    
}

private extension WaterControlService {
    
    static func waterControlEntityFetchRequest() -> FetchRequest<WaterControlEntity> {
        return WaterControlEntity.request().limited(value: 1)
    }
    
}
