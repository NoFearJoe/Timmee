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

final class TagsService {}

extension TagsService {
    
    func fetchTags() -> [Tag] {
        let entities = fetch(with: tagsFetchRequest())
        return entities.map { Tag(entity: $0) }
    }
    
    func searchTags(by string: String) -> [Tag] {
        let entities = fetch(with: tagsSearchRequest(string: string))
        return entities.map { Tag(entity: $0) }
    }
    
    private func fetch(with request: NSFetchRequest<TagEntity>) -> [TagEntity] {
        return (try? DefaultStorage.instance.database.readContext.fetch(request)) ?? []
    }
    
}

extension TagsService {

    func createOrUpdateTag(_ tag: Tag, completion: (() -> Void)?) {
        DefaultStorage.instance.database.write({ (context, save) in
            if let existingTag = context.fetchTag(id: tag.id) {
                existingTag.map(from: tag)
                save()
            } else if let newTag = context.createTag() {
                newTag.map(from: tag)
                save()
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }) { _ in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func removeTag(_ tag: Tag, completion: (() -> Void)?) {
        DefaultStorage.instance.database.write({ (context, save) in
            if let existingTag = context.fetchTag(id: tag.id) {
                context.delete(existingTag)
                save()
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }) { _ in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
}

fileprivate extension TagsService {
    
    func tagFetchRequest(id: String) -> NSFetchRequest<TagEntity> {
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return fetchRequest
    }
    
    func tagsFetchRequest() -> NSFetchRequest<TagEntity> {
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return fetchRequest
    }
    
    func tagsSearchRequest(string: String) -> NSFetchRequest<TagEntity> {
        let request = tagsFetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", string)
        return request
    }
    
}

extension NSManagedObjectContext {
    
    func fetchTag(id: String) -> TagEntity? {
        let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        return (try? fetch(request))?.first
    }
    
    func createTag() -> TagEntity? {
        return try? create()
    }
    
}
