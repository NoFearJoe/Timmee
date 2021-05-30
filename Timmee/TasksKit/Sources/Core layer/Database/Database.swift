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

public protocol Storage: AnyObject {
    var readContext: NSManagedObjectContext { get }
    var writeContext: NSManagedObjectContext { get }
    
    func write(_ operation: @escaping (_ context: NSManagedObjectContext,
                                       _ save: @escaping () -> Void) -> Void,
               completion: ((Bool) -> Void)?)
}

private final class CoreDataStorage: Storage {
    
    private let persistentContainer = makePersistentContainer(name: storeName, model: model)
    
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
    
    static var modelName: String {
        DatabaseConfiguration.shared.properties["database_model_name"] as! String
    }
    
    static var storeName: String {
        DatabaseConfiguration.shared.properties["database_name"] as! String
    }
    
    var storeConfiguration: String? {
        DatabaseConfiguration.shared.properties["database_configuration"] as? String
    }
    
    static var sharedGroup: String? {
        DatabaseConfiguration.shared.properties["database_shared_group"] as? String
    }
    
    func storeURL(name: String) -> URL {
        FilesService.URLs.documents!.appendingPathComponent(name)
    }
    
    static func sharedStoreURL(group: String) -> URL? {
        FilesService.URLs.shared(group: group)?.appendingPathComponent(storeName)
    }
    
    static var model: NSManagedObjectModel {
        let url = Bundle(for: CoreDataStorage.self).url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: url)!
    }
    
    static func makePersistentContainer(name: String, model: NSManagedObjectModel) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: name, managedObjectModel: model)
        
        if let group = sharedGroup, let sharedStoreURL = sharedStoreURL(group: group) {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: sharedStoreURL.appendingPathExtension("sqlite"))]
        }
        
        container.loadPersistentStores { _, error in
            if let error = error { assertionFailure(error.localizedDescription) }
        }
        
        return container
    }

    private static func makePersistentStoreOptions() -> [String: Any] {
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
