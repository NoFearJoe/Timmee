//
//  TasksService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class CoreData.NSFetchRequest
import class CoreData.NSManagedObject
import protocol CoreData.NSFetchRequestResult
import class CoreData.NSManagedObjectContext
import struct SugarRecord.FetchRequest
import class SugarRecord.CoreDataDefaultStorage
import protocol SugarRecord.Context
import class Foundation.NSSet
import class Foundation.NSPredicate
import class Foundation.NSOrderedSet
import class Foundation.NSSortDescriptor

final class TasksService {

    enum Error: Swift.Error {
        case taskIsAlreadyExist
        case taskIsNotExist
        case taskAddingError
        case taskUpdatingError
        case taskRemovingError
    }
    
    func tasksFetchRequest(listID: String) -> NSFetchRequest<TaskEntity> {
        let request = NSFetchRequest<TaskEntity>(entityName: TaskEntity.entityName)
        request.predicate = NSPredicate(format: "list.id == %@", listID)
        request.sortDescriptors = [NSSortDescriptor(key: "isDone", ascending: true)]
        return request
    }
    
    func tasksFetchRequest(smartListID: String) -> NSFetchRequest<TaskEntity> {
        let smartList = SmartList(type: SmartListType(id: smartListID))
        let request = NSFetchRequest<TaskEntity>(entityName: TaskEntity.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "isDone", ascending: true)]
        
        if let predicate = smartList.tasksFetchPredicate {
            request.predicate = predicate
        }
        
        return request
    }
    
    func allTasksFetchRequest() -> NSFetchRequest<TaskEntity> {
        let request = NSFetchRequest<TaskEntity>(entityName: TaskEntity.entityName)
//        request.predicate = NSPredicate(format: "list == nil")
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "list.title", ascending: false),
            NSSortDescriptor(key: "isDone", ascending: true),
            NSSortDescriptor(key: "isImportant", ascending: false),
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        return request
//        let entities = fetchTaskEntities(with: request)
//        return entities.map({ Task(task: $0) })
    }

}

extension TasksService {
    
    func fetchTasks(listID: String) -> [Task] {
        let entities = fetchTaskEntities(listID: listID)
        return entities.map({ Task(task: $0) })
    }
    
    func fetchTasks(smartListID: String) -> [Task] {
        let entities = fetchTaskEntities(smartListID: smartListID)
        return entities.map({ Task(task: $0) })
    }
    
    func fetchTaskEntities(with request: NSFetchRequest<TaskEntity>) -> [TaskEntity] {
        return (try? (DefaultStorage.instance.storage.mainContext as! NSManagedObjectContext).fetch(request)) ?? []
    }
    
    func fetchTaskEntities(listID: String) -> [TaskEntity] {
        return fetchTaskEntities(with: tasksFetchRequest(listID: listID))
    }
    
    func fetchTaskEntities(smartListID: String) -> [TaskEntity] {
        return fetchTaskEntities(with: tasksFetchRequest(smartListID: smartListID))
    }
    
    static func taskFetchRequest(with id: String) -> FetchRequest<TaskEntity> {
        return FetchRequest<TaskEntity>().filtered(with: "id", equalTo: id)
    }

}

extension TasksService {

    func addTask(_ task: Task, listID: String, completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            guard context.fetchTask(id: task.id) == nil else {
                completion(.taskIsAlreadyExist)
                return
            }
            
            if let newTask = context.createTask() {
                newTask.map(from: task)
                newTask.list = context.fetchList(id: listID)
                newTask.subtasks = NSOrderedSet(array: self.retrieveSubtaskEntities(from: task.subtasks,
                                                                                    in: context))
                save()
            }
        }) { error in
            completion(error != nil ?.taskAddingError : nil)
        }
    }
    
    func updateTask(_ task: Task, listID: String? = nil, completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            if let existingTask = context.fetchTask(id: task.id) {
                existingTask.map(from: task)
                if let listID = listID {
                    existingTask.list = context.fetchList(id: listID)
                }
                existingTask.subtasks = NSOrderedSet(array: self.retrieveSubtaskEntities(from: task.subtasks,
                                                                                         in: context))
                existingTask.tags = NSSet(array: self.retrieveTagEntities(from: task.tags,
                                                                          in: context))
                
                save()
            } else if let newTask = context.createTask() {
                newTask.map(from: task)
                if let listID = listID {
                    newTask.list = context.fetchList(id: listID)
                }
                newTask.subtasks = NSOrderedSet(array: self.retrieveSubtaskEntities(from: task.subtasks,
                                                                                    in: context))
                newTask.tags = NSSet(array: self.retrieveTagEntities(from: task.tags,
                                                                     in: context))
                
                save()
            } else {
                completion(.taskUpdatingError)
            }
        }) { error in
            completion(error != nil ? .taskUpdatingError : nil)
        }
    }
    
    func removeTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            if let existingTask = context.fetchTask(id: task.id) {
                try? context.remove(existingTask)
                save()
            } else {
                completion(.taskIsNotExist)
            }
        }) { error in
            completion(error != nil ?.taskRemovingError : nil)
        }
    }

}

fileprivate extension TasksService {

    func retrieveSubtaskEntities(from subtasks: [Subtask],
                                 in context: Context) -> [SubtaskEntity] {
        return subtasks.flatMap { subtask in
            let entity = context.fetchSubtask(id: subtask.id) ?? context.createSubtask()
            entity?.map(from: subtask)
            return entity
        }
    }
    
    func retrieveTagEntities(from tags: [Tag],
                             in context: Context) -> [TagEntity] {
        return tags.flatMap { tag in
            let entity = context.fetchTag(id: tag.id) ?? context.createTag()
            entity?.map(from: tag)
            return entity
        }
    }

}

extension Context {

    func fetchTask(id: String) -> TaskEntity? {
        return (try? fetch(TasksService.taskFetchRequest(with: id)))?.first
    }
    
    func createTask() -> TaskEntity? {
        return try? create()
    }

}
