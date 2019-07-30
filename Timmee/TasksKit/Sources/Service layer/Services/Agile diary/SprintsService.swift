//
//  SprintsService.swift
//  TasksKit
//
//  Created by i.kharabet on 16.10.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Workset
import class Foundation.NSSet
import class Foundation.NSSortDescriptor
import class CoreData.NSPredicate
import class CoreData.NSFetchRequest
import class CoreData.NSManagedObjectContext
import class CoreData.NSCompoundPredicate

public protocol SprintsProvider: class {
    func fetchSprint(id: String) -> Sprint?
    func fetchSprints() -> [Sprint]
}

public protocol SprintEntitiesProvider: class {
    func createSprintEntity() -> SprintEntity?
    func fetchSprintEntities() -> [SprintEntity]
    func fetchSprintEntitiesInBackground() -> [SprintEntity]
    func fetchSprintEntity(id: String) -> SprintEntity?
    func fetchSprintEntity(id: String, context: NSManagedObjectContext) -> SprintEntity?
}

public protocol SprintsObserverProvider: class {
    func sprintsObserver() -> CacheObserver<Sprint>
}

public protocol SprintsManager: class {
    func createOrUpdateSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void)
    func removeSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void)
}

public final class SprintsService {}

extension SprintsService: SprintsProvider {
    
    public func fetchSprint(id: String) -> Sprint? {
        return fetchSprintEntity(id: id).map { Sprint(sprintEntity: $0) }
    }
    
    public func fetchSprints() -> [Sprint] {
        return fetchSprintEntities().map { Sprint(sprintEntity: $0) }
    }
    
}

extension SprintsService: SprintsManager {
    
    public func createOrUpdateSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void) {
        Database.localStorage.write({ context, save in
            if let existingSprint = self.fetchSprintEntity(id: sprint.id, context: context) {
                existingSprint.map(from: sprint)
            } else if let newSprint = self.createSprintEntity() {
                newSprint.map(from: sprint)
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
    public func removeSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void) {
        Database.localStorage.write({ context, save in
            guard let existingSprint = self.fetchSprintEntity(id: sprint.id, context: context) else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            context.delete(existingSprint)
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
}

extension SprintsService: SprintsObserverProvider {
    
    public func sprintsObserver() -> CacheObserver<Sprint> {
        let observer: CacheObserver<Sprint>
        observer = CacheObserver(request: SprintsService.sprintsFetchRequest().sorted(keyPath: \SprintEntity.startDate, ascending: false).nsFetchRequestWithResult,
                                 section: nil,
                                 cacheName: nil,
                                 context: Database.localStorage.readContext)
        observer.setSectionOffset(0)
        return observer
    }
    
}

extension SprintsService: SprintEntitiesProvider {
    
    public func createSprintEntity() -> SprintEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchSprintEntities() -> [SprintEntity] {
        return SprintsService.sprintsFetchRequest().execute()
    }
    
    public func fetchSprintEntitiesInBackground() -> [SprintEntity] {
        return SprintsService.sprintsFetchRequest().executeInBackground()
    }
    
    public func fetchSprintEntity(id: String) -> SprintEntity? {
        return SprintsService.sprintFetchRequest(id: id).execute().first
    }
    
    public func fetchSprintEntity(id: String, context: NSManagedObjectContext) -> SprintEntity? {
        return SprintsService.sprintFetchRequest(id: id).execute(context: context).first
    }
    
}

private extension SprintsService {
    
    /// Запрос всех спринтов
    static func sprintsFetchRequest() -> FetchRequest<SprintEntity> {
        return SprintEntity.request().sorted(keyPath: \.startDate, ascending: false)
    }
    
    /// Запрос спринта по id
    static func sprintFetchRequest(id: String) -> FetchRequest<SprintEntity> {
        return SprintEntity.request().filtered(key: "id", value: id)
    }
    
}
