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
    func prepareListsObserver(_ cacheSubscribable: CacheSubscribable)
    func didFetchInitialLists()
    func didUpdateLists(with change: CoreDataChange)
    
    func prepareSmartListsObserver(_ cacheSubscribable: CacheSubscribable)
    func didFetchInitialSmartLists()
    func didUpdateSmartLists(with change: CoreDataChange)
}

final class ListsInteractor {

    private let listsService = ServicesAssembly.shared.listsService
    private let tasksService: TaskEntitiesCountProvider = ServicesAssembly.shared.tasksService
    
    private var smartListsObserver: CacheObserver<SmartList>!
    private var listsObserver: CacheObserver<List>!
    
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
        listsService.createOrUpdateList(list, tasks: []) { error in }
    }
    
    func updateList(_ list: List) {
        listsService.createOrUpdateList(list, tasks: []) { error in }
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
            return tasksService.tasksCount(smartListID: smartList.id)
        }
        return tasksService.tasksCount(listID: list.id)
    }
    
    func activeTasksCount(in list: List) -> Int {
        if let smartList = list as? SmartList {
            return tasksService.tasksCount(smartListID: smartList.id, isDone: false)
        }
        return tasksService.tasksCount(listID: list.id, isDone: false)
    }

}

private extension ListsInteractor {
    
    func setupListsObserver() {
        let listSorting = ListSorting(value: UserProperty.listSorting.int())
        guard currentListsSorting != listSorting else { return }
        currentListsSorting = listSorting
        
        listsObserver = listsService.listsObserver()
        
        listsObserver.setMapping { entity in
            let listEntity = entity as! ListEntity
            return List(listEntity: listEntity)
        }
        
        listsObserver.setActions(
            onInitialFetch: { [weak self] in
                self?.output.didFetchInitialLists()
            },
            onItemsCountChange: nil,
            onItemChange: { [weak self] change in
                self?.output.didUpdateLists(with: change)
            })
    }
    
    func setupSmartListsObserver() {
        smartListsObserver = listsService.smartListsObserver()
        
        smartListsObserver.setMapping { entity in
            let listEntity = entity as! SmartListEntity
            let type = SmartListType(id: listEntity.id ?? "")
            return SmartList(type: type)
        }
        
        smartListsObserver.setActions(
            onInitialFetch: { [weak self] in
                self?.output.didFetchInitialSmartLists()
            },
            onItemsCountChange: nil,
            onItemChange: { [weak self] change in
                self?.output.didUpdateSmartLists(with: change)
            })
    }
    
}
