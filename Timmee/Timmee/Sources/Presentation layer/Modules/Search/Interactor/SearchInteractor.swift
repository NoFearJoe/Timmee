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
    func prepareCacheObserver(_ cacheSubscribable: CacheSubscribable)
}

protocol SearchDataSource: class {
    func sectionsCount() -> Int
    func itemsCount(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> Task?
    func sectionTitle(forSectionAt index: Int) -> String?
}

final class SearchInteractor {
    
    weak var output: SearchInteractorOutput!
    
    private let tasksService = ServicesAssembly.shared.tasksService
    private var tasksObserver: CacheObserver<Task>!
    
}

extension SearchInteractor: SearchInteractorInput {
    
    func search(_ string: String) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", string.trimmed.lowercased())
        fetchTasks(predicate: predicate)
    }
    
    func deleteTask(_ task: Task) {
        tasksService.removeTask(task, completion: { [weak self] error in
            self?.output.operationCompleted()
        })
    }
    
    func completeTask(_ task: Task) {
        task.isDone = !task.isDone
        if task.isDone {
            task.inProgress = false
        }
        
        tasksService.updateTask(task) { [weak self] error in
            self?.output.operationCompleted()
        }
    }
    
    func toggleTaskProgressState(_ task: Task) {
        task.inProgress = !task.inProgress
        
        tasksService.updateTask(task) { [weak self] error in
            self?.output.operationCompleted()
        }
    }
    
    func toggleImportancy(of task: Task) {
        task.isImportant = !task.isImportant
        
        tasksService.updateTask(task) { [weak self] error in
            self?.output.operationCompleted()
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
        tasksObserver = tasksService.tasksObserver(predicate: predicate)
        
        tasksObserver.setActions(
            onInitialFetch: nil,
            onItemsCountChange: { [weak self] count in
                self?.output.tasksFetched(count: count)
            },
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: nil)
        
        output.prepareCacheObserver(tasksObserver!)
        
        tasksObserver.fetchInitialEntities()
    }
    
}
