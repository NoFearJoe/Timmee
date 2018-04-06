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

protocol TagsProvider: class {
    func fetchTags() -> [Tag]
}

protocol TagEntitiesProvider: class {
    func fetchTagEntity(id: String) -> TagEntity?
}

protocol TagEntitiesBackgroundProvider: class {
    func createTagEntity() -> TagEntity?
    func fetchTagEntityInBackground(id: String) -> TagEntity?
}

protocol TagsManager: class {
    func createOrUpdateTag(_ tag: Tag, completion: (() -> Void)?)
    func removeTag(_ tag: Tag, completion: (() -> Void)?)
}

final class TagsService {}

extension TagsService: TagsManager {

    func createOrUpdateTag(_ tag: Tag, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingTag = self.fetchTagEntityInBackground(id: tag.id) {
                existingTag.map(from: tag)
            } else if let newTag = self.createTagEntity() {
                newTag.map(from: tag)
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func removeTag(_ tag: Tag, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingTag = self.fetchTagEntityInBackground(id: tag.id) {
                context.delete(existingTag)
                
            }
            
            save()
        }) { _ in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
}

// MARK: - Fetch

extension TagsService: TagsProvider {
    
    func fetchTags() -> [Tag] {
        return TagsService.tagsFetchRequest().execute().map { Tag(entity: $0) }
    }
    
}

// MARK: - Fetch entities

extension TagsService: TagEntitiesProvider {
    
    func fetchTagEntity(id: String) -> TagEntity? {
        return TagsService.tagFetchRequest(id: id).execute().first
    }
    
}

// MARK: - Fetch entities in background

extension TagsService: TagEntitiesBackgroundProvider {
    
    func createTagEntity() -> TagEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    func fetchTagEntityInBackground(id: String) -> TagEntity? {
        return TagsService.tagFetchRequest(id: id).executeInBackground().first
    }
    
}

// MARK: - Fetch reqeusts

private extension TagsService {
    
    static func tagFetchRequest(id: String) -> FetchRequest<TagEntity> {
        return TagEntity.request().filtered(key: "id", value: id)
    }
    
    static func tagsFetchRequest() -> FetchRequest<TagEntity> {
        return TagEntity.request().sorted(key: "title", ascending: true)
    }
    
}
