//
//  ListsInteractor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.DispatchQueue
import struct Foundation.IndexPath
import class CoreData.NSFetchRequest
import protocol CoreData.NSFetchRequestResult
import class SugarRecord.CoreDataDefaultStorage
import class CoreData.NSManagedObjectContext

protocol ListsInteractorOutput: class {
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble)
    func didFetchInitialLists()
    func didUpdateListsCount(_ count: Int)
    func didUpdateLists(with change: CoreDataItemChange)
}

final class ListsInteractor {

    fileprivate let listsService = ListsService()
    fileprivate let tasksService = TasksService()
    
    fileprivate var listsObserver: CoreDataObserver<List>!
    
    var output: ListsInteractorOutput!
    
    func requestLists() {
        if listsObserver == nil {
            setupListsObserver()
        }
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
    
    func setupListsObserver() {
        let sortDescriptor = ListSorting(value: UserProperty.listSorting.int()).sortDescriptor
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ListEntity.entityName)
        request.sortDescriptors = [sortDescriptor]
        let context = (DefaultStorage.instance.storage as! CoreDataDefaultStorage).mainContext as! NSManagedObjectContext
        listsObserver = CoreDataObserver(request: request, section: nil, cacheName: nil, context: context)
        listsObserver.sectionOffset = 1
        
        listsObserver.mapping = { entity in
            let listEntity = entity as! ListEntity
            return List(listEntity: listEntity)
        }
        
        listsObserver.onInitialFetch = { [weak self] in
            self?.output.didFetchInitialLists()
        }
        listsObserver.onFetchedObjectsCountChange = { [weak self] count in
            self?.output.didUpdateListsCount(count)
        }
        
        listsObserver.onItemChange = { [weak self] change in
            self?.output.didUpdateLists(with: change)
        }
        
        output.prepareCoreDataObserver(listsObserver)
        
        listsObserver.fetchInitialEntities()
    }

}

extension ListsInteractor {

    func numberOfSections() -> Int {
        return (listsObserver?.numberOfSections() ?? 0) + 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        if section == 0 {
            return listsService.smartLists.count
        }
        return listsObserver?.numberOfItems(in: section) ?? 0
    }
    
    func list(at index: Int, in section: Int) -> List? {
        if section == 0 {
            return listsService.smartLists.item(at: index)
        }
        return listsObserver?.item(at: IndexPath(row: index, section: section))
    }
    
    func totalListsCount() -> Int {
        return (0..<numberOfSections()).reduce(0) { (result, section) in
            return result + self.numberOfItems(in: section)
        }
    }

}

extension ListsInteractor {

    func tasksCount(in list: List) -> Int {
        return tasksService.fetchTasks(listID: list.id).count
    }

}
