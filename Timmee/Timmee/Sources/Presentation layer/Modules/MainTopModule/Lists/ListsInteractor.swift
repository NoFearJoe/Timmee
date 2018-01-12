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
import class CoreData.NSManagedObjectContext
import protocol CoreData.NSFetchRequestResult
import class SugarRecord.CoreDataDefaultStorage

protocol ListsInteractorOutput: class {
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble)
    func didFetchInitialLists()
    func didUpdateLists(with change: CoreDataItemChange)
}

final class ListsInteractor {

    fileprivate let listsService = ListsService()
    fileprivate let tasksService = TasksService()
    
    fileprivate var listsObserver: CoreDataObserver<List>!
    fileprivate var currentListsSorting: ListSorting!
    
    weak var output: ListsInteractorOutput!
    
    init() {
        setupListsObserver()
    }
    
    func requestLists() {
        setupListsObserver()
        output.prepareCoreDataObserver(listsObserver)
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

}

extension ListsInteractor {

    func numberOfSections() -> Int {
        return listsObserver.numberOfSections() + 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        if section == 0 {
            return listsService.smartLists.count
        }
        return listsObserver.numberOfItems(in: section)
    }
    
    func list(at index: Int, in section: Int) -> List? {
        if section == 0 {
            return listsService.smartLists.item(at: index)
        }
        return listsObserver.item(at: IndexPath(row: index, section: section))
    }
    
    func totalListsCount() -> Int {
        return (0..<numberOfSections()).reduce(0) { (result, section) in
            return result + self.numberOfItems(in: section)
        }
    }
    
    func indexPath(ofList list: List) -> IndexPath? {
        if let list = list as? SmartList {
            guard let index = listsService.smartLists.index(of: list) else { return nil }
            return IndexPath(row: index, section: 0)
        } else {
            guard let index = listsObserver.index(of: list) else { return nil }
            return IndexPath(row: index, section: 1)
        }
    }

}

extension ListsInteractor {

    func tasksCount(in list: List) -> Int {
        return tasksService.fetchTasks(listID: list.id).count
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
    
    func makeListsObserver(sorting: ListSorting) -> CoreDataObserver<List> {
        let observer: CoreDataObserver<List>
        observer = CoreDataObserver(request: makeListsFetchRequest(sorting: sorting),
                                    section: nil,
                                    cacheName: "lists",
                                    context: DefaultStorage.instance.mainContext)
        observer.sectionOffset = 1
        return observer
    }
    
    func makeListsFetchRequest(sorting: ListSorting) -> NSFetchRequest<NSFetchRequestResult> {
        let sortDescriptor = sorting.sortDescriptor
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ListEntity.entityName)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
}
