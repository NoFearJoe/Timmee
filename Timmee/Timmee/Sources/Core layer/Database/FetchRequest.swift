//
//  FetchRequest.swift
//  Timmee
//
//  Created by i.kharabet on 04.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class CoreData.NSPredicate
import class CoreData.NSFetchRequest
import class CoreData.NSManagedObject
import class CoreData.NSManagedObjectContext
import protocol CoreData.NSFetchRequestResult
import class Foundation.NSSortDescriptor

final class FetchRequest<T: NSManagedObject> {
    
    private var predicate: NSPredicate?
    private var sortDescriptors: [NSSortDescriptor]?
    private var limit: Int?
    private var batchSize: Int = 0
    
}

extension FetchRequest {
    
    var nsFetchRequest: NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: T.entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let limit = limit {
            request.fetchLimit = limit
        }
        request.fetchBatchSize = batchSize
        return request
    }
    
    var nsCountFetchRequest: NSFetchRequest<T> {
        let request = nsFetchRequest
        request.resultType = .countResultType
        return request
    }
    
    var nsFetchRequestWithResult: NSFetchRequest<NSFetchRequestResult> {
        return nsFetchRequest as! NSFetchRequest<NSFetchRequestResult>
    }
    
}

extension FetchRequest {
   
    func execute() -> [T] {
        return (try? Database.localStorage.readContext.fetch(self.nsFetchRequest)) ?? []
    }
    
    func executeInBackground() -> [T] {
        return (try? Database.localStorage.writeContext.fetch(self.nsFetchRequest)) ?? []
    }
    
    func execute(context: NSManagedObjectContext) -> [T] {
        return (try? context.fetch(self.nsFetchRequest)) ?? []
    }
    
    // MARK: Count
    
    func count() -> Int {
        return (try? Database.localStorage.readContext.count(for: self.nsCountFetchRequest)) ?? 0
    }
    
    func countInBackground() -> Int {
        return (try? Database.localStorage.writeContext.count(for: self.nsCountFetchRequest)) ?? 0
    }
    
    func count(context: NSManagedObjectContext) -> Int {
        return (try? context.count(for: self.nsCountFetchRequest)) ?? 0
    }
    
}

// MARK: - Filters

extension FetchRequest {
    
    func filtered(predicate: NSPredicate?) -> FetchRequest<T> {
        self.predicate = predicate
        return self
    }
    
    func filtered(key: String, value: String) -> FetchRequest<T> {
        self.predicate = NSPredicate(format: "\(key) = %@", value)
        return self
    }
    
    func filtered(key: String, in array: [String]) -> FetchRequest<T> {
        self.predicate = NSPredicate(format: "\(key) IN %@", array)
        return self
    }
    
    func filtered(key: String, contains value: String) -> FetchRequest<T> {
        self.predicate = NSPredicate(format: "\(key) CONTAINS[cd] %@", value)
        return self
    }
    
}

// MARK: - Sorting

extension FetchRequest {
    
    func sorted(sortDescriptor: NSSortDescriptor) -> FetchRequest<T> {
        if let sortDescriptors = self.sortDescriptors {
            self.sortDescriptors = sortDescriptors + [sortDescriptor]
        } else {
            self.sortDescriptors = [sortDescriptor]
        }
        return self
    }
    
    func sorted(key: String, ascending: Bool) -> FetchRequest<T> {
        if let sortDescriptors = self.sortDescriptors {
            self.sortDescriptors = sortDescriptors + [NSSortDescriptor(key: key, ascending: ascending)]
        } else {
            self.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        }
        return self
    }
    
}

// MARK: - Limits

extension FetchRequest {
    
    func limited(value: Int) -> FetchRequest<T> {
        self.limit = value
        return self
    }
    
    func batchSize(_ size: Int) -> FetchRequest<T> {
        self.batchSize = size
        return self
    }
    
}
