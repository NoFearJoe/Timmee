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

protocol TableListRepresentationInteractorInput: class {
    func subscribeToTasks(in list: List?)
    
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
    
    func prepareCacheObserver(_ cacheSubscribable: CacheSubscribable)
}

final class TableListRepresentationInteractor {
    
    weak var output: TableListRepresentationInteractorOutput!
    
    private let tasksService = ServicesAssembly.shared.tasksService
    private let taskSchedulerService = TaskSchedulerService()
    
    private var tasksObserver: CacheObserver<Task>!
    private var lastListID: String?
    
}

extension TableListRepresentationInteractor: TableListRepresentationInteractorInput {
    
    func subscribeToTasks(in list: List?) {
        if let listID = list?.id, tasksObserver == nil || lastListID != listID {
            setupTasksObserver(listID: listID)
        }
        lastListID = list?.id
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

extension TableListRepresentationInteractor: TableListRepresentationDataSource {
    
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

private extension TableListRepresentationInteractor {
    
    func setupTasksObserver(listID: String) {
        tasksObserver = tasksService.tasksObserver(listID: listID)
        
        tasksObserver.setActions(
            onInitialFetch: { [weak self] in
                self?.output.initialTasksFetched()
            },
            onItemsCountChange: { [weak self] count in
                self?.output.tasksCountChanged(count: count)
            },
            onItemChange: nil)
        
        output.prepareCacheObserver(tasksObserver)
        
        tasksObserver.fetchInitialEntities()
    }
    
}