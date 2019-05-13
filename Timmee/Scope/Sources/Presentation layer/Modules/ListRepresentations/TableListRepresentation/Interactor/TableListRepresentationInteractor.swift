//
//  TableListRepresentationInteractor.swift
//  Timmee
//
//  Created by i.kharabet on 12.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.IndexPath
import class Foundation.NSPredicate
import class Foundation.DispatchQueue
import class CoreData.NSFetchRequest
import class CoreData.NSSortDescriptor
import class CoreData.NSManagedObjectContext
import protocol CoreData.NSFetchRequestResult

protocol TableListRepresentationInteractorInput: TaskCompletionInteractorTrait {
    func subscribeToTasks(in list: List?)
    
    func deleteTask(_ task: Task)
    func deleteTasks(_ tasks: [Task])
    func toggleTaskProgressState(_ task: Task)
    func toggleTasksProgressState(_ tasks: [Task])
    func toggleImportancy(of task: Task)
    func moveTasks(_ tasks: [Task], toList list: List, completion: (() -> Void)?)
    func deleteCompletedTasks()
    
    func item(at index: Int, in section: Int) -> Task?
    func sectionInfo(forSectionWithName name: String) -> (name: String, numberOfItems: Int)?
}

protocol TableListRepresentationInteractorOutput: class {
    func initialTasksFetched()
    func tasksCountChanged(count: Int)
    func taskChanged(change: CoreDataChange)
    func didNotSubscribeToTasks()
    
    func operationCompleted()
    func groupEditingOperationCompleted()
    
    func prepareCacheObserver(_ cacheSubscribable: CacheSubscribable)
}

final class TableListRepresentationInteractor {
    
    weak var output: TableListRepresentationInteractorOutput!
    
    let tasksService = ServicesAssembly.shared.tasksService
    let taskSchedulerService: TaskSchedulerService = TaskSchedulerService()
    
    private var lastListID: String?
    
    private var observer: CachedEntitiesObserver<TaskEntity, Task>!
    
    private var fetchedTasks: [Task] = []
    
}

extension TableListRepresentationInteractor: TableListRepresentationInteractorInput {
    
    func subscribeToTasks(in list: List?) {
        if let listID = list?.id, observer == nil || lastListID != listID {
            setupScope(listID: listID)
        } else {
            output.didNotSubscribeToTasks()
        }
        lastListID = list?.id
    }
    
    func deleteTask(_ task: Task) {
        taskSchedulerService.removeNotifications(for: task)
        tasksService.removeTask(task, completion: { [weak self] error in
            self?.output.operationCompleted()
        })
    }
    
    func deleteTasks(_ tasks: [Task]) {
        tasks.forEach { taskSchedulerService.removeNotifications(for: $0) }
        tasksService.removeTasks(tasks) { [weak self] error in
            self?.output.operationCompleted()
        }
    }
    
    func deleteCompletedTasks() {
        guard let listID = lastListID else {
            output.operationCompleted()
            return
        }
        
        let tasks: [Task]
        if SmartListType.isSmartListID(listID) {
            let smartList = SmartList(type: SmartListType(id: listID))
            tasks = tasksService.fetchTasks(smartListID: listID, predicate: .completed(date: smartList.defaultDueDate ?? Date()))
        } else {
            tasks = tasksService.fetchTasks(listID: listID, predicate: .completed(date: Date()))
        }
        
        tasksService.removeTasks(tasks) { [weak self] error in
            self?.output.operationCompleted()
        }
    }
    
    func toggleTaskProgressState(_ task: Task) {
        task.inProgress = !task.inProgress
        
        tasksService.updateTask(task) { [weak self] error in
            self?.taskSchedulerService.removeNotifications(for: task)
            self?.output.operationCompleted()
        }
    }
    
    func toggleTasksProgressState(_ tasks: [Task]) {
        let willInProgress = tasks.contains(where: { !$0.inProgress })
        tasks.forEach { $0.inProgress = willInProgress }
        
        tasksService.updateTasks(tasks) { [weak self] error in
            tasks.forEach { self?.taskSchedulerService.removeNotifications(for: $0) }
            self?.output.groupEditingOperationCompleted()
        }
    }
    
    func toggleImportancy(of task: Task) {
        task.isImportant = !task.isImportant
        
        tasksService.updateTask(task) { [weak self] error in
            self?.output.operationCompleted()
        }
    }
    
    func moveTasks(_ tasks: [Task], toList list: List, completion: (() -> Void)?) {
        tasksService.updateTasks(tasks, listID: list.id) { _ in
            completion?()
        }
    }
    
}

extension TableListRepresentationInteractor: TableListRepresentationDataSource {
    
    func sectionsCount() -> Int {
        return observer?.numberOfSections() ?? 0
    }
    
    func itemsCount(in section: Int) -> Int {
        return observer?.numberOfItems(in: section) ?? 0
    }
    
    func item(at index: Int, in section: Int) -> Task? {
        let indexPath = IndexPath(row: index, section: section)
        return observer?.item(at: indexPath)
    }
    
    func sectionInfo(forSectionAt index: Int) -> (name: String, numberOfItems: Int)? {
        return observer?.sectionInfo(at: index)
    }
    
    func sectionInfo(forSectionWithName name: String) -> (name: String, numberOfItems: Int)? {
        return observer?.sectionInfo(with: name)
    }
    
    func totalObjectsCount() -> Int {
        return observer?.totalObjectsCount() ?? 0
    }
    
}

private extension TableListRepresentationInteractor {
    
    func setupScope(listID: String) {
        observer = tasksService.tasksScope(listID: listID)
        observer.setDelegate(CachedEntitiesObserverDelegate<Task>(onInitialFetch: { [weak self] _ in
            self?.output.initialTasksFetched()
        }, onEntitiesCountChange: { [weak self] count in
            self?.output.tasksCountChanged(count: count)
        }, onChanges: { [weak self] changes in
            changes.forEach { self?.output.taskChanged(change: $0) }
        }))
        output.prepareCacheObserver(observer)
        observer.fetch()
    }
    
}
