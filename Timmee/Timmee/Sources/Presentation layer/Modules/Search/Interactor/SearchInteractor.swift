//
//  SearchInteractor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 07.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.IndexPath
import class Foundation.NSPredicate
import class Foundation.DispatchQueue
import class CoreData.NSFetchRequest
import protocol CoreData.NSFetchRequestResult
import class CoreData.NSManagedObjectContext

protocol SearchInteractorInput: class {
    func search(_ string: String)
    
    func deleteTask(_ task: Task)
    func completeTask(_ task: Task)
    func toggleTaskProgressState(_ task: Task)
    func toggleImportancy(of task: Task)
}

protocol SearchInteractorOutput: class {
    func tasksFetched(count: Int)
    func operationCompleted()
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble)
}

protocol SearchDataSource: class {
    func sectionsCount() -> Int
    func itemsCount(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> Task?
    func sectionTitle(forSectionAt index: Int) -> String?
}

final class SearchInteractor {
    
    weak var output: SearchInteractorOutput!
    
    fileprivate let tasksService = TasksService()
    fileprivate var tasksObserver: CoreDataObserver<Task>!
    
}

extension SearchInteractor: SearchInteractorInput {
    
    func search(_ string: String) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", string.trimmed.lowercased())
        fetchTasks(predicate: predicate)
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
        if task.isDone {
            task.inProgress = false
        }
        
        tasksService.updateTask(task) { [weak self] error in
            DispatchQueue.main.async {
                self?.output.operationCompleted()
            }
        }
    }
    
    func toggleTaskProgressState(_ task: Task) {
        task.inProgress = !task.inProgress
        
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

extension SearchInteractor: SearchDataSource {
    
    func sectionsCount() -> Int {
        return tasksObserver?.numberOfSections() ?? 0
    }
    
    func itemsCount(in section: Int) -> Int {
        return tasksObserver?.numberOfItems(in: section) ?? 0
    }
    
    func item(at indexPath: IndexPath) -> Task? {
        return tasksObserver?.item(at: indexPath)
    }
    
    func sectionTitle(forSectionAt index: Int) -> String? {
        return tasksObserver?.sectionInfo(at: index)?.name
    }
    
}

fileprivate extension SearchInteractor {
    
    func fetchTasks(predicate: NSPredicate?) {
        let request = tasksService.allTasksFetchRequest() as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = predicate
        let context = DefaultStorage.instance.database.readContext
        tasksObserver = CoreDataObserver<Task>(request: request,
                                               section: "list.title",
                                               cacheName: nil,
                                               context: context)
        
        tasksObserver.mapping = { entity in
            let entity = entity as! TaskEntity
            return Task(task: entity)
        }
        
        tasksObserver.onFetchedObjectsCountChange = { [weak self] count in
            self?.output.tasksFetched(count: count)
        }
        
        output.prepareCoreDataObserver(tasksObserver!)
        
        tasksObserver.fetchInitialEntities()
    }
    
}
