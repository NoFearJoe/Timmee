//
//  StagesService.swift
//  TasksKit
//
//  Created by Илья Харабет on 27.04.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import class Foundation.NSPredicate
import class Foundation.DispatchQueue
import class Foundation.NSSortDescriptor
import class CoreData.NSFetchRequest
import class CoreData.NSManagedObjectContext

public protocol StagesProvider: class {
    func fetchStage(id: String) -> Stage?
    func fetchStages(taskID: String) -> [Stage]
}

public protocol StageEntitiesProvider: class {
    func fetchStageEntity(id: String) -> StageEntity?
    func fetchStageEntities(taskID: String) -> [StageEntity]
}

public protocol StageEntitiesBackgroundProvider: class {
    func createStageEntity() -> StageEntity?
    func fetchStageEntityInBackground(id: String) -> StageEntity?
    func fetchStageEntitiesInBackground(taskID: String) -> [StageEntity]
}

public protocol StagesManager: class {
    func addStage(_ stage: Stage, to goal: Goal, completion: (() -> Void)?)
    func updateStage(_ stage: Stage, completion: (() -> Void)?)
    func removeStage(_ stage: Stage, completion: (() -> Void)?)
}

public final class StagesService {
    
    weak var tasksProvider: TaskEntitiesBackgroundProvider!
    weak var goalsProvider: GoalEntitiesBackgroundProvider!
    
}

extension StagesService: StagesManager {
    
    public func addStage(_ stage: Stage, to goal: Goal, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            guard self.fetchStageEntityInBackground(id: stage.id) == nil else {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            if let goalEntity = self.goalsProvider.fetchGoalEntityInBackground(id: goal.id),
                let newStage = self.createStageEntity() {
                newStage.map(from: stage)
                newStage.goal = goalEntity
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
    public func updateStage(_ stage: Stage, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingStage = self.fetchStageEntityInBackground(id: stage.id) {
                existingStage.map(from: stage)
            } else if let newStage = self.createStageEntity() {
                newStage.map(from: stage)
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
    public func removeStage(_ stage: Stage, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingStage = self.fetchStageEntityInBackground(id: stage.id) {
                context.delete(existingStage)
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }

}

// MARK: - Fetch

extension StagesService: StagesProvider {
    
    public func fetchStage(id: String) -> Stage? {
        guard let entity = self.fetchStageEntity(id: id) else { return nil }
        return Stage(entity: entity)
    }
    
    public func fetchStages(taskID: String) -> [Stage] {
        let entities = self.fetchStageEntities(taskID: taskID)
        return entities.map { Stage(entity: $0) }
    }
    
}

// MARK: - Fetch entities

extension StagesService: StageEntitiesProvider {
    
    public func fetchStageEntity(id: String) -> StageEntity? {
        return StagesService.stageFetchRequest(id: id).execute().first
    }
    
    public func fetchStageEntities(taskID: String) -> [StageEntity] {
        return StagesService.stagesFetchRequest(taskID: taskID).execute()
    }
    
}

// MARK: - Fetch entities in background

extension StagesService: StageEntitiesBackgroundProvider {
    
    public func createStageEntity() -> StageEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchStageEntityInBackground(id: String) -> StageEntity? {
        return StagesService.stageFetchRequest(id: id).executeInBackground().first
    }
    
    public func fetchStageEntitiesInBackground(taskID: String) -> [StageEntity] {
        return StagesService.stagesFetchRequest(taskID: taskID).executeInBackground()
    }
    
}

// MARK: - Fetch reqeusts

private extension StagesService {

    /// Запрос подзадачи по id
    static func stageFetchRequest(id: String) -> FetchRequest<StageEntity> {
        return StageEntity.request().filtered(key: "id", value: id)
    }
    
    /// Запрос подзадач для задачи с определенным id
    static func stagesFetchRequest(taskID: String) -> FetchRequest<StageEntity> {
        return StageEntity.request().filtered(key: "task.id", value: taskID).sorted(keyPath: \.sortPosition, ascending: true)
    }

}

