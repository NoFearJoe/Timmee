//
//  MoodService.swift
//  TasksKit
//
//  Created by i.kharabet on 19.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Workset
import struct Foundation.Date
import class Foundation.NSPredicate
import class Foundation.NSSortDescriptor
import class Foundation.DispatchQueue
import class CoreData.NSManagedObjectContext
import class CoreData.NSFetchRequest

public protocol MoodProvider: class {
    func createMood() -> Mood
    func fetchMood(date: Date) -> Mood?
    func fetchAllMoods() -> [Mood]
    func fetchMoods(sprint: Sprint) -> [Mood]
}

public protocol MoodEntityBackgroundProvider: class {
    func createMoodEntity() -> MoodEntity?
    func fetchMoodEntityInBakground(date: Date) -> MoodEntity?
    func fetchAllMoodEntitiesInBackground() -> [MoodEntity]
}

public protocol MoodManager: class {
    func createOrUpdateMood(_ mood: Mood, completion: (() -> Void)?)
    func removeMood(mood: Mood, completion: (() -> Void)?)
}

public final class MoodService {}

extension MoodService: MoodProvider {
    public func createMood() -> Mood {
        return Mood(kind: .normal, date: Date())
    }
    
    public func fetchMood(date: Date) -> Mood? {
        return MoodService.moodEntityFetchRequest(date: date).execute().map { Mood(entity: $0) }.first
    }
    
    public func fetchAllMoods() -> [Mood] {
        return MoodService.allMoodEntitiesFetchRequest().execute().map { Mood(entity: $0) }
    }
    
    public func fetchMoods(sprint: Sprint) -> [Mood] {
        return MoodService.moodEntitiesFetchRequest(sprint: sprint).execute().map { Mood(entity: $0) }
    }
}

extension MoodService: MoodEntityBackgroundProvider {
    public func createMoodEntity() -> MoodEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchMoodEntityInBakground(date: Date) -> MoodEntity? {
        return MoodService.moodEntityFetchRequest(date: date).executeInBackground().first
    }
    
    public func fetchAllMoodEntitiesInBackground() -> [MoodEntity] {
        return MoodService.allMoodEntitiesFetchRequest().executeInBackground()
    }
}

extension MoodService: MoodManager {
    public func createOrUpdateMood(_ mood: Mood, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let existingMoodEntity = self.fetchMoodEntityInBakground(date: mood.date) {
                existingMoodEntity.map(from: mood)
                save()
            } else if let newMoodEntity = self.createMoodEntity() {
                newMoodEntity.map(from: mood)
                save()
            } else {
                DispatchQueue.main.async { completion?() }
            }
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
    
    public func removeMood(mood: Mood, completion: (() -> Void)?) {
        Database.localStorage.write({ (context, save) in
            if let moodEntity = self.fetchMoodEntityInBakground(date: mood.date) {
                context.delete(moodEntity)
                save()
            } else {
                DispatchQueue.main.async { completion?() }
            }
        }) { _ in
            DispatchQueue.main.async { completion?() }
        }
    }
}

private extension MoodService {
    static func moodEntityFetchRequest(date: Date) -> FetchRequest<MoodEntity> {
        return MoodEntity.request().filtered(predicate: NSPredicate(format: "date == %@", date as NSDate)).limited(value: 1)
    }
    
    static func allMoodEntitiesFetchRequest() -> FetchRequest<MoodEntity> {
        return MoodEntity.request().sorted(keyPath: \MoodEntity.date, ascending: true)
    }
    
    static func moodEntitiesFetchRequest(sprint: Sprint) -> FetchRequest<MoodEntity> {
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", sprint.startDate as NSDate, sprint.endDate as NSDate)
        return MoodEntity.request()
            .filtered(predicate: predicate)
            .sorted(keyPath: \MoodEntity.date, ascending: true)
    }
}
