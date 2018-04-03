//
//  ListsInteractor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.IndexPath
import class Foundation.DispatchQueue
import class CoreData.NSFetchRequest
import class CoreData.NSSortDescriptor
import class CoreData.NSManagedObjectContext
import protocol CoreData.NSFetchRequestResult

protocol ListsInteractorOutput: class {
    func prepareListsObserver(_ collectionViewManageble: CollectionViewManageble)
    func didFetchInitialLists()
    func didUpdateLists(with change: CoreDataItemChange)
    
    func prepareSmartListsObserver(_ collectionViewManageble: CollectionViewManageble)
    func didFetchInitialSmartLists()
    func didUpdateSmartLists(with change: CoreDataItemChange)
}

final class ListsInteractor {

    private let listsService = ListsService()
    private let tasksService = TasksService()
    
    private var smartListsObserver: CoreDataObserver<SmartList>!
    private var listsObserver: CoreDataObserver<List>!
    
    private var currentListsSorting: ListSorting!
    
    weak var output: ListsInteractorOutput!
    
    init() {
        setupSmartListsObserver()
        setupListsObserver()
    }
    
    func requestLists() {
        setupSmartListsObserver()
        setupListsObserver()
        
        output.prepareSmartListsObserver(smartListsObserver)
        output.prepareListsObserver(listsObserver)
        
        smartListsObserver.fetchInitialEntities()
        listsObserver.fetchInitialEntities()
    }
    
    func createListEntity() -> List {
        let id = RandomStringGenerator.randomString(length: 20)
        let image = ListIcon.randomIcon
        return List(id: id,
                    title: "",
                    icon: image,
                    creationDate: Date())
    }
    
    func createNewList(_ list: List) {
        listsService.addList(list) { error in }
    }
    
    func updateList(_ list: List) {
        listsService.updateList(list) { error in }
    }
    
    func removeList(_ list: List) {
        listsService.removeList(list) { error in }
    }
    
    
    func hideSmartList(_ list: SmartList) {
        listsService.removeSmartList(list) { error in }
    }

}

extension ListsInteractor {

    func numberOfSections() -> Int {
        return smartListsObserver.numberOfSections() + listsObserver.numberOfSections()
    }
    
    func numberOfItems(in section: Int) -> Int {
        if section == ListsCollectionViewSection.smartLists.rawValue {
            return smartListsObserver.numberOfItems(in: section)
        }
        return listsObserver.numberOfItems(in: section)
    }
    
    func list(at index: Int, in section: Int) -> List? {
        let indexPath = IndexPath(row: index, section: section)
        
        if section == ListsCollectionViewSection.smartLists.rawValue {
            return smartListsObserver.item(at: indexPath)
        }
        return listsObserver.item(at: indexPath)
    }
    
    func indexPath(ofList list: List) -> IndexPath? {
        if let list = list as? SmartList {
            guard let index = smartListsObserver.index(of: list) else { return nil }
            return IndexPath(row: index, section: ListsCollectionViewSection.smartLists.rawValue)
        } else {
            guard let index = listsObserver.index(of: list) else { return nil }
            return IndexPath(row: index, section: ListsCollectionViewSection.lists.rawValue) // FIXME: Может быть неправильная секция, если обычные списки будут разбиты на доп. секции
        }
    }

}

extension ListsInteractor {

    func tasksCount(in list: List) -> Int {
        if let smartList = list as? SmartList {
            return tasksService.fetchTasks(smartListID: smartList.id).count
        }
        return tasksService.fetchTasks(listID: list.id).count
    }
    
    func activeTasksCount(in list: List) -> Int {
        if let smartList = list as? SmartList {
            return tasksService.fetchActiveTasks(smartListID: smartList.id).count
        }
        return tasksService.fetchActiveTasks(listID: list.id).count
    }

}

fileprivate extension ListsInteractor {
    
    func setupListsObserver() {
        let listSorting = ListSorting(value: UserProperty.listSorting.int())
        
        guard currentListsSorting != listSorting else { return }
        
        currentListsSorting = listSorting
        
        listsObserver = makeListsObserver(sorting: listSorting)
        
        listsObserver.mapping = { entity in
            let listEntity = entity as! ListEntity
            return List(listEntity: listEntity)
        }
        
        listsObserver.onInitialFetch = { [weak self] in
            self?.output.didFetchInitialLists()
        }
        
        listsObserver.onItemChange = { [weak self] change in
            self?.output.didUpdateLists(with: change)
        }
    }
    
    func setupSmartListsObserver() {
        smartListsObserver = makeSmartListsObserver()
        
        smartListsObserver.mapping = { entity in
            let listEntity = entity as! SmartListEntity
            let type = SmartListType(id: listEntity.id ?? "")
            return SmartList(type: type)
        }
        
        smartListsObserver.onInitialFetch = { [weak self] in
            self?.output.didFetchInitialSmartLists()
        }
        
        smartListsObserver.onItemChange = { [weak self] change in
            self?.output.didUpdateSmartLists(with: change)
        }
    }
    
    func makeListsObserver(sorting: ListSorting) -> CoreDataObserver<List> {
        let observer: CoreDataObserver<List>
        observer = CoreDataObserver(request: makeListsFetchRequest(sorting: sorting),
                                    section: nil,
                                    cacheName: "lists",
                                    context: DefaultStorage.instance.database.readContext)
        observer.sectionOffset = 1
        return observer
    }
    
    func makeSmartListsObserver() -> CoreDataObserver<SmartList> {
        let observer: CoreDataObserver<SmartList>
        observer = CoreDataObserver(request: makeSmartListsFetchRequest(),
                                    section: nil,
                                    cacheName: "smart_lists",
                                    context: DefaultStorage.instance.database.readContext)
        observer.sectionOffset = 0
        return observer
    }
    
    func makeListsFetchRequest(sorting: ListSorting) -> NSFetchRequest<NSFetchRequestResult> {
        let sortDescriptor = sorting.sortDescriptor
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ListEntity.entityName)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
    func makeSmartListsFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SmartListEntity.entityName)
        let sortDescriptor = NSSortDescriptor(key: "sortPosition", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
}
