//
//  ListsService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset
import class Foundation.NSSet
import class Foundation.NSSortDescriptor
import class CoreData.NSPredicate
import class CoreData.NSFetchRequest
import class CoreData.NSManagedObjectContext
import class CoreData.NSCompoundPredicate

public protocol ListsProvider: class {
    func fetchLists() -> [List]
}

public protocol SmartListsProvider: class {
    func fetchSmartLists() -> [SmartList]
}

public protocol ListEntitiesProvider: class {
    func createListEntity() -> ListEntity?
    func fetchListEntities() -> [ListEntity]
    func fetchListEntities(context: NSManagedObjectContext) -> [ListEntity]
    func fetchListEntity(id: String) -> ListEntity?
    func fetchListEntity(id: String, context: NSManagedObjectContext) -> ListEntity?
}

public protocol SmartListEntitiesProvider: class {
    func createSmartListEntity() -> SmartListEntity?
    func fetchSmartListEntities() -> [SmartListEntity]
    func fetchSmartListEntities(context: NSManagedObjectContext) -> [SmartListEntity]
    func fetchSmartList(id: String) -> SmartListEntity?
    func fetchSmartList(id: String, context: NSManagedObjectContext) -> SmartListEntity?
}

public protocol ListsObserverProvider: class {
    func listsObserver() -> CacheObserver<List>
    func smartListsObserver() -> CacheObserver<SmartList>
}

public protocol ListsManager: class {
    func createOrUpdateList(_ list: List, tasks: [Task], completion: @escaping (ListsService.Error?) -> Void)
    func removeList(_ list: List, completion: @escaping (ListsService.Error?) -> Void)
    func changeFavoriteState(of list: List, to isFavorite: Bool, completion: @escaping (ListsService.Error?) -> Void)
}

public protocol SmartListsManager: class {
    func addSmartList(_ list: SmartList, completion: @escaping (ListsService.Error?) -> Void)
    func removeSmartList(_ list: SmartList, completion: @escaping (ListsService.Error?) -> Void)
}

public final class ListsService {
    
    public enum Error: Swift.Error {
        case listIsNotExist
        case listAddingError
        case listUpdatingError
        case listRemovingError
    }
    
    weak var tasksProvider: TaskEntitiesBackgroundProvider!
    
}

// MARK: - Lists manager

extension ListsService: ListsManager {
    
    public func createOrUpdateList(_ list: List,
                                   tasks: [Task],
                                   completion: @escaping (Error?) -> Void) {
        Database.localStorage.write({ context, save in
            let taskEntities = NSSet(array: tasks.isEmpty ? [] : self.tasksProvider.fetchTaskEntitiesInBackground(tasks: tasks))
            
            if let existingList = self.fetchListEntity(id: list.id, context: context) {
                existingList.map(from: list)
                if !tasks.isEmpty {
                    existingList.addToTasks(taskEntities)
                }
            } else if let newList = self.createListEntity() {
                newList.map(from: list)
                if !tasks.isEmpty {
                    newList.addToTasks(taskEntities)
                }
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(!isSuccess ? .listUpdatingError : nil) }
        }
    }
    
    public func removeList(_ list: List, completion: @escaping (Error?) -> Void) {
        Database.localStorage.write({ context, save in
            guard let existingList = self.fetchListEntity(id: list.id, context: context) else {
                DispatchQueue.main.async { completion(.listIsNotExist) }
                return
            }
            
            context.delete(existingList)
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(!isSuccess ? .listRemovingError : nil) }
        }
    }
    
    public func changeFavoriteState(of list: List, to isFavorite: Bool, completion: @escaping (ListsService.Error?) -> Void) {
        Database.localStorage.write({ context, save in
            guard let existingList = self.fetchListEntity(id: list.id, context: context) else {
                DispatchQueue.main.async { completion(.listIsNotExist) }
                return
            }
            
            existingList.isFavorite = isFavorite
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(!isSuccess ? .listUpdatingError : nil) }
        }
    }
    
}

// MARK: - Smart lists manager

extension ListsService: SmartListsManager {
    
    public func addSmartList(_ list: SmartList,
                             completion: @escaping (Error?) -> Void) {
        Database.localStorage.write({ (context, save) in
            guard self.fetchSmartList(id: list.id, context: context) == nil else {
                DispatchQueue.main.async { completion(.listAddingError) }
                return
            }
            
            if let newList = self.createSmartListEntity() {
                newList.map(from: list)
                save()
            }
        }) { isSuccess in
            DispatchQueue.main.async { completion(!isSuccess ? .listAddingError : nil) }
        }
    }
    
    public func removeSmartList(_ list: SmartList,
                                completion: @escaping (Error?) -> Void) {
        Database.localStorage.write({ (context, save) in
            guard let existingList = self.fetchSmartList(id: list.id, context: context) else {
                DispatchQueue.main.async { completion(.listIsNotExist) }
                return
            }
            
            context.delete(existingList)
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(!isSuccess ? .listRemovingError : nil) }
        }
    }
    
}

// MARK: - Fetch

extension ListsService: ListsProvider, SmartListsProvider {
    
    public func fetchLists() -> [List] {
        let entities = fetchListEntities()
        return entities.map({ List(listEntity: $0) })
    }
    
    public func fetchSmartLists() -> [SmartList] {
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
    
}

// MARK: - Fetch list entities

extension ListsService: ListEntitiesProvider {
    
    public func createListEntity() -> ListEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchListEntities() -> [ListEntity] {
        return ListsService.listsFetchRequest().execute()
    }
    
    public func fetchListEntities(context: NSManagedObjectContext) -> [ListEntity] {
        return ListsService.listsFetchRequest().execute(context: context)
    }
    
    public func fetchListEntity(id: String) -> ListEntity? {
        return ListsService.listFetchRequest(id: id).execute().first
    }
    
    public func fetchListEntity(id: String, context: NSManagedObjectContext) -> ListEntity? {
        return ListsService.listFetchRequest(id: id).execute(context: context).first
    }

}

// MARK: - Fetch smart list entities

extension ListsService: SmartListEntitiesProvider {
    
    public func createSmartListEntity() -> SmartListEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchSmartListEntities() -> [SmartListEntity] {
        return ListsService.smartListsFetchRequest().execute()
    }
    
    public func fetchSmartListEntities(context: NSManagedObjectContext) -> [SmartListEntity] {
        return ListsService.smartListsFetchRequest().execute(context: context)
    }
    
    public func fetchSmartList(id: String) -> SmartListEntity? {
        return ListsService.smartListFetchRequest(id: id).execute().first
    }
    
    public func fetchSmartList(id: String, context: NSManagedObjectContext) -> SmartListEntity? {
        return ListsService.smartListFetchRequest(id: id).execute(context: context).first
    }
    
}

// MARK: - Lists observer

extension ListsService: ListsObserverProvider {
    
    public func listsObserver() -> CacheObserver<List> {
        let observer: CacheObserver<List>
        observer = CacheObserver(request: ListsService.listsFetchRequest().nsFetchRequestWithResult,
                                 section: nil,
                                 cacheName: nil,
                                 context: Database.localStorage.readContext)
        observer.setSectionOffset(1)
        return observer
    }
    
    public func smartListsObserver() -> CacheObserver<SmartList> {
        let observer: CacheObserver<SmartList>
        observer = CacheObserver(request: ListsService.smartListsFetchRequest().nsFetchRequestWithResult,
                                 section: nil,
                                 cacheName: nil,
                                 context: Database.localStorage.readContext)
        observer.setSectionOffset(0)
        return observer
    }
    
}

// MARK: - Fetch requests

private extension ListsService {
    
    /// Запрос всех смарт списков
    static func smartListsFetchRequest() -> FetchRequest<SmartListEntity> {
        return SmartListEntity.request().sorted(keyPath: \.sortPosition, ascending: true)
    }
    
    /// Запрос смарт списка по id
    static func smartListFetchRequest(id: String) -> FetchRequest<SmartListEntity> {
        return SmartListEntity.request().filtered(key: "id", value: id)
    }
    
    /// Запрос всех списков
    static func listsFetchRequest() -> FetchRequest<ListEntity> {
        let sortDescriptor = ListSorting(value: ListSorting.asUserProperty.int()).sortDescriptor
        return ListEntity.request().sorted(keyPath: \.isFavorite, ascending: false).sorted(sortDescriptor: sortDescriptor)
    }
    
    /// Запрос списка по id
    static func listFetchRequest(id: String) -> FetchRequest<ListEntity> {
        return ListEntity.request().filtered(key: "id", value: id)
    }
    
}
