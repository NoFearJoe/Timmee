//
//  StorageObservable.swift
//  Timmee
//
//  Created by Ilya Kharabet on 30.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSObject
import struct Foundation.IndexPath
import class CoreData.NSManagedObject
import class CoreData.NSFetchedResultsController
import protocol CoreData.NSFetchedResultsControllerDelegate
import class CoreData.NSManagedObjectContext
import protocol CoreData.NSFetchRequestResult
import enum CoreData.NSFetchedResultsChangeType
import class CoreData.NSFetchRequest
import protocol CoreData.NSFetchedResultsSectionInfo
import class UIKit.UITableView
import struct Foundation.IndexSet

enum CoreDataItemChange {
    case insertion(IndexPath)
    case deletion(IndexPath)
    case update(IndexPath)
    case move(IndexPath, IndexPath)
}

protocol TableViewManageble: class {
    func setTableView(_ tableView: UITableView)
}

final class CoreDataObserver<T: Equatable>: NSObject, NSFetchedResultsControllerDelegate, TableViewManageble {

    let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    var mapping: ((NSManagedObject) -> T)!
    var onFetchedObjectsCountChange: ((Int) -> Void)?
    var onItemChange: ((CoreDataItemChange) -> Void)?
    var onInitialFetch: (() -> Void)?
    
    var sectionOffset: Int = 0
    
    fileprivate weak var tableView: UITableView?
    
    fileprivate var batchChanges: [CoreDataItemChange] = []
    
    init(request: NSFetchRequest<NSFetchRequestResult>,
        section: String?,
        cacheName: String?,
        context: NSManagedObjectContext) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: section,
                                                              cacheName: cacheName)
        
        super.init()
    }
    
    func setTableView(_ tableView: UITableView) {
        self.tableView = tableView
    }
    
    func fetchInitialEntities() {
        _ = try? fetchedResultsController.performFetch()
        tableView?.reloadData()
        onFetchedObjectsCountChange?(totalObjectsCount())
        onInitialFetch?()
        
        fetchedResultsController.delegate = self
    }
    

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex + sectionOffset), with: .fade)
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex + sectionOffset), with: .fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        var indexPathWithOffset = indexPath
        indexPathWithOffset?.section += sectionOffset
        
        var newIndexPathWithOffset = newIndexPath
        newIndexPathWithOffset?.section += sectionOffset
        
        switch type {
        case .insert:
            batchChanges.append(.insertion(newIndexPathWithOffset!))
            tableView?.insertRows(at: [newIndexPathWithOffset!], with: .fade)
        case .delete:
            batchChanges.append(.deletion(indexPathWithOffset!))
            tableView?.deleteRows(at: [indexPathWithOffset!], with: .fade)
        case .update:
            batchChanges.append(.update(indexPathWithOffset!))
            tableView?.reloadRows(at: [indexPathWithOffset!], with: .fade)
        case .move:
            batchChanges.append(.move(indexPathWithOffset!, newIndexPathWithOffset!))
            
            guard let tableView = tableView else { break }
            
            if tableView.numberOfSections - 1 < newIndexPathWithOffset!.section {
                tableView.deleteRows(at: [indexPathWithOffset!], with: .fade)
            } else {
                tableView.deleteRows(at: [indexPathWithOffset!], with: .fade)
                tableView.insertRows(at: [newIndexPathWithOffset!], with: .fade)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
        onFetchedObjectsCountChange?(totalObjectsCount())
        
        batchChanges.forEach { self.onItemChange?($0) }
        batchChanges.removeAll()        
    }

}

extension CoreDataObserver {

    func numberOfSections() -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        guard let section = sections.item(at: section - sectionOffset) else { return 0 }
        return section.numberOfObjects
    }
    
    func item(at indexPath: IndexPath) -> T {
        return mapping(entity(at: indexPath))
    }
    
    func entity(at indexPath: IndexPath) -> NSManagedObject {
        var indexPathWithOffset = indexPath
        indexPathWithOffset.section -= sectionOffset
        
        return fetchedResultsController.object(at: indexPathWithOffset) as! NSManagedObject
    }
    
    func index(of item: T) -> Int? {
        return fetchedResultsController.fetchedObjects?.index(where: { entity in
            let object = self.mapping(entity as! NSManagedObject)
            return object == item
        })
    }
    
    func totalObjectsCount() -> Int {
        return (0..<numberOfSections()).reduce(0) { (result, section) in
            return result + self.numberOfItems(in: section)
        }
    }
    
    func containsSection(withName name: String) -> Bool {
        return sectionInfo(with: name) != nil
    }
    
    func sectionInfo(with sectionName: String) -> (name: String, numberOfItems: Int)? {
        guard let sections = fetchedResultsController.sections else { return nil }
        guard let sectionInfo = sections.first(where: { $0.name == sectionName }) else { return nil }
        return (sectionInfo.name, sectionInfo.numberOfObjects)
    }
    
    func sectionInfo(at index: Int) -> (name: String, numberOfItems: Int)? {
        guard let sections = fetchedResultsController.sections else { return nil }
        guard let sectionInfo = sections.item(at: index) else { return nil }
        return (sectionInfo.name, sectionInfo.numberOfObjects)
    }
    
}
