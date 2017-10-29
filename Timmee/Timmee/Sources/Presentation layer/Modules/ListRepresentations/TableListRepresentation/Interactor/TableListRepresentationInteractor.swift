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
    func addShortTask(with title: String, dueDate: Date?)
    func deleteTask(_ task: Task)
    func completeTask(_ task: Task)
    func toggleImportancy(of task: Task)
    
    func sectionInfo(forSectionWithName name: String) -> (name: String, numberOfItems: Int)?
}

protocol TableListRepresentationInteractorOutput: class {
    func initialTasksFetched()
    func tasksCountChanged(count: Int)
        
    func operationCompleted()
    
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble)
}

final class TableListRepresentationInteractor {

    weak var output: TableListRepresentationInteractorOutput!
    
    fileprivate let tasksService = TasksService()
    
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
    
    func addShortTask(with title: String, dueDate: Date?) {
        guard let listID = lastListID else { return }
        
        let task = Task(id: RandomStringGenerator.randomString(length: 24),
                        title: title)
        
        if let dueDate = dueDate {
            task.dueDate = dueDate
        }
        
        tasksService.addTask(task, listID: listID, completion: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.operationCompleted()
            }
        })
    }
    
    func deleteTask(_ task: Task) {
        tasksService.removeTask(task, completion: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.operationCompleted()
            }
        })
    }
    
    func completeTask(_ task: Task) {
        task.isDone = !task.isDone
        
        tasksService.updateTask(task) { [weak self] error in
            DispatchQueue.main.async {
                self?.output.operationCompleted()
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
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let context = (DefaultStorage.instance.storage as! CoreDataDefaultStorage).mainContext as! NSManagedObjectContext
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
