//
//  CacheObserver.swift
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
import struct Foundation.IndexSet

public enum CoreDataChange {
    case sectionInsertion(Int)
    case sectionDeletion(Int)
    case insertion(IndexPath)
    case deletion(IndexPath)
    case update(IndexPath)
    case move(IndexPath, IndexPath)
}

public protocol CacheSubscriber: class {
    func reloadData()
    func prepareToProcessChanges()
    func processChanges(_ changes: [CoreDataChange], completion: @escaping () -> Void)
}

public protocol CacheSubscribable: class {
    func setSubscriber(_ subscriber: CacheSubscriber)
}

public protocol CacheObserverConfigurable: class {
    associatedtype T: Equatable
    
    func setSectionOffset(_ offset: Int)
    func setMapping(_ mapping: @escaping (NSManagedObject) -> T)
    func setActions(onInitialFetch: (() -> Void)?,
                    onItemsCountChange: ((Int) -> Void)?,
                    onItemChange: ((CoreDataChange) -> Void)?,
                    onBatchUpdatesStarted: (() -> Void)?,
                    onBatchUpdatesCompleted: (() -> Void)?)
}

public final class CacheObserver<T: Equatable>: NSObject, NSFetchedResultsControllerDelegate {
    
    private var mapping: ((NSManagedObject) -> T)!
    private var onItemsCountChange: ((Int) -> Void)?
    private var onItemChange: ((CoreDataChange) -> Void)?
    private var onInitialFetch: (() -> Void)?
    private var onBatchUpdatesStarted: (() -> Void)?
    private var onBatchUpdatesCompleted: (() -> Void)?
    
    private var sectionOffset: Int = 0
    
    private let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    private weak var subscriber: CacheSubscriber?
    
    private var batchChanges: [CoreDataChange] = []
    
    public init(request: NSFetchRequest<NSFetchRequestResult>,
                section: String?,
                cacheName: String?,
                context: NSManagedObjectContext) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: section,
                                                              cacheName: cacheName)
        super.init()
        fetchedResultsController.delegate = self
    }
    
    public func fetchInitialEntities() {
        try? fetchedResultsController.performFetch()
        subscriber?.reloadData()
        onItemsCountChange?(totalObjectsCount())
        onInitialFetch?()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange sectionInfo: NSFetchedResultsSectionInfo,
                           atSectionIndex sectionIndex: Int,
                           for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            batchChanges.append(.sectionInsertion(sectionIndex + sectionOffset))
        case .delete:
            batchChanges.append(.sectionDeletion(sectionIndex + sectionOffset))
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
        case .delete:
            batchChanges.append(.deletion(indexPathWithOffset!))
        case .update:
            batchChanges.append(.update(indexPathWithOffset!))
        case .move:
            batchChanges.append(.move(indexPathWithOffset!, newIndexPathWithOffset!))
        }
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        subscriber?.prepareToProcessChanges()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onItemsCountChange?(totalObjectsCount())
        
        onBatchUpdatesStarted?()
        
        if let subscriber = self.subscriber {
            subscriber.processChanges(batchChanges) {
                self.batchChanges.forEach { self.onItemChange?($0) }
                self.batchChanges.removeAll()
                self.onBatchUpdatesCompleted?()
            }
        } else {
            self.batchChanges.forEach { self.onItemChange?($0) }
            self.batchChanges.removeAll()
            self.onBatchUpdatesCompleted?()
        }
    }

}

extension CacheObserver: CacheSubscribable {
    
    public func setSubscriber(_ subscriber: CacheSubscriber) {
        self.subscriber = subscriber
    }
    
}

extension CacheObserver: CacheObserverConfigurable {
    
    public func setSectionOffset(_ offset: Int) {
        self.sectionOffset = offset
    }
    
    public func setMapping(_ mapping: @escaping (NSManagedObject) -> T) {
        self.mapping = mapping
    }
    
    public func setActions(onInitialFetch: (() -> Void)?,
                           onItemsCountChange: ((Int) -> Void)?,
                           onItemChange: ((CoreDataChange) -> Void)?,
                           onBatchUpdatesStarted: (() -> Void)?,
                           onBatchUpdatesCompleted: (() -> Void)?) {
        self.onInitialFetch = onInitialFetch
        self.onItemsCountChange = onItemsCountChange
        self.onItemChange = onItemChange
        self.onBatchUpdatesStarted = onBatchUpdatesStarted
        self.onBatchUpdatesCompleted = onBatchUpdatesCompleted
    }
    
}

public extension CacheObserver {

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
    
    public func items(in section: Int) -> [T] {
        return fetchedResultsController.fetchedObjects?.compactMap { self.mapping($0 as! NSManagedObject) } ?? []
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
