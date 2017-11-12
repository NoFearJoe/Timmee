//
//  TasksImportInteractor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.IndexPath
import class Foundation.NSPredicate
import class CoreData.NSFetchRequest
import protocol CoreData.NSFetchRequestResult
import class CoreData.NSManagedObjectContext
import class SugarRecord.CoreDataDefaultStorage

protocol TasksImportInteractorInput: class {
    func fetchTasks(excludeList list: List?)
    func searchTasks(by string: String, excludeList list: List?)
}

protocol TasksImportInteractorOutput: class {
    func tasksFetched(count: Int)
    
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble)
}

protocol TasksImportDataSource: class {
    func sectionsCount() -> Int
    func itemsCount(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> Task?
    func sectionTitle(forSectionAt index: Int) -> String?
}

final class TasksImportInteractor {

    weak var output: TasksImportInteractorOutput!
    
    fileprivate let tasksService = TasksService()
    
    fileprivate var tasksObserver: CoreDataObserver<Task>!

}

extension TasksImportInteractor: TasksImportInteractorInput {

    func fetchTasks(excludeList list: List?) {
        if let list = list {
            fetchTasks(predicate: NSPredicate(format: "list.id != %@ || list == nil", list.id))
        } else {
            fetchTasks(predicate: nil)
        }
    }
    
    func searchTasks(by string: String, excludeList list: List?) {
        let predicate: NSPredicate
        if let list = list {
            predicate = NSPredicate(format: "(list.id != %@ || list == nil) && title CONTAINS[cd] %@", list.id, string.trimmed.lowercased())
        } else {
            predicate = NSPredicate(format: "title CONTAINS[cd] %@", string.trimmed.lowercased())
        }
        fetchTasks(predicate: predicate)
    }

}

extension TasksImportInteractor: TasksImportDataSource {
    
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

fileprivate extension TasksImportInteractor {
    
    func fetchTasks(predicate: NSPredicate?) {
        let request = tasksService.allTasksFetchRequest() as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = predicate
        let context = DefaultStorage.instance.mainContext
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
