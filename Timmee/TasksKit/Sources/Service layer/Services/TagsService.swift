//
//  TagsService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSPredicate
import class Foundation.NSSortDescriptor
import class Foundation.DispatchQueue
import class CoreData.NSManagedObjectContext
import class CoreData.NSFetchRequest

public protocol TagsProvider: class {
    func fetchTags() -> [Tag]
}

public protocol TagEntitiesProvider: class {
    func fetchTagEntity(id: String) -> TagEntity?
}

public protocol TagEntitiesBackgroundProvider: class {
    func createTagEntity() -> TagEntity?
    func fetchTagEntityInBackground(id: String) -> TagEntity?
}

public protocol TagsManager: class {
    func createOrUpdateTag(_ tag: Tag, completion: (() -> Void)?)
    func removeTag(_ tag: Tag, completion: (() -> Void)?)
}

public final class TagsService {}

extension TagsService: TagsManager {

    public func createOrUpdateTag(_ tag: Tag, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingTag = self.fetchTagEntityInBackground(id: tag.id) {
                existingTag.map(from: tag)
            } else if let newTag = self.createTagEntity() {
                newTag.map(from: tag)
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
    public func removeTag(_ tag: Tag, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingTag = self.fetchTagEntityInBackground(id: tag.id) {
                context.delete(existingTag)
                
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
}

// MARK: - Fetch

extension TagsService: TagsProvider {
    
    public func fetchTags() -> [Tag] {
        return TagsService.tagsFetchRequest().execute().map { Tag(entity: $0) }
    }
    
}

// MARK: - Fetch entities

extension TagsService: TagEntitiesProvider {
    
    public func fetchTagEntity(id: String) -> TagEntity? {
        return TagsService.tagFetchRequest(id: id).execute().first
    }
    
}

// MARK: - Fetch entities in background

extension TagsService: TagEntitiesBackgroundProvider {
    
    public func createTagEntity() -> TagEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchTagEntityInBackground(id: String) -> TagEntity? {
        return TagsService.tagFetchRequest(id: id).executeInBackground().first
    }
    
}

// MARK: - Fetch reqeusts

private extension TagsService {
    
    static func tagFetchRequest(id: String) -> FetchRequest<TagEntity> {
        return TagEntity.request().filtered(key: "id", value: id)
    }
    
    static func tagsFetchRequest() -> FetchRequest<TagEntity> {
        return TagEntity.request().sorted(keyPath: \.title, ascending: true)
    }
    
}
