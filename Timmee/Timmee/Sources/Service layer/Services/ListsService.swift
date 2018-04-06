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

protocol ListsProvider: class {
    func fetchLists() -> [List]
}

protocol SmartListsProvider: class {
    func fetchSmartLists() -> [SmartList]
}

protocol ListEntitiesProvider: class {
    func createListEntity() -> ListEntity?
    func fetchListEntities() -> [ListEntity]
    func fetchListEntities(context: NSManagedObjectContext) -> [ListEntity]
    func fetchListEntity(id: String) -> ListEntity?
    func fetchListEntity(id: String, context: NSManagedObjectContext) -> ListEntity?
}

protocol SmartListEntitiesProvider: class {
    func createSmartListEntity() -> SmartListEntity?
    func fetchSmartListEntities() -> [SmartListEntity]
    func fetchSmartListEntities(context: NSManagedObjectContext) -> [SmartListEntity]
    func fetchSmartList(id: String) -> SmartListEntity?
    func fetchSmartList(id: String, context: NSManagedObjectContext) -> SmartListEntity?
}

protocol ListsObserverProvider: class {
    func listsObserver() -> CoreDataObserver<List>
    func smartListsObserver() -> CoreDataObserver<SmartList>
}

protocol ListsManager: class {
    func createOrUpdateList(_ list: List, tasks: [Task], completion: @escaping (ListsService.Error?) -> Void)
    func removeList(_ list: List, completion: @escaping (ListsService.Error?) -> Void)
}

protocol SmartListsManager: class {
    func addSmartList(_ list: SmartList, completion: @escaping (ListsService.Error?) -> Void)
    func removeSmartList(_ list: SmartList, completion: @escaping (ListsService.Error?) -> Void)
}

final class ListsService {
    
    enum Error: Swift.Error {
        case listIsNotExist
        case listAddingError
        case listUpdatingError
        case listRemovingError
    }
    
    weak var tasksProvider: TaskEntitiesBackgroundProvider!
    
}

// MARK: - Lists manager

extension ListsService: ListsManager {
    
    func createOrUpdateList(_ list: List,
                            tasks: [Task],
                            completion: @escaping (Error?) -> Void) {
        Database.localStorage.write({ (context, save) in
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
            completion(!isSuccess ? .listUpdatingError : nil)
        }
    }
    
    func removeList(_ list: List, completion: @escaping (Error?) -> Void) {
        Database.localStorage.write({ (context, save) in
            guard let existingList = self.fetchListEntity(id: list.id, context: context) else {
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

// MARK: - Smart lists manager

extension ListsService: SmartListsManager {
    
    func addSmartList(_ list: SmartList,
                      completion: @escaping (Error?) -> Void) {
        Database.localStorage.write({ (context, save) in
            guard self.fetchSmartList(id: list.id, context: context) == nil else {
                completion(.listAddingError)
                return
            }
            
            if let newList = self.createSmartListEntity() {
                newList.map(from: list)
                save()
            }
        }) { isSuccess in
            completion(!isSuccess ? .listAddingError : nil)
        }
    }
    
    func removeSmartList(_ list: SmartList,
                         completion: @escaping (Error?) -> Void) {
        Database.localStorage.write({ (context, save) in
            guard let existingList = self.fetchSmartList(id: list.id, context: context) else {
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

// MARK: - Fetch

extension ListsService: ListsProvider, SmartListsProvider {
    
    func fetchLists() -> [List] {
        let entities = fetchListEntities()
        return entities.map({ List(listEntity: $0) })
    }
    
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
    
}

// MARK: - Fetch list entities

extension ListsService: ListEntitiesProvider {
    
    func createListEntity() -> ListEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    func fetchListEntities() -> [ListEntity] {
        return ListsService.listsFetchRequest().execute()
    }
    
    func fetchListEntities(context: NSManagedObjectContext) -> [ListEntity] {
        return ListsService.listsFetchRequest().execute(context: context)
    }
    
    func fetchListEntity(id: String) -> ListEntity? {
        return ListsService.listFetchRequest(id: id).execute().first
    }
    
    func fetchListEntity(id: String, context: NSManagedObjectContext) -> ListEntity? {
        return ListsService.listFetchRequest(id: id).execute(context: context).first
    }

}

// MARK: - Fetch smart list entities

extension ListsService: SmartListEntitiesProvider {
    
    func createSmartListEntity() -> SmartListEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    func fetchSmartListEntities() -> [SmartListEntity] {
        return ListsService.smartListsFetchRequest().execute()
    }
    
    func fetchSmartListEntities(context: NSManagedObjectContext) -> [SmartListEntity] {
        return ListsService.smartListsFetchRequest().execute(context: context)
    }
    
    func fetchSmartList(id: String) -> SmartListEntity? {
        return ListsService.smartListFetchRequest(id: id).execute().first
    }
    
    func fetchSmartList(id: String, context: NSManagedObjectContext) -> SmartListEntity? {
        return ListsService.smartListFetchRequest(id: id).execute(context: context).first
    }
    
}

// MARK: - Lists observer

extension ListsService: ListsObserverProvider {
    
    func listsObserver() -> CoreDataObserver<List> {
        let observer: CoreDataObserver<List>
        observer = CoreDataObserver(request: ListsService.listsFetchRequest().nsFetchRequestWithResult,
                                    section: nil,
                                    cacheName: "lists",
                                    context: Database.localStorage.readContext)
        observer.sectionOffset = 1
        return observer
    }
    
    func smartListsObserver() -> CoreDataObserver<SmartList> {
        let observer: CoreDataObserver<SmartList>
        observer = CoreDataObserver(request: ListsService.smartListsFetchRequest().nsFetchRequestWithResult,
                                    section: nil,
                                    cacheName: "smart_lists",
                                    context: Database.localStorage.readContext)
        observer.sectionOffset = 0
        return observer
    }
    
}

// MARK: - Fetch requests

private extension ListsService {
    
    /// Запрос всех смарт списков
    static func smartListsFetchRequest() -> FetchRequest<SmartListEntity> {
        return SmartListEntity.request().sorted(key: "sortPosition", ascending: true)
    }
    
    /// Запрос смарт списка по id
    static func smartListFetchRequest(id: String) -> FetchRequest<SmartListEntity> {
        return SmartListEntity.request().filtered(key: "id", value: id)
    }
    
    /// Запрос всех списков
    static func listsFetchRequest() -> FetchRequest<ListEntity> {
        let sortDescriptor = ListSorting(value: UserProperty.listSorting.int()).sortDescriptor
        return ListEntity.request().sorted(sortDescriptor: sortDescriptor)
    }
    
    /// Запрос списка по id
    static func listFetchRequest(id: String) -> FetchRequest<ListEntity> {
        return ListEntity.request().filtered(key: "id", value: id)
    }
    
}
