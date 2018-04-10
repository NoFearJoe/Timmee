//
//  StorageObservable.swift
//  Timmee
//
//  Created by Ilya Kharabet on 30.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset
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
import class UIKit.UICollectionView
import struct Foundation.IndexSet

public enum CoreDataItemChange {
    case insertion(IndexPath)
    case deletion(IndexPath)
    case update(IndexPath)
    case move(IndexPath, IndexPath)
}

public protocol TableViewManageble: class {
    func setTableView(_ tableView: UITableView)
}

public protocol CollectionViewManageble: class {
    func setCollectionView(_ collectionView: UICollectionView)
}

public final class CoreDataObserver<T: Equatable>: NSObject, NSFetchedResultsControllerDelegate, TableViewManageble, CollectionViewManageble {

    let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    public var mapping: ((NSManagedObject) -> T)!
    public var onFetchedObjectsCountChange: ((Int) -> Void)?
    public var onItemChange: ((CoreDataItemChange) -> Void)?
    public var onInitialFetch: (() -> Void)?
    
    public var sectionOffset: Int = 0
    
    private weak var tableView: UITableView?
    private weak var collectionView: UICollectionView?
    
    private var batchChanges: [CoreDataItemChange] = []
    
    public init(request: NSFetchRequest<NSFetchRequestResult>,
        section: String?,
        cacheName: String?,
        context: NSManagedObjectContext) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: section,
                                                              cacheName: cacheName)
        
        super.init()
    }
    
    public func setTableView(_ tableView: UITableView) {
        self.tableView = tableView
    }
    
    public func setCollectionView(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    public func fetchInitialEntities() {
        _ = try? fetchedResultsController.performFetch()
        tableView?.reloadData()
        collectionView?.reloadData()
        onFetchedObjectsCountChange?(totalObjectsCount())
        onInitialFetch?()
        
        fetchedResultsController.delegate = self
    }
    

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
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
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
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
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onFetchedObjectsCountChange?(totalObjectsCount())
        
        if let collectionView = self.collectionView {
            let changes = batchChanges
            
            collectionView.performBatchUpdates({
                changes.forEach { change in
                    switch change {
                    case let .insertion(indexPath):
                        collectionView.insertItems(at: [indexPath])
                    case let .deletion(indexPath):
                        collectionView.deleteItems(at: [indexPath])
                    case let .update(indexPath):
                        collectionView.reloadItems(at: [indexPath])
                    case let .move(fromIndexPath, toIndexPath):
                        collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
                    }
                }
            }, completion: { finished in
                self.batchChanges.forEach { self.onItemChange?($0) }
                self.batchChanges.removeAll()
            })
        } else {
            tableView?.endUpdates()
            batchChanges.forEach { self.onItemChange?($0) }
            batchChanges.removeAll()
        }
    }

}

public extension CoreDataObserver {

    public func numberOfSections() -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        guard let section = sections.item(at: section - sectionOffset) else { return 0 }
        return section.numberOfObjects
    }
    
    public func item(at indexPath: IndexPath) -> T {
        return mapping(entity(at: indexPath))
    }
    
    public func entity(at indexPath: IndexPath) -> NSManagedObject {
        var indexPathWithOffset = indexPath
        indexPathWithOffset.section -= sectionOffset
        
        return fetchedResultsController.object(at: indexPathWithOffset) as! NSManagedObject
    }
    
    public func index(of item: T) -> Int? {
        return fetchedResultsController.fetchedObjects?.index(where: { entity in
            let object = self.mapping(entity as! NSManagedObject)
            return object == item
        })
    }
    
    public func totalObjectsCount() -> Int {
        return (0..<numberOfSections()).reduce(0) { (result, section) in
            return result + self.numberOfItems(in: section)
        }
    }
    
    public func containsSection(withName name: String) -> Bool {
        return sectionInfo(with: name) != nil
    }
    
    public func sectionInfo(with sectionName: String) -> (name: String, numberOfItems: Int)? {
        guard let sections = fetchedResultsController.sections else { return nil }
        guard let sectionInfo = sections.first(where: { $0.name == sectionName }) else { return nil }
        return (sectionInfo.name, sectionInfo.numberOfObjects)
    }
    
    public func sectionInfo(at index: Int) -> (name: String, numberOfItems: Int)? {
        guard let sections = fetchedResultsController.sections else { return nil }
        guard let sectionInfo = sections.item(at: index) else { return nil }
        return (sectionInfo.name, sectionInfo.numberOfObjects)
    }
    
}
