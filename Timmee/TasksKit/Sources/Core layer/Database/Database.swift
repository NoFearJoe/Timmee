//
//  Database.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import CoreData
import CloudKit

public final class Database {
    
    public static let localStorage: Storage = CoreDataStorage()
    
}

public protocol Storage: class {
    var readContext: NSManagedObjectContext { get }
    var writeContext: NSManagedObjectContext { get }
    
    func write(_ operation: @escaping (_ context: NSManagedObjectContext,
                                       _ save: @escaping () -> Void) -> Void,
               completion: ((Bool) -> Void)?)
}

private final class CoreDataStorage: Storage {
    
    private lazy var persistentContainer = Self.makePersistentContainer(name: storeName, model: model)
    
    lazy var readContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = rootContext
        return context
    }()
    
    lazy var writeContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = readContext
        return context
    }()
    
    private lazy var rootContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    init() {
        guard let group = sharedGroup, let sharedStoreURL = sharedStoreURL(group: group) else { return }
        
        addPersistentStore(
            at: sharedStoreURL,
            configuration: storeConfiguration,
            coordinator: persistentContainer.persistentStoreCoordinator
        )
    }
    
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
    
    var modelName: String {
        DatabaseConfiguration.shared.properties["database_model_name"] as! String
    }
    
    var storeName: String {
        DatabaseConfiguration.shared.properties["database_name"] as! String
    }
    
    var storeConfiguration: String? {
        DatabaseConfiguration.shared.properties["database_configuration"] as? String
    }
    
    var sharedGroup: String? {
        DatabaseConfiguration.shared.properties["database_shared_group"] as? String
    }
    
    func storeURL(name: String) -> URL {
        FilesService.URLs.documents!.appendingPathComponent(name)
    }
    
    func sharedStoreURL(group: String) -> URL? {
        FilesService.URLs.shared(group: group)?.appendingPathComponent(storeName)
    }
    
    var model: NSManagedObjectModel {
        let url = Bundle(for: CoreDataStorage.self).url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: url)!
    }
    
    static func makePersistentContainer(name: String, model: NSManagedObjectModel) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: name, managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error { assertionFailure(error.localizedDescription) }
        }
        return container
    }
    
//    var coordinator: NSPersistentStoreCoordinator {
//        let coordinator = persistentContainer.persistentStoreCoordinator
//        if let group = sharedGroup, let sharedStoreURL = sharedStoreURL(group: group) {
//            migrateOldPersistentStore(to: sharedStoreURL, coordinator: coordinator)
//            addPersistentStore(at: sharedStoreURL, configuration: storeConfiguration, coordinator: coordinator)
//        } else {
//            addPersistentStore(at: storeURL(name: storeName), configuration: storeConfiguration, coordinator: coordinator)
//        }
//        return coordinator
//    }
//
    @discardableResult
    private func addPersistentStore(at url: URL, configuration: String?, coordinator: NSPersistentStoreCoordinator) -> NSPersistentStore? {
        try? coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: url,
            options: makePersistentStoreOptions()
        )
    }
//
//    private func migrateOldPersistentStore(to url: URL, coordinator: NSPersistentStoreCoordinator) {
//        guard FileManager.default.fileExists(atPath: storeURL(name: storeName).path) else { return }
//        if let oldPersistentStore = addPersistentStore(at: storeURL(name: storeName), configuration: storeConfiguration, coordinator: coordinator) {
//            let migratedPersistentStore = try? coordinator.migratePersistentStore(oldPersistentStore,
//                                                                                  to: url,
//                                                                                  options: makePersistentStoreOptions(),
//                                                                                  withType: NSSQLiteStoreType)
//            migratedPersistentStore.map { try? coordinator.remove($0) }
//            try? FileManager.default.removeItem(at: storeURL(name: storeName))
//        }
//    }
//
    private func makePersistentStoreOptions() -> [String: Any] {
        return [NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true,
                NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
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
