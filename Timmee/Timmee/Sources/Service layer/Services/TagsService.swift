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
import class SugarRecord.CoreDataDefaultStorage
import struct SugarRecord.FetchRequest
import protocol SugarRecord.Context

final class TagsService {}

extension TagsService {
    
    func fetchTags() -> [Tag] {
        let entities = (try? DefaultStorage.instance.mainContext.fetch(tagsFetchRequest())) ?? []
        return entities.map { Tag(entity: $0) }
    }
    
}

extension TagsService {

    func createOrUpdateTag(_ tag: Tag, completion: (() -> Void)?) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
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
        }) { error in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func removeTag(_ tag: Tag, completion: (() -> Void)?) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            if let existingTag = context.fetchTag(id: tag.id) {
                try? context.remove(existingTag)
                save()
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }) { error in
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
    
}

extension Context {
    
    func fetchTag(id: String) -> TagEntity? {
        let request = FetchRequest<TagEntity>().filtered(with: "id", equalTo: id)
        return (try? fetch(request))?.first
    }
    
    func createTag() -> TagEntity? {
        return try? create()
    }
    
}
