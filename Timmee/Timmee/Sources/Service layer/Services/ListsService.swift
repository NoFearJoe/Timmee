//
//  ListsService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSSet
import class Foundation.NSSortDescriptor
import class CoreData.NSPredicate
import class CoreData.NSFetchRequest
import class CoreData.NSManagedObjectContext
import class CoreData.NSCompoundPredicate

final class ListsService {
    
    enum Error: Swift.Error {
        case listIsAlreadyExist
        case listIsNotExist
        case listAddingError
        case listUpdatingError
        case listRemovingError
    }
    
    lazy var smartListsFetchRequest: NSFetchRequest<SmartListEntity> = SmartListEntity.fetchRequest()
    
    lazy var listsFetchRequest: NSFetchRequest<ListEntity> = {
        let sortDescriptor = ListSorting(value: UserProperty.listSorting.int()).sortDescriptor
        let request: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        request.sortDescriptors = [sortDescriptor]
        return request
    }()
    
    fileprivate func listsSearchRequest(string: String) -> NSFetchRequest<ListEntity> {
        let request: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", string)
        return request
    }
    
    // MARK: Lists
    
    func fetchLists() -> [List] {
        let entities = fetchListEntities()
        return entities.map({ List(listEntity: $0) })
    }
    
    func addList(_ list: List, completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.database.write({ (context, save) in
            guard context.fetchList(id: list.id) == nil else {
                completion(.listIsAlreadyExist)
                return
            }
            
            if let newList = context.createList() {
                newList.map(from: list)
                save()
            }
        }) { isSuccess in
            completion(!isSuccess ? .listAddingError : nil)
        }
    }
    
    func updateList(_ list: List,
                    tasks: [Task] = [],
                    completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.database.write({ (context, save) in
            let taskEntities = NSSet(array: self.fetchTaskEntities(for: tasks,
                                                                   context: context))
            
            if let existingList = context.fetchList(id: list.id) {
                existingList.map(from: list)
                existingList.addToTasks(taskEntities)
                save()
            } else if let newList = context.createList() {
                newList.map(from: list)
                newList.addToTasks(taskEntities)
                save()
            }
        }) { isSuccess in
            completion(!isSuccess ? .listUpdatingError : nil)
        }
    }
    
    func removeList(_ list: List, completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.database.write({ (context, save) in
            guard let existingList = context.fetchList(id: list.id) else {
                completion(.listIsNotExist)
                return
            }
            
            context.delete(existingList)
            save()
        }) { isSuccess in
            completion(!isSuccess ? .listRemovingError : nil)
        }
    }
    
    // MARK: Smart lists
    
    func fetchSmartLists() -> [SmartList] {
        let entities = fetchSmartListEntities()
        return entities
            .compactMap {
                guard let id = $0.id else { return nil }
                let smartListType = SmartListType(id: id)
                return SmartList(type: smartListType)
            }
            .sorted(by: { lhs, rhs -> Bool in
                return lhs.smartListType.sortPosition < rhs.smartListType.sortPosition
            })
    }
    
    func addSmartList(_ list: SmartList,
                      completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.database.write({ (context, save) in
            guard context.fetchSmartList(id: list.id) == nil else {
                completion(.listIsAlreadyExist)
                return
            }
            
            if let newList = context.createSmartList() {
                newList.map(from: list)
                save()
            }
        }) { isSuccess in
            completion(!isSuccess ? .listAddingError : nil)
        }
    }
    
    func removeSmartList(_ list: SmartList,
                         completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.database.write({ (context, save) in
            guard let existingList = context.fetchSmartList(id: list.id) else {
                completion(.listIsNotExist)
                return
            }
            
            context.delete(existingList)
            save()
        }) { isSuccess in
            completion(!isSuccess ? .listRemovingError : nil)
        }
    }
    
}

fileprivate extension ListsService {
    
    func searchLists(by string: String) -> [List] {
        let entities = searchListEntities(by: string)
        return entities.map({ List(listEntity: $0) })
    }
    
    func fetchListEntities() -> [ListEntity] {
        return (try? DefaultStorage.instance.database.readContext.fetch(listsFetchRequest)) ?? []
    }
    
    func fetchSmartListEntities() -> [SmartListEntity] {
        return (try? DefaultStorage.instance.database.readContext.fetch(smartListsFetchRequest)) ?? []
    }
    
    func searchListEntities(by string: String) -> [ListEntity] {
        return (try? DefaultStorage.instance.database.readContext.fetch(listsSearchRequest(string: string))) ?? []
    }
    
    static func listFetchRequest(with id: String) -> NSFetchRequest<ListEntity> {
        let request: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        return request
    }
    
    static func smartListFetchRequest(with id: String) -> NSFetchRequest<SmartListEntity> {
        let request: NSFetchRequest<SmartListEntity> = SmartListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        return request
    }
    
    static func tasksFetchRequest(for tasks: [Task]) -> NSFetchRequest<TaskEntity> {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", tasks.map { $0.id })
        return request
    }
    
    func fetchTaskEntities(for tasks: [Task], context: NSManagedObjectContext) -> [TaskEntity] {
        return (try? context.fetch(ListsService.tasksFetchRequest(for: tasks))) ?? []
    }

}

extension NSManagedObjectContext {

    func fetchList(id: String) -> ListEntity? {
        return (try? fetch(ListsService.listFetchRequest(with: id)))?.first
    }
    
    func fetchSmartList(id: String) -> SmartListEntity? {
        return (try? fetch(ListsService.smartListFetchRequest(with: id)))?.first
    }
    
    func createList() -> ListEntity? {
        return try? create()
    }
    
    func createSmartList() -> SmartListEntity? {
        return try? create()
    }

}
