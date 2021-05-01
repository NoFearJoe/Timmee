//
//  SubtasksService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSPredicate
import class Foundation.DispatchQueue
import class Foundation.NSSortDescriptor
import class CoreData.NSFetchRequest
import class CoreData.NSManagedObjectContext

public protocol SubtasksProvider: class {
    func fetchSubtask(id: String) -> Subtask?
    func fetchSubtasks(taskID: String) -> [Subtask]
}

public protocol SubtaskEntitiesProvider: class {
    func fetchSubtaskEntity(id: String) -> SubtaskEntity?
    func fetchSubtaskEntities(taskID: String) -> [SubtaskEntity]
}

public protocol SubtaskEntitiesBackgroundProvider: class {
    func createSubtaskEntity() -> SubtaskEntity?
    func fetchSubtaskEntityInBackground(id: String) -> SubtaskEntity?
    func fetchSubtaskEntitiesInBackground(taskID: String) -> [SubtaskEntity]
}

public protocol SubtasksManager: class {
    func addSubtask(_ subtask: Subtask, to task: Task, completion: (() -> Void)?)
    func updateSubtask(_ subtask: Subtask, completion: (() -> Void)?)
    func removeSubtask(_ subtask: Subtask, completion: (() -> Void)?)
}

public final class SubtasksService {
    
    weak var tasksProvider: TaskEntitiesBackgroundProvider!
    weak var goalsProvider: GoalEntitiesBackgroundProvider!
    
}

extension SubtasksService: SubtasksManager {

    public func addSubtask(_ subtask: Subtask, to task: Task, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            guard self.fetchSubtaskEntityInBackground(id: subtask.id) == nil else {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            if let task = self.tasksProvider.fetchTaskEntityInBackground(id: task.id),
                let newSubtask = self.createSubtaskEntity() {
                newSubtask.map(from: subtask)
                newSubtask.task = task
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
    public func updateSubtask(_ subtask: Subtask, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingSubtask = self.fetchSubtaskEntityInBackground(id: subtask.id) {
                existingSubtask.map(from: subtask)
            } else if let newSubtask = self.createSubtaskEntity() {
                newSubtask.map(from: subtask)
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
    public func removeSubtask(_ subtask: Subtask, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingSubtask = self.fetchSubtaskEntityInBackground(id: subtask.id) {
                context.delete(existingSubtask)
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }

}

// MARK: - Fetch

extension SubtasksService: SubtasksProvider {
    
    public func fetchSubtask(id: String) -> Subtask? {
        guard let entity = self.fetchSubtaskEntity(id: id) else { return nil }
        return Subtask(entity: entity)
    }
    
    public func fetchSubtasks(taskID: String) -> [Subtask] {
        let entities = self.fetchSubtaskEntities(taskID: taskID)
        return entities.map { Subtask(entity: $0) }
    }
    
}

// MARK: - Fetch entities

extension SubtasksService: SubtaskEntitiesProvider {
    
    public func fetchSubtaskEntity(id: String) -> SubtaskEntity? {
        return SubtasksService.subtaskFetchRequest(id: id).execute().first
    }
    
    public func fetchSubtaskEntities(taskID: String) -> [SubtaskEntity] {
        return SubtasksService.subtasksFetchRequest(taskID: taskID).execute()
    }
    
}

// MARK: - Fetch entities in background

extension SubtasksService: SubtaskEntitiesBackgroundProvider {
    
    public func createSubtaskEntity() -> SubtaskEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchSubtaskEntityInBackground(id: String) -> SubtaskEntity? {
        return SubtasksService.subtaskFetchRequest(id: id).executeInBackground().first
    }
    
    public func fetchSubtaskEntitiesInBackground(taskID: String) -> [SubtaskEntity] {
        return SubtasksService.subtasksFetchRequest(taskID: taskID).executeInBackground()
    }
    
}

// MARK: - Fetch reqeusts

private extension SubtasksService {

    /// Запрос подзадачи по id
    static func subtaskFetchRequest(id: String) -> FetchRequest<SubtaskEntity> {
        return SubtaskEntity.request().filtered(key: "id", value: id)
    }
    
    /// Запрос подзадач для задачи с определенным id
    static func subtasksFetchRequest(taskID: String) -> FetchRequest<SubtaskEntity> {
        return SubtaskEntity.request().filtered(key: "task.id", value: taskID).sorted(keyPath: \.sortPosition, ascending: true)
    }

}
