//
//  DefaultStorage.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import SugarRecord
import class CoreData.NSManagedObjectContext

final class DefaultStorage {
    
    static let instance = DefaultStorage()
    
    lazy var storage: Storage = {
        let store = CoreDataStore.named("Timmee")
        let model = CoreDataObjectModel.merged(nil)
        return try! CoreDataDefaultStorage(store: store, model: model)
    }()
    
    lazy var iCloudStorage: Storage = {
        let model = CoreDataObjectModel.merged(nil)
        let config = CoreDataiCloudConfig(ubiquitousContentName: "",
                                          ubiquitousContentURL: "",
                                          ubiquitousContainerIdentifier: "")
        return try! CoreDataiCloudStorage(model: model, iCloud: config)
    }()
    
}

extension DefaultStorage {
    
    var mainContext: NSManagedObjectContext {
        return storage.mainContext as! NSManagedObjectContext
    }
    
}
