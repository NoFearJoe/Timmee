//
//  Database.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import CoreData

public final class Database {
    
    public static let localStorage: Storage = CoreDataStorage()
    
}

public protocol Storage: class {
    var readContext: NSManagedObjectContext { get }
    var writeContext: NSManagedObjectContext { get }
    
    func write(_ operation: @escaping (_ context: NSManagedObjectContext,
                                       _ save: @escaping () -> Void) -> Void,
               completion: ((Bool) -> Void)?)
    
    func deleteStorage()
}

private final class CoreDataStorage: Storage {
    
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

// MARK: - Delete storage

extension CoreDataStorage {
    
    func deleteStorage() {
        do {
            if let group = self.sharedGroup, let sharedStoreURL = self.sharedStoreURL(group: group) {
                try coordinator.destroyPersistentStore(at: sharedStoreURL, ofType: NSSQLiteStoreType, options: nil)
            } else {
                try coordinator.destroyPersistentStore(at: self.storeURL, ofType: NSSQLiteStoreType, options: nil)
            }
        } catch {
            print(error)
        }
    }
    
}

private extension CoreDataStorage {
    
    var storeName: String {
        return DatabaseConfiguration.shared.properties["database_name"] as! String
    }
    
    var storeConfiguration: String? {
        return DatabaseConfiguration.shared.properties["database_configuration"] as? String
    }
    
    var sharedGroup: String? {
        return DatabaseConfiguration.shared.properties["database_shared_group"] as? String
    }
    
    var storeURL: URL {
        return FilesService.URLs.documents!.appendingPathComponent(storeName)
    }
    
    func sharedStoreURL(group: String) -> URL? {
        return FilesService.URLs.shared(group: group)?.appendingPathComponent(storeName)
    }
    
    var model: NSManagedObjectModel {
        return NSManagedObjectModel.mergedModel(from: [Bundle(for: CoreDataStorage.self)])!
    }
    
    var coordinator: NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        if let group = self.sharedGroup, let sharedStoreURL = self.sharedStoreURL(group: group) {
            if let oldPersistentStore = coordinator.persistentStore(for: self.storeURL) {
                _ = try? coordinator.migratePersistentStore(oldPersistentStore,
                                                            to: sharedStoreURL,
                                                            options: nil,
                                                            withType: NSSQLiteStoreType)
            }
            _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                    configurationName: self.storeConfiguration,
                                                    at: sharedStoreURL,
                                                    options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                              NSInferMappingModelAutomaticallyOption: true,
                                                              NSSQLitePragmasOption: ["journal_mode": "DELETE"]])
        } else {
            _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                    configurationName: self.storeConfiguration,
                                                    at: self.storeURL,
                                                    options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                              NSInferMappingModelAutomaticallyOption: true,
                                                              NSSQLitePragmasOption: ["journal_mode": "DELETE"]])
        }
        return coordinator
    }
    
}

private class DatabaseConfiguration {
    
    static let shared = DatabaseConfiguration()
    
    let properties: [String: Any]
    
    init() {
        guard let plistURL = Bundle.main.url(forResource: "TasksKitConfiguration", withExtension: "plist") else {
            fatalError("Файл Database.plist не найден")
        }
        guard let data = try? Data(contentsOf: plistURL) else {
            fatalError("Файл Database.plist имеет неверный формат")
        }
        guard let properties = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: Any] else {
            fatalError("Файл Database.plist имеет неверный формат")
        }
        
        self.properties = properties
    }
    
}
