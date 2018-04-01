//
//  DefaultStorage.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import CoreData

final class DefaultStorage {
    
    static let instance = DefaultStorage()
    
    lazy var database: Database = CoreDataStorage()
    
}

protocol Database: class {
    var readContext: NSManagedObjectContext { get }
    var writeContext: NSManagedObjectContext { get }
    
    func write(_ operation: @escaping (_ context: NSManagedObjectContext,
                                       _ save: @escaping () -> Void) -> Void,
               completion: ((Bool) -> Void)?)
}

private final class CoreDataStorage: Database {
    
    lazy var readContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.rootContext
        return context
    }()
    
    lazy var writeContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.readContext
        return context
    }()
    
    private lazy var rootContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.coordinator
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()
    
}

// MARK: - Operations

extension CoreDataStorage {
    
    func write(_ operation: @escaping (NSManagedObjectContext, @escaping () -> Void) -> Void, completion: ((Bool) -> Void)?) {
        writeContext.perform {
            operation(self.writeContext, {
                self.save(completion: completion)
            })
        }
    }
    
}

// MARK: - Save

private extension CoreDataStorage {
    
    private func save(completion: ((Bool) -> Void)?) {
        save(context: writeContext, completion: completion)
    }
    
    private func save(context: NSManagedObjectContext, completion: ((Bool) -> Void)?) {
        guard context.hasChanges else {
            completion?(true)
            return
        }
        
        do {
            try context.save()
            
            if let parentContext = context.parent {
                save(context: parentContext, completion: completion)
            } else {
                completion?(true)
            }
        } catch {
            context.rollback()
            completion?(false)
        }
    }
    
}

private extension CoreDataStorage {
    
    var storeURL: URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentURL.appendingPathComponent("Timmee.sqlite")
    }
    
    var model: NSManagedObjectModel {
        let modelURL = Bundle.main.url(forResource: "Timmee", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
    
    var coordinator: NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                            configurationName: nil,
                                            at: self.storeURL,
                                            options: [NSMigratePersistentStoresAutomaticallyOption: true])
        return coordinator
    }
    
}
