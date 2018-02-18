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
import struct Foundation.Date
import class Foundation.NSSet
import class Foundation.NSPredicate
import class Foundation.NSCompoundPredicate
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
    
    func tasksFetchRequest(listID: String, isDone: Bool) -> NSFetchRequest<TaskEntity> {
        let request = NSFetchRequest<TaskEntity>(entityName: TaskEntity.entityName)
        request.predicate = NSPredicate(format: "list.id == %@ && isDone == %@", listID, isDone as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "isDone", ascending: true)]
        return request
    }
    
    func tasksFetchRequest(smartListID: String, isDone: Bool) -> NSFetchRequest<TaskEntity> {
        let smartList = SmartList(type: SmartListType(id: smartListID))
        let request = NSFetchRequest<TaskEntity>(entityName: TaskEntity.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "isDone", ascending: true)]
        
        if let predicate = smartList.tasksFetchPredicate {
            let donePredicate = NSPredicate(format: "isDone == %@", isDone as CVarArg)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, donePredicate])
        } else {
            request.predicate = NSPredicate(format: "isDone == %@", isDone as CVarArg)
        }
        
        return request
    }
    
    func tasksSearchRequest(string: String) -> NSFetchRequest<TaskEntity> {
        let request = allTasksFetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", string)
        return request
    }
    
    func allTasksFetchRequest() -> NSFetchRequest<TaskEntity> {
        let request = NSFetchRequest<TaskEntity>(entityName: TaskEntity.entityName)
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "list.title", ascending: true),
            NSSortDescriptor(key: "isDone", ascending: true),
            NSSortDescriptor(key: "isImportant", ascending: false),
            NSSortDescriptor(key: "inProgress", ascending: false),
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        return request
    }
    
    func tasksToUpdateDueDateFetchRequest() -> NSFetchRequest<TaskEntity> {
        let request = NSFetchRequest<TaskEntity>(entityName: TaskEntity.entityName)
        
        request.predicate = NSPredicate(format: "dueDate < %@ AND repeatMask != %@",
                                        Date() as CVarArg,
                                        RepeatType.never.string as CVarArg)
        
        return request
    }

}

extension TasksService {
    
    func fetchTasks(listID: String) -> [Task] {
        let entities = fetchTaskEntities(listID: listID)
        return entities.map({ Task(task: $0) })
    }
    
    func fetchActiveTasks(listID: String) -> [Task] {
        let entities = fetchTaskEntities(listID: listID, isDone: false)
        return entities.map({ Task(task: $0) })
    }
    
    func fetchTasks(smartListID: String) -> [Task] {
        let entities = fetchTaskEntities(smartListID: smartListID)
        return entities.map({ Task(task: $0) })
    }
    
    func fetchActiveTasks(smartListID: String) -> [Task] {
        let entities = fetchTaskEntities(smartListID: smartListID, isDone: false)
        return entities.map({ Task(task: $0) })
    }
    
    func searchTasks(by string: String) -> [Task] {
        let entities = fetchTaskEntities(with: tasksSearchRequest(string: string))
        return entities.map({ Task(task: $0) })
    }
    
    func fetchTaskEntities(with request: NSFetchRequest<TaskEntity>) -> [TaskEntity] {
        return (try? (DefaultStorage.instance.storage.mainContext as! NSManagedObjectContext).fetch(request)) ?? []
    }
    
    func fetchTaskEntitiesInBackground(with request: NSFetchRequest<TaskEntity>) -> [TaskEntity] {
        return (try? (DefaultStorage.instance.storage.requestContext() as! NSManagedObjectContext).fetch(request)) ?? []
    }
    
    func fetchTaskEntities(listID: String) -> [TaskEntity] {
        return fetchTaskEntities(with: tasksFetchRequest(listID: listID))
    }
    
    func fetchTaskEntities(smartListID: String) -> [TaskEntity] {
        return fetchTaskEntities(with: tasksFetchRequest(smartListID: smartListID))
    }
    
    func fetchTaskEntities(listID: String, isDone: Bool) -> [TaskEntity] {
        return fetchTaskEntities(with: tasksFetchRequest(listID: listID, isDone: isDone))
    }
    
    func fetchTaskEntities(smartListID: String, isDone: Bool) -> [TaskEntity] {
        return fetchTaskEntities(with: tasksFetchRequest(smartListID: smartListID, isDone: isDone))
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
                newTask.subtasks = NSSet(array: self.retrieveSubtaskEntities(from: task.subtasks,
                                                                             in: context))
                newTask.tags = NSSet(array: self.retrieveTagEntities(from: task.tags,
                                                                     in: context))
                newTask.timeTemplate = self.retrieveTimeTemplateEntity(from: task.timeTemplate,
                                                                          in: context)
                save()
            }
        }) { error in
            completion(error != nil ?.taskAddingError : nil)
        }
    }
    
    func updateTask(_ task: Task, listID: String? = nil, completion: @escaping (Error?) -> Void) {
        updateTasks([task], listID: listID, completion: completion)
    }
    
    func updateTasks(_ tasks: [Task], listID: String? = nil, completion: @escaping (Error?) -> Void) {
        guard !tasks.isEmpty else {
            completion(nil)
            return
        }
        
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            tasks.forEach { task in
                if let taskEntity = context.fetchTask(id: task.id) ?? context.createTask() {
                    taskEntity.map(from: task)
                    
                    if let listID = listID {
                        taskEntity.list = context.fetchList(id: listID)
                    }
                    
                    taskEntity.subtasks = NSSet(array: self.retrieveSubtaskEntities(from: task.subtasks,
                                                                                    in: context))
                    taskEntity.tags = NSSet(array: self.retrieveTagEntities(from: task.tags,
                                                                            in: context))
                    
                    taskEntity.timeTemplate = self.retrieveTimeTemplateEntity(from: task.timeTemplate,
                                                                              in: context)
                }
            }
            save()
        }) { error in
            completion(error != nil ? .taskUpdatingError : nil)
        }
    }
    
    func removeTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        removeTasks([task], completion: completion)
    }
    
    func removeTasks(_ tasks: [Task], completion: @escaping (Error?) -> Void) {
        guard !tasks.isEmpty else {
            completion(nil)
            return
        }
        
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            tasks.forEach { task in
                task.attachments.forEach { FilesService().removeFileFromDocuments(withName: $0) }
                
                if let existingTask = context.fetchTask(id: task.id) {
                    try? context.remove(existingTask)
                }
            }
            save()
        }) { error in
            completion(error != nil ?.taskRemovingError : nil)
        }
    }

}

extension TasksService {
    
    func doneTask(withID id: String, completion: @escaping () -> Void) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            guard let task = context.fetchTask(id: id) else {
                completion()
                return
            }
            
            task.isDone = true
            
            save()
        }) { _ in
            completion()
        }
    }
    
}

extension TasksService {
    
    func retrieveList(of task: Task) -> List? {
        if let taskEntity = DefaultStorage.instance.mainContext.fetchTask(id: task.id), let listEntity = taskEntity.list {
            return List(listEntity: listEntity)
        }
        return nil
    }
    
    func retrieveTask(withID id: String) -> Task? {
        guard let entity = DefaultStorage.instance.mainContext.fetchTask(id: id) else { return nil }
        return Task(task: entity)
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
    
    func retrieveTimeTemplateEntity(from template: TimeTemplate?,
                                      in context: Context) -> TimeTemplateEntity? {
        guard let template = template else { return nil }
        let entity = context.fetchTimeTemplate(id: template.id) ?? context.createTimeTemplate()
        entity?.map(from: template)
        return entity
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
