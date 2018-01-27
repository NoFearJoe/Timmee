//
//  TableListRepresentationInteractor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.IndexPath
import class SugarRecord.CoreDataDefaultStorage
import class CoreData.NSManagedObjectContext
import class CoreData.NSFetchRequest
import protocol CoreData.NSFetchRequestResult
import class Foundation.NSPredicate
import class CoreData.NSSortDescriptor
import class Foundation.DispatchQueue

protocol TableListRepresentationInteractorInput: class {
    func fetchTasks(by listID: String?)
    func addShortTask(with title: String, dueDate: Date?, inProgress: Bool, isImportant: Bool)
    func deleteTask(_ task: Task)
    func deleteTasks(_ tasks: [Task])
    func completeTask(_ task: Task)
    func completeTasks(_ tasks: [Task])
    func toggleTaskProgressState(_ task: Task)
    func toggleTasksProgressState(_ tasks: [Task])
    func toggleImportancy(of task: Task)
    func moveTasks(_ tasks: [Task], toList list: List)
        
    func item(at index: Int, in section: Int) -> Task?
    func sectionInfo(forSectionWithName name: String) -> (name: String, numberOfItems: Int)?
}

protocol TableListRepresentationInteractorOutput: class {
    func initialTasksFetched()
    func tasksCountChanged(count: Int)
        
    func operationCompleted()
    func groupEditingOperationCompleted()
    
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble)
}

final class TableListRepresentationInteractor {

    weak var output: TableListRepresentationInteractorOutput!
    
    fileprivate let tasksService = TasksService()
    fileprivate let taskSchedulerService = TaskSchedulerService()
    
    fileprivate var tasksObserver: CoreDataObserver<Task>!
    fileprivate var lastListID: String?
    
}

extension TableListRepresentationInteractor: TableListRepresentationInteractorInput {

    func fetchTasks(by listID: String?) {
        if let listID = listID {
            if tasksObserver == nil || lastListID != listID {
                lastListID = listID
                setupTasksObserver(listID: listID)
            }
        } else {
            lastListID = nil
        }
    }
    
    func addShortTask(with title: String, dueDate: Date?, inProgress: Bool, isImportant: Bool) {
        guard let listID = lastListID else { return }
        
        let task = Task(id: RandomStringGenerator.randomString(length: 24),
                        title: title)
        
        if let dueDate = dueDate {
            task.dueDate = dueDate
        }
        task.inProgress = inProgress
        task.isImportant = isImportant
        
        tasksService.addTask(task, listID: listID, completion: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.operationCompleted()
            }
        })
    }
    
    func deleteTask(_ task: Task) {
        taskSchedulerService.removeNotifications(for: task)
        tasksService.removeTask(task, completion: { [weak self] error in
            DispatchQueue.main.async {
                
                self?.output.operationCompleted()
            }
        })
    }
    
    func deleteTasks(_ tasks: [Task]) {
        tasks.forEach { taskSchedulerService.removeNotifications(for: $0) }
        tasksService.removeTasks(tasks) { [weak self] error in
            DispatchQueue.main.async {
                self?.output.operationCompleted()
            }
        }
    }
    
    func completeTask(_ task: Task) {
        task.isDone = !task.isDone
        if task.isDone {
            task.inProgress = false
        }
        
        tasksService.updateTask(task) { [weak self] error in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                
                if task.isDone {
                    self.taskSchedulerService.removeNotifications(for: task)
                } else {
                    let listTitle = self.tasksService.retrieveList(of: task)?.title ?? "all_tasks".localized
                    self.taskSchedulerService.scheduleTask(task, listTitle: listTitle)
                }
                
                self.output.operationCompleted()
            }
        }
    }
    
    func completeTasks(_ tasks: [Task]) {
        let willDone = tasks.contains(where: { !$0.isDone })
        tasks.forEach {
            $0.isDone = willDone
            if $0.isDone {
                $0.inProgress = false
            }
        }
        
        tasksService.updateTasks(tasks) { [weak self] error in
            DispatchQueue.main.async {
                guard let `self` = self else { return }

                tasks.forEach { task in
                    if task.isDone {
                        self.taskSchedulerService.removeNotifications(for: task)
                    } else {
                        let listTitle = self.tasksService.retrieveList(of: task)?.title ?? "all_tasks".localized
                        self.taskSchedulerService.scheduleTask(task, listTitle: listTitle)
                    }
                }
                self.output.groupEditingOperationCompleted()
            }
        }
    }
    
    func toggleTaskProgressState(_ task: Task) {
        task.inProgress = !task.inProgress
        
        tasksService.updateTask(task) { [weak self] error in
            DispatchQueue.main.async {
                self?.taskSchedulerService.removeNotifications(for: task)
                self?.output.operationCompleted()
            }
        }
    }
    
    func toggleTasksProgressState(_ tasks: [Task]) {
        let willInProgress = tasks.contains(where: { !$0.inProgress })
        tasks.forEach { $0.inProgress = willInProgress }
        
        tasksService.updateTasks(tasks) { [weak self] error in
            DispatchQueue.main.async {
                tasks.forEach { self?.taskSchedulerService.removeNotifications(for: $0) }
                self?.output.groupEditingOperationCompleted()
            }
        }
    }
    
    func toggleImportancy(of task: Task) {
        task.isImportant = !task.isImportant
        
        tasksService.updateTask(task) { [weak self] error in
            DispatchQueue.main.async {
                self?.output.operationCompleted()
            }
        }
    }
    
    func moveTasks(_ tasks: [Task], toList list: List) {
        tasksService.updateTasks(tasks, listID: list.id) { [weak self] error in
            DispatchQueue.main.async {
                self?.output.groupEditingOperationCompleted()
            }
        }
    }

}

extension TableListRepresentationInteractor: TableListRepresentationViewDataSource {

    func sectionsCount() -> Int {
        return tasksObserver?.numberOfSections() ?? 0
    }
    
    func itemsCount(in section: Int) -> Int {
        return tasksObserver?.numberOfItems(in: section) ?? 0
    }
    
    func item(at index: Int, in section: Int) -> Task? {
        let indexPath = IndexPath(row: index, section: section)
        return tasksObserver?.item(at: indexPath)
    }
    
    func sectionInfo(forSectionAt index: Int) -> (name: String, numberOfItems: Int)? {
        return tasksObserver?.sectionInfo(at: index)
    }
    
    func sectionInfo(forSectionWithName name: String) -> (name: String, numberOfItems: Int)? {
        return tasksObserver?.sectionInfo(with: name)
    }
    
    func totalObjectsCount() -> Int {
        return tasksObserver?.totalObjectsCount() ?? 0
    }

}

fileprivate extension TableListRepresentationInteractor {
    
    func setupTasksObserver(listID: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TaskEntity.entityName)
        if SmartListType.isSmartListID(listID) {
            let smartList = SmartList(type: SmartListType(id: listID))
            if let predicate = smartList.tasksFetchPredicate {
                request.predicate = predicate
            }
        } else {
            request.predicate = NSPredicate(format: "list.id == %@", listID)
        }
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "isDone", ascending: true),
            NSSortDescriptor(key: "isImportant", ascending: false),
            NSSortDescriptor(key: "inProgress", ascending: false),
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        request.fetchBatchSize = 20
        
        let context = DefaultStorage.instance.mainContext
        tasksObserver = CoreDataObserver(request: request,
                                         section: "isDone",
                                         cacheName: "tasks\(listID)",
                                         context: context)
        
        tasksObserver.mapping = { entity in
            let taskEntity = entity as! TaskEntity
            return Task(task: taskEntity)
        }
        tasksObserver.onFetchedObjectsCountChange = { [weak self] count in
            self?.output.tasksCountChanged(count: count)
        }
        tasksObserver.onInitialFetch = { [weak self] in
            self?.output.initialTasksFetched()
        }
        
        output.prepareCoreDataObserver(tasksObserver)
        
        tasksObserver.fetchInitialEntities()
    }

}
