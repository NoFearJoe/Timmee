//
//  TasksService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSSet
import class Foundation.NSDate
import class Foundation.NSNumber
import class Foundation.NSPredicate
import class Foundation.NSCompoundPredicate
import class Foundation.NSOrderedSet
import class Foundation.NSSortDescriptor
import class Foundation.DispatchQueue
import class CoreData.NSFetchRequest
import class CoreData.NSManagedObject
import class CoreData.NSManagedObjectContext
import protocol CoreData.NSFetchRequestResult
import Workset

public enum TasksFetchPredicate {
    case none
    case completed(date: Date)
    case notCompleted(date: Date)
}

public protocol TasksProvider: class {
    func createTask() -> TaskEntity?
    func fetchTask(id: String) -> Task?
    func fetchTasks(listID: String, predicate: TasksFetchPredicate) -> [Task]
    func fetchTasks(smartListID: String, predicate: TasksFetchPredicate) -> [Task]
    func searchTasks(by string: String) -> [Task]
    func retrieveList(of task: Task) -> List?
}

public protocol TaskEntitiesProvider: class {
    func fetchTaskEntity(id: String) -> TaskEntity?
}

public protocol TaskEntitiesBackgroundProvider: class {
    func fetchTaskEntityInBackground(id: String) -> TaskEntity?
    func fetchTaskEntitiesToUpdateDueDateInBackground() -> [TaskEntity]
    func fetchTaskEntitiesToUpdateNotificationDateInBackground() -> [TaskEntity]
    func fetchTaskEntitiesInBackground(tasks: [Task]) -> [TaskEntity]
}

public protocol TasksObserverProvider: class {
    func tasksObserver(listID: String) -> CacheObserver<Task>
    func tasksObserver(predicate: NSPredicate?) -> CacheObserver<Task>
    func tasksScope(listID: String) -> CachedEntitiesObserver<TaskEntity, Task>
}

public protocol TaskEntitiesCountProvider: class {
    func tasksCount() -> Int
    func tasksCount(listID: String, predicate: TasksFetchPredicate) -> Int
    func tasksCount(smartListID: String, predicate: TasksFetchPredicate) -> Int
}

public protocol TasksManager: class {
    func addTask(_ task: Task, listID: String, completion: @escaping (TasksService.Error?) -> Void)
    func updateTask(_ task: Task, completion: @escaping (TasksService.Error?) -> Void)
    func updateTask(_ task: Task, listID: String?, completion: @escaping (TasksService.Error?) -> Void)
    func updateTasks(_ tasks: [Task], completion: @escaping (TasksService.Error?) -> Void)
    func updateTasks(_ tasks: [Task], listID: String?, completion: @escaping (TasksService.Error?) -> Void)
    func removeTask(_ task: Task, completion: @escaping (TasksService.Error?) -> Void)
    func removeTasks(_ tasks: [Task], completion: @escaping (TasksService.Error?) -> Void)
    func completeTask(withID id: String, doneDate: Date, completion: @escaping () -> Void)
    func updateTasksDueDates(completion: @escaping () -> Void)
    func updateTasksNotificationDates()
}

public final class TasksService {

    public enum Error: Swift.Error {
        case taskIsAlreadyExist
        case taskIsNotExist
        case taskAddingError
        case taskUpdatingError
        case taskRemovingError
    }
    
    private let listsProvider: ListEntitiesProvider
    private let subtasksProvider: SubtaskEntitiesBackgroundProvider
    private let tagsProvider: TagEntitiesBackgroundProvider
    private let timeTemplatesProvider: TimeTemplateEntitiesBackgroundProvider
    
    public init(listsProvider: ListEntitiesProvider,
                subtasksProvider: SubtaskEntitiesBackgroundProvider,
                tagsProvider: TagEntitiesBackgroundProvider,
                timeTemplatesProvider: TimeTemplateEntitiesBackgroundProvider) {
        self.listsProvider = listsProvider
        self.subtasksProvider = subtasksProvider
        self.tagsProvider = tagsProvider
        self.timeTemplatesProvider = timeTemplatesProvider
    }

}

extension TasksService: TasksManager {

    public func addTask(_ task: Task, listID: String, completion: @escaping (Error?) -> Void) {
        Database.localStorage.write({ (context, save) in
            guard self.fetchTaskEntityInBackground(id: task.id) == nil else {
                DispatchQueue.main.async { completion(.taskIsAlreadyExist) }
                return
            }
            
            if let newTask = self.createTask() {
                newTask.map(from: task)
                newTask.list = self.listsProvider.fetchListEntity(id: listID, context: context)
                newTask.subtasks = NSSet(array: self.retrieveSubtaskEntities(from: task.subtasks,
                                                                             in: context))
                newTask.tags = NSSet(array: self.retrieveTagEntities(from: task.tags,
                                                                     in: context))
                newTask.timeTemplate = self.retrieveTimeTemplateEntity(from: task.timeTemplate,
                                                                       in: context)
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(!isSuccess ? .taskAddingError : nil) }
        }
    }
    
    public func updateTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        updateTask(task, listID: nil, completion: completion)
    }
    
    public func updateTask(_ task: Task, listID: String? = nil, completion: @escaping (Error?) -> Void) {
        updateTasks([task], listID: listID, completion: completion)
    }
    
    public func updateTasks(_ tasks: [Task], completion: @escaping (Error?) -> Void) {
        updateTasks(tasks, listID: nil, completion: completion)
    }
    
    public func updateTasks(_ tasks: [Task], listID: String? = nil, completion: @escaping (Error?) -> Void) {
        guard !tasks.isEmpty else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        Database.localStorage.write({ (context, save) in
            tasks.forEach { task in
                if let taskEntity = self.fetchTaskEntityInBackground(id: task.id) ?? self.createTask() {
                    taskEntity.map(from: task)
                    
                    if let listID = listID {
                        taskEntity.list = self.listsProvider.fetchListEntity(id: listID, context: context)
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
        }) { isSuccess in
            DispatchQueue.main.async { completion(!isSuccess ? .taskUpdatingError : nil) }
        }
    }
    
    public func removeTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        removeTasks([task], completion: completion)
    }
    
    public func removeTasks(_ tasks: [Task], completion: @escaping (Error?) -> Void) {
        guard !tasks.isEmpty else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        Database.localStorage.write({ (context, save) in
            tasks.forEach { task in
                task.attachments.forEach { FilesService(directory: "Attachments").removeFileFromDocuments(withName: $0) }
                
                if let existingTask = self.fetchTaskEntityInBackground(id: task.id) {
                    context.delete(existingTask)
                }
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(!isSuccess ? .taskRemovingError : nil) }
        }
    }
    
    public func completeTask(withID id: String, doneDate: Date, completion: @escaping () -> Void) {
        guard let task = self.fetchTask(id: id) else {
            completion()
            return
        }
        
        task.setDone(true, at: doneDate)
        
        updateTask(task) { _ in
            completion()
        }
    }
    
    public func updateTasksDueDates(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            let tasksToUpdate = self.fetchTaskEntitiesToUpdateDueDateInBackground()
            let updatedTasks = tasksToUpdate.map { entity -> Task in
                let task = Task(entity: entity)
                task.dueDate = task.nextDueDate
                return task
            }
            self.updateTasks(updatedTasks, completion: { _ in completion() })
        }
    }
    
    public func updateTasksNotificationDates() {
        DispatchQueue.global().async {
            let tasksToUpdate = self.fetchTaskEntitiesToUpdateNotificationDateInBackground()
            let updatedTasks = tasksToUpdate.map { entity -> Task in
                let task = Task(entity: entity)
                task.notificationDate = task.nextNotificationDate
                return task
            }
            self.updateTasks(updatedTasks, completion: { _ in })
        }
    }
    
}

// MARK: - Tasks observer

extension TasksService: TasksObserverProvider {
    
    public func tasksObserver(listID: String) -> CacheObserver<Task> {
        var request: FetchRequest<TaskEntity> = TaskEntity.request()
            .sorted(keyPath: \.isDone, ascending: true)
            .sorted(keyPath: \.isImportant, ascending: false)
            .sorted(keyPath: \.inProgress, ascending: false)
            .sorted(keyPath: \.creationDate, ascending: false)
            .batchSize(10)
        
        if SmartListType.isSmartListID(listID) {
            request = request.filtered(predicate: SmartListType(id: listID).fetchPredicate)
        } else {
            request = request.filtered(key: "list.id", value: listID)
        }
        
        let context = Database.localStorage.readContext
        let tasksObserver = CacheObserver<Task>(request: request.nsFetchRequestWithResult,
                                                section: "isDone",
                                                cacheName: nil,
                                                context: context)
        
        tasksObserver.setMapping { entity in
            let taskEntity = entity as! TaskEntity
            return Task(entity: taskEntity)
        }
        
        return tasksObserver
    }
    
    public func tasksObserver(predicate: NSPredicate?) -> CacheObserver<Task> {
        let request = TasksService.allTasksFetchRequest().filtered(predicate: predicate).batchSize(10).nsFetchRequestWithResult
        let context = Database.localStorage.readContext
        let tasksObserver = CacheObserver<Task>(request: request,
                                                section: "list.title",
                                                cacheName: nil,
                                                context: context)
        
        tasksObserver.setMapping { entity in
            let entity = entity as! TaskEntity
            return Task(entity: entity)
        }
        
        return tasksObserver
    }
    
    public func tasksScope(listID: String) -> CachedEntitiesObserver<TaskEntity, Task> {
        var request: FetchRequest<TaskEntity> = TaskEntity.request()
            .sorted(keyPath: \.isImportant, ascending: false)
            .sorted(keyPath: \.inProgress, ascending: false)
            .sorted(keyPath: \.creationDate, ascending: false)
            .batchSize(10)
        
        var filter: ((Task) -> Bool)?
        var doneDate: Date = Date()
        if SmartListType.isSmartListID(listID) {
            let smartListType = SmartListType(id: listID)
            request = request.filtered(predicate: smartListType.fetchPredicate)
            filter = smartListType.filter
            doneDate = SmartList(type: smartListType).defaultDueDate ?? Date()
        } else {
            request = request.filtered(key: "list.id", value: listID)
        }
        
        return CachedEntitiesObserver<TaskEntity, Task>(context: Database.localStorage.readContext,
                                       baseRequest: request.nsFetchRequest,
                                       grouping: { $0.isDone(at: doneDate) || $0.isFinished(at: doneDate) ? "1" : "0" },
                                       mapping: { Task(entity:$0) },
                                       filter: filter)
    }
    
}

// MARK: - Fetch

extension TasksService: TasksProvider {
    
    public func createTask() -> TaskEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchTask(id: String) -> Task? {
        guard let entity = fetchTaskEntity(id: id) else { return nil }
        return Task(entity: entity)
    }
    
    public func fetchTasks(listID: String, predicate: TasksFetchPredicate) -> [Task] {
        switch predicate {
        case .none: return TasksService.tasksFetchRequest(listID: listID).execute().map({ Task(entity: $0) })
        case let .completed(date): return TasksService.tasksFetchRequest(listID: listID).execute().map({ Task(entity: $0) }).filter({ $0.isDone(at: date) })
        case let .notCompleted(date): return TasksService.tasksFetchRequest(listID: listID).execute().map({ Task(entity: $0) }).filter({ !$0.isDone(at: date) })
        }
    }
    
    public func fetchTasks(smartListID: String, predicate: TasksFetchPredicate) -> [Task] {
        switch predicate {
        case .none:
            if let filter = SmartListType(id: smartListID).filter {
                return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter(filter)
            }
            return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:))
        case let .completed(date):
            if let filter = SmartListType(id: smartListID).filter {
                return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter({ filter($0) && $0.isDone(at: date) })
            }
            return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter({ $0.isDone(at: date) })
        case let .notCompleted(date):
            if let filter = SmartListType(id: smartListID).filter {
                return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter({ filter($0) && !$0.isDone(at: date) })
            }
            return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter({ !$0.isDone(at: date) })
        }
    }
    
    public func searchTasks(by string: String) -> [Task] {
        return TasksService.tasksSearchRequest(string: string).execute().map({ Task(entity: $0) })
    }
    
    public func retrieveList(of task: Task) -> List? {
        if let taskEntity = fetchTaskEntity(id: task.id), let listEntity = taskEntity.list {
            return List(listEntity: listEntity)
        }
        return nil
    }
    
}

// MARK: - Fetch entities

extension TasksService: TaskEntitiesProvider {
    
    public func fetchTaskEntity(id: String) -> TaskEntity? {
        return TasksService.taskFetchRequest(id: id).execute().first
    }
    
}

// MARK: - Fetch entities in background

extension TasksService: TaskEntitiesBackgroundProvider {
    
    public func fetchTaskEntityInBackground(id: String) -> TaskEntity? {
        return TasksService.taskFetchRequest(id: id).executeInBackground().first
    }
    
    public func fetchTaskEntitiesToUpdateDueDateInBackground() -> [TaskEntity] {
        return TasksService.tasksToUpdateDueDateFetchRequest().executeInBackground()
    }
    
    public func fetchTaskEntitiesToUpdateNotificationDateInBackground() -> [TaskEntity] {
        return TasksService.tasksToUpdateNotificationDateFetchRequest().executeInBackground()
    }
    
    public func fetchTaskEntitiesInBackground(tasks: [Task]) -> [TaskEntity] {
        return TasksService.taskEntitiesFetchRequest(tasks: tasks).executeInBackground()
    }
    
}

// MARK: - Count entities

extension TasksService: TaskEntitiesCountProvider {
    
    public func tasksCount() -> Int {
        return TasksService.allTasksFetchRequest().count()
    }
    
    public func tasksCount(listID: String, predicate: TasksFetchPredicate) -> Int {
        switch predicate {
        case .none: return TasksService.tasksFetchRequest(listID: listID).count()
        case let .completed(date): return TasksService.tasksFetchRequest(listID: listID).execute().map(Task.init(entity:)).filter({ $0.isDone(at: date) }).count
        case let .notCompleted(date): return TasksService.tasksFetchRequest(listID: listID).execute().map(Task.init(entity:)).filter({ $0.isDone(at: date) }).count
        }
    }
    
    public func tasksCount(smartListID: String, predicate: TasksFetchPredicate) -> Int {
        switch predicate {
        case .none:
            if let filter = SmartListType(id: smartListID).filter {
                return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter(filter).count
            }
            return TasksService.tasksFetchRequest(smartListID: smartListID).count()
        case let .completed(date):
            if let filter = SmartListType(id: smartListID).filter {
                return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter({ filter($0) && $0.isDone(at: date) }).count
            }
            return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter({ $0.isDone(at: date) }).count
        case let .notCompleted(date):
            if let filter = SmartListType(id: smartListID).filter {
                return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter({ filter($0) && !$0.isDone(at: date) }).count
            }
            return TasksService.tasksFetchRequest(smartListID: smartListID).execute().map(Task.init(entity:)).filter({ !$0.isDone(at: date) }).count
        }
    }
    
}

// MARK: - Fetch requests

private extension TasksService {
    
    static func tasksFetchRequest(listID: String) -> FetchRequest<TaskEntity> {
        return TaskEntity.request().filtered(key: "list.id", value: listID)
    }
    
    static func tasksFetchRequest(smartListID: String) -> FetchRequest<TaskEntity> {
        let smartList = SmartList(type: SmartListType(id: smartListID))
        var request: FetchRequest<TaskEntity> = TaskEntity.request()
        
        if let predicate = smartList.tasksFetchPredicate {
            request = request.filtered(predicate: predicate)
        }
        
        return request
    }
    
    static func taskFetchRequest(id: String) -> FetchRequest<TaskEntity> {
        return TaskEntity.request().filtered(key: "id", value: id)
    }
    
    static func tasksSearchRequest(string: String) -> FetchRequest<TaskEntity> {
        return allTasksFetchRequest().filtered(key: "title", contains: string)
    }
    
    static func allTasksFetchRequest() -> FetchRequest<TaskEntity> {
        return TaskEntity.request()
            .sorted(keyPath: \.list?.title, ascending: true)
            .sorted(keyPath: \.isImportant, ascending: false)
            .sorted(keyPath: \.inProgress, ascending: false)
            .sorted(keyPath: \.creationDate, ascending: false)
    }
    
    static func tasksToUpdateDueDateFetchRequest() -> FetchRequest<TaskEntity> {
        let predicate = NSPredicate(format: "dueDate < %@ AND repeatMask != %@",
                                    NSDate(),
                                    RepeatType.never.string)
        return TaskEntity.request().filtered(predicate: predicate)
    }
    
    static func tasksToUpdateNotificationDateFetchRequest() -> FetchRequest<TaskEntity> {
        let predicate = NSPredicate(format: "notificationDate != nil AND notificationDate < %@ AND repeatMask != %@",
                                    NSDate(),
                                    RepeatType.never.string)
        return TaskEntity.request().filtered(predicate: predicate)
    }
    
    static func taskEntitiesFetchRequest(tasks: [Task]) -> FetchRequest<TaskEntity> {
        return TaskEntity.request().filtered(key: "id", in: tasks.map { $0.id })
    }
    
}

private extension TasksService {
    
    func retrieveSubtaskEntities(from subtasks: [Subtask],
                                 in context: NSManagedObjectContext) -> [SubtaskEntity] {
        return subtasks.compactMap { subtask in
            let entity = self.subtasksProvider.fetchSubtaskEntityInBackground(id: subtask.id)
                ?? self.subtasksProvider.createSubtaskEntity()
            entity?.map(from: subtask)
            return entity
        }
    }
    
    func retrieveTagEntities(from tags: [Tag],
                             in context: NSManagedObjectContext) -> [TagEntity] {
        return tags.compactMap { tag in
            let entity = self.tagsProvider.fetchTagEntityInBackground(id: tag.id)
                ?? self.tagsProvider.createTagEntity()
            entity?.map(from: tag)
            return entity
        }
    }
    
    func retrieveTimeTemplateEntity(from template: TimeTemplate?,
                                    in context: NSManagedObjectContext) -> TimeTemplateEntity? {
        guard let template = template else { return nil }
        let entity = self.timeTemplatesProvider.fetchTimeTemplateEntityInBackground(id: template.id)
            ?? self.timeTemplatesProvider.createTimeTemplateEntity()
        entity?.map(from: template)
        return entity
    }
    
}
