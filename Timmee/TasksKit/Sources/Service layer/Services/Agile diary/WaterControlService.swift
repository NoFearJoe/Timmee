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

public protocol WaterControlProvider: AnyObject {
    func createWaterControl() -> WaterControl
    func fetchWaterControl(id: String) -> WaterControl?
    func fetchWaterControl(sprintID: String) -> WaterControl?
}

public protocol WaterControlEntityBackgroundProvider: AnyObject {
    func createWaterControlEntity(context: NSManagedObjectContext) -> WaterControlEntity?
    func fetchWaterControlEntityInBakground(sprintID: String) -> WaterControlEntity?
}

public protocol WaterControlManager: AnyObject {
    func createOrUpdateWaterControl(_ waterControl: WaterControl, completion: (() -> Void)?)
    func removeWaterControl(sprintID: String, completion: (() -> Void)?)
}

public protocol WaterControlMigrationManager: AnyObject {
    func performMigration(completion: (() -> Void)?)
}

public final class WaterControlService {
    
    private let sprintsProvider: SprintEntitiesProvider
    
    init(sprintsProvider: SprintEntitiesProvider) {
        self.sprintsProvider = sprintsProvider
    }
    
}

extension WaterControlService: WaterControlProvider {
    
    public func createWaterControl() -> WaterControl {
        return WaterControl(id: RandomStringGenerator.randomString(length: 16),
                            neededVolume: 0,
                            drunkVolume: [:],
                            sprintID: "",
                            notificationsEnabled: false,
                            notificationsInterval: 2,
                            notificationsStartTime: Date(),
                            notificationsEndTime: Date())
    }
    
    public func fetchWaterControl(id: String) -> WaterControl? {
        return WaterControlService.waterControlEntityFetchRequest(id: id).execute().map { WaterControl(entity: $0) }.first
    }
    
    public func fetchWaterControl(sprintID: String) -> WaterControl? {
        return WaterControlService.waterControlEntityFetchRequest(sprintID: sprintID).execute().map { WaterControl(entity: $0) }.first
    }
    
    private func fetchWaterControlV1() -> WaterControl? {
        return WaterControlService.waterControlEntityFetchRequestV1().execute().map { WaterControl(entity: $0) }.first
    }
    
}

extension WaterControlService: WaterControlManager {
    
    public func createOrUpdateWaterControl(_ waterControl: WaterControl, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            let sprint = self.sprintsProvider.fetchSprintEntity(id: waterControl.sprintID, context: context)
            if let existingWaterControl = self.fetchWaterControlEntityInBakground(sprintID: waterControl.sprintID) {
                existingWaterControl.map(from: waterControl)
                existingWaterControl.sprint = sprint
                save()
            } else if let newWaterControl = self.createWaterControlEntity(context: context) {
                newWaterControl.map(from: waterControl)
                newWaterControl.sprint = sprint
                save()
            } else {
                DispatchQueue.main.async { completion?() }
            }
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
    public func removeWaterControl(sprintID: String, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let waterControl = self.fetchWaterControlEntityInBakground(sprintID: sprintID) {
                context.delete(waterControl)
                save()
            } else {
                DispatchQueue.main.async { completion?() }
            }
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
    private func removeWaterControlV1(completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let waterControl = self.fetchWaterControlEntityInBakgroundV1() {
                context.delete(waterControl)
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
    
    public func createWaterControlEntity(context: NSManagedObjectContext) -> WaterControlEntity? {
        return try? context.create()
    }
    
    public func fetchWaterControlEntityInBakground(sprintID: String) -> WaterControlEntity? {
        return WaterControlService.waterControlEntityFetchRequest(sprintID: sprintID).executeInBackground().first
    }
    
    public func fetchWaterControlEntityInBakgroundV1() -> WaterControlEntity? {
        return WaterControlService.waterControlEntityFetchRequestV1().executeInBackground().first
    }
    
}

extension WaterControlService: WaterControlMigrationManager {
    
    public func performMigration(completion: (() -> Void)?) {
        guard let waterControlV1 = fetchWaterControlEntityInBakgroundV1() else {
            completion?()
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let sprints = sprintsProvider.fetchSprintEntitiesInBackground()
        sprints.forEach { sprint in
            let newWaterControl = WaterControl(entity: waterControlV1)
            newWaterControl.id = RandomStringGenerator.randomString(length: 16)
            newWaterControl.sprintID = sprint.id ?? ""
            
            dispatchGroup.enter()
            createOrUpdateWaterControl(newWaterControl, completion: {
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            self.removeWaterControlV1 {
                completion?()
            }
        }
    }
    
}

private extension WaterControlService {
    
    static func waterControlEntityFetchRequest(id: String) -> FetchRequest<WaterControlEntity> {
        return WaterControlEntity.request().filtered(key: "id", value: id).limited(value: 1)
    }
    
    static func waterControlEntityFetchRequest(sprintID: String) -> FetchRequest<WaterControlEntity> {
        return WaterControlEntity.request().filtered(key: "sprint.id", value: sprintID).limited(value: 1)
    }
    
    // Запрос на получение WaterControlEntity первой версии (без id)
    static func waterControlEntityFetchRequestV1() -> FetchRequest<WaterControlEntity> {
        return WaterControlEntity.request().filteredNil(key: "id").limited(value: 1)
    }
    
}
