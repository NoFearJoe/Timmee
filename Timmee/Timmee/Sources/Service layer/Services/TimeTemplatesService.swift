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

protocol TimeTemplatesProvider: class {
    func createTimeTemplate() -> TimeTemplate
    func fetchTimeTemplates() -> [TimeTemplate]
}

protocol TimeTemplateEntitiesProvider: class {
    func fetchTimeTemplateEntity(id: String) -> TimeTemplateEntity?
}

protocol TimeTemplateEntitiesBackgroundProvider: class {
    func createTimeTemplateEntity() -> TimeTemplateEntity?
    func fetchTimeTemplateEntityInBackground(id: String) -> TimeTemplateEntity?
}

protocol TimeTemplatesManager: class {
    func createOrUpdateTimeTemplate(_ template: TimeTemplate, completion: (() -> Void)?)
    func removeTimeTemplate(_ template: TimeTemplate, completion: (() -> Void)?)
}

final class TimeTemplatesService {}

extension TimeTemplatesService: TimeTemplatesManager {
    
    func createOrUpdateTimeTemplate(_ template: TimeTemplate, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingTimeTemplate = self.fetchTimeTemplateEntityInBackground(id: template.id) {
                existingTimeTemplate.map(from: template)
                save()
            } else if let newTimeTemplate = self.createTimeTemplateEntity() {
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
        Database.localStorage.write({ (context, save) in
            if let existingTimeTemplate = self.fetchTimeTemplateEntityInBackground(id: template.id) {
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

// MARK: - Fetch

extension TimeTemplatesService: TimeTemplatesProvider {
    
    func createTimeTemplate() -> TimeTemplate {
        var date = Date()
        date => TimeRounder.roundMinutes(date.minutes).asMinutes
        return TimeTemplate(id: RandomStringGenerator.randomString(length: 12),
                            title: "",
                            time: (date.hours, date.minutes),
                            notification: .justInTime)
    }
    
    func fetchTimeTemplates() -> [TimeTemplate] {
        return TimeTemplatesService.timeTemplatesFetchRequest().execute().map { TimeTemplate(entity: $0) }
    }
    
}

// MARK: - Fetch entities

extension TimeTemplatesService: TimeTemplateEntitiesProvider {
    
    func fetchTimeTemplateEntity(id: String) -> TimeTemplateEntity? {
        return TimeTemplatesService.timeTemplateFetchRequest(id: id).execute().first
    }
    
}

// MARK: - Fetch entities in background

extension TimeTemplatesService: TimeTemplateEntitiesBackgroundProvider {
    
    func createTimeTemplateEntity() -> TimeTemplateEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    func fetchTimeTemplateEntityInBackground(id: String) -> TimeTemplateEntity? {
        return TimeTemplatesService.timeTemplateFetchRequest(id: id).executeInBackground().first
    }
    
}

// MARK: - Fetch requests

private extension TimeTemplatesService {
    
    static func timeTemplatesFetchRequest() -> FetchRequest<TimeTemplateEntity> {
        return TimeTemplateEntity.request().sorted(key: "title", ascending: true)
    }
    
    static func timeTemplateFetchRequest(id: String) -> FetchRequest<TimeTemplateEntity> {
        return TimeTemplateEntity.request().filtered(key: "id", value: id)
    }
    
}
