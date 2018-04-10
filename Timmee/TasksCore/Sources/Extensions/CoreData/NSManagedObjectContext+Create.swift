//
//  NSManagedObjectContext+Create.swift
//  Timmee
//
//  Created by Илья Харабет on 01.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class CoreData.NSManagedObject
import class CoreData.NSEntityDescription
import class CoreData.NSManagedObjectContext

public extension NSManagedObjectContext {
    
    public func create<T: NSManagedObject>() throws -> T {
        return NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as! T
    }
    
}
