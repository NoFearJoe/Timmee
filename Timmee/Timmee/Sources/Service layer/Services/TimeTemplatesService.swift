//
//  TimeTemplatesService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 12.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSPredicate
import class Foundation.NSSortDescriptor
import class Foundation.DispatchQueue
import class CoreData.NSManagedObjectContext
import class CoreData.NSFetchRequest

final class TimeTemplatesService {}

extension TimeTemplatesService {
    
    func fetchTimeTemplates() -> [TimeTemplate] {
        let entities = fetch(with: timeTemplatesFetchRequest())
        return entities.map { TimeTemplate(entity: $0) }
    }
    
    func searchTimeTemplates(by string: String) -> [TimeTemplate] {
        let entities = fetch(with: timeTemplatesSearchRequest(string: string))
        return entities.map { TimeTemplate(entity: $0) }
    }
    
    private func fetch(with request: NSFetchRequest<TimeTemplateEntity>) -> [TimeTemplateEntity] {
        return (try? DefaultStorage.instance.database.readContext.fetch(request)) ?? []
    }
    
}

extension TimeTemplatesService {
    
    func createTimeTemplate() -> TimeTemplate {
        var date = Date()
        date => TimeRounder.roundMinutes(date.minutes).asMinutes
        return TimeTemplate(id: RandomStringGenerator.randomString(length: 12),
                            title: "",
                            time: (date.hours, date.minutes),
                            notification: .justInTime)
    }
    
    func createOrUpdateTimeTemplate(_ template: TimeTemplate, completion: (() -> Void)?) {
        DefaultStorage.instance.database.write({ (context, save) in
            if let existingTimeTemplate = context.fetchTimeTemplate(id: template.id) {
                existingTimeTemplate.map(from: template)
                save()
            } else if let newTimeTemplate = context.createTimeTemplate() {
                newTimeTemplate.map(from: template)
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
    
    func removeTimeTemplate(_ template: TimeTemplate, completion: (() -> Void)?) {
        DefaultStorage.instance.database.write({ (context, save) in
            if let existingTimeTemplate = context.fetchTimeTemplate(id: template.id) {
                context.delete(existingTimeTemplate)
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

private extension TimeTemplatesService {
    
    func timeTemplateFetchRequest(id: String) -> NSFetchRequest<TimeTemplateEntity> {
        let fetchRequest: NSFetchRequest<TimeTemplateEntity> = TimeTemplateEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return fetchRequest
    }
    
    func timeTemplatesFetchRequest() -> NSFetchRequest<TimeTemplateEntity> {
        let fetchRequest: NSFetchRequest<TimeTemplateEntity> = TimeTemplateEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return fetchRequest
    }
    
    func timeTemplatesSearchRequest(string: String) -> NSFetchRequest<TimeTemplateEntity> {
        let request = timeTemplatesFetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", string)
        return request
    }
    
}

extension NSManagedObjectContext {
    
    func fetchTimeTemplate(id: String) -> TimeTemplateEntity? {
        let request: NSFetchRequest<TimeTemplateEntity> = TimeTemplateEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        return (try? fetch(request))?.first
    }
    
    func createTimeTemplate() -> TimeTemplateEntity? {
        return try? create()
    }
    
}
