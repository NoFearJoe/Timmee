//
//  ListsService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSSet
import class CoreData.NSPredicate
import class CoreData.NSManagedObjectContext
import class CoreData.NSCompoundPredicate
import struct SugarRecord.FetchRequest
import class SugarRecord.CoreDataDefaultStorage
import protocol SugarRecord.Context

final class ListsService {
    
    enum Error: Swift.Error {
        case listIsAlreadyExist
        case listIsNotExist
        case listAddingError
        case listUpdatingError
        case listRemovingError
    }
    
    lazy var smartListsFetchRequest: FetchRequest<SmartListEntity> = {
        return FetchRequest<SmartListEntity>()
    }()
    
    lazy var listsFetchRequest: FetchRequest<ListEntity> = {
        let sortDescriptor = ListSorting(value: UserProperty.listSorting.int()).sortDescriptor
        return FetchRequest<ListEntity>().sorted(with: sortDescriptor)
    }()
    
    fileprivate func listsSearchRequest(string: String) -> FetchRequest<ListEntity> {
        return listsFetchRequest.filtered(with: NSPredicate(format: "title CONTAINS[cd] %@", string))
    }
    
    // MARK: Lists
    
    func fetchLists() -> [List] {
        let entities = fetchListEntities()
        return entities.map({ List(listEntity: $0) })
    }
    
    func addList(_ list: List, completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            guard context.fetchList(id: list.id) == nil else {
                completion(.listIsAlreadyExist)
                return
            }
            
            if let newList = context.createList() {
                newList.map(from: list)
                save()
            }
        }) { error in
            completion(error != nil ? .listAddingError : nil)
        }
    }
    
    func updateList(_ list: List,
                    tasks: [Task] = [],
                    completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
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
        }) { error in
            completion(error != nil ? .listUpdatingError : nil)
        }
    }
    
    func removeList(_ list: List, completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            guard let existingList = context.fetchList(id: list.id) else {
                completion(.listIsNotExist)
                return
            }
            
            try? context.remove(existingList)
            save()
        }) { error in
            completion(error != nil ? .listRemovingError : nil)
        }
    }
    
    // MARK: Smart lists
    
    func fetchSmartLists() -> [SmartList] {
        let entities = fetchSmartListEntities()
        return entities
            .flatMap {
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
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            guard context.fetchSmartList(id: list.id) == nil else {
                completion(.listIsAlreadyExist)
                return
            }
            
            if let newList = context.createSmartList() {
                newList.map(from: list)
                save()
            }
        }) { error in
            completion(error != nil ? .listAddingError : nil)
        }
    }
    
    func removeSmartList(_ list: SmartList,
                         completion: @escaping (Error?) -> Void) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            guard let existingList = context.fetchSmartList(id: list.id) else {
                completion(.listIsNotExist)
                return
            }
            
            try? context.remove(existingList)
            save()
        }) { error in
            completion(error != nil ? .listRemovingError : nil)
        }
    }
    
}

fileprivate extension ListsService {
    
    func searchLists(by string: String) -> [List] {
        let entities = searchListEntities(by: string)
        return entities.map({ List(listEntity: $0) })
    }
    
    func fetchListEntities() -> [ListEntity] {
        return (try? DefaultStorage.instance.storage.fetch(listsFetchRequest)) ?? []
    }
    
    func fetchSmartListEntities() -> [SmartListEntity] {
        return (try? DefaultStorage.instance.storage.fetch(smartListsFetchRequest)) ?? []
    }
    
    func searchListEntities(by string: String) -> [ListEntity] {
        return (try? DefaultStorage.instance.storage.fetch(listsSearchRequest(string: string))) ?? []
    }
    
    static func listFetchRequest(with id: String) -> FetchRequest<ListEntity> {
        return FetchRequest<ListEntity>().filtered(with: "id", equalTo: id)
    }
    
    static func smartListFetchRequest(with id: String) -> FetchRequest<SmartListEntity> {
        return FetchRequest<SmartListEntity>().filtered(with: "id", equalTo: id)
    }
    
    static func tasksFetchRequest(for tasks: [Task]) -> FetchRequest<TaskEntity> {
        return FetchRequest<TaskEntity>().filtered(with: "id", in: tasks.map { $0.id })
    }
    
    func fetchTaskEntities(for tasks: [Task], context: Context) -> [TaskEntity] {
        return (try? context.fetch(ListsService.tasksFetchRequest(for: tasks))) ?? []
    }

}

extension Context {

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
