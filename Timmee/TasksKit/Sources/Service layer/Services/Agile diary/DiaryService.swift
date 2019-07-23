//
//  DiaryService.swift
//  TasksKit
//
//  Created by i.kharabet on 23/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Foundation
import CoreData
import Workset

public protocol DiaryProvider: AnyObject {
    func fetchDiaryEntry(id: String) -> DiaryEntry?
    func fetchDiaryEntries(sprint: Sprint) -> [DiaryEntry]
    func fetchDiaryEntries(goal: Goal) -> [DiaryEntry]
    func fetchDiaryEntries(habit: Habit) -> [DiaryEntry]
}

public protocol DiaryEntitiesProvider: AnyObject {
    func fetchDiaryEntryEntity(id: String) -> DiaryEntryEntity?
}

public protocol DiaryEntitiesBackgroundProvider: AnyObject {
    func fetchDiaryEntryEntityInBackground(id: String) -> DiaryEntryEntity?
}

public protocol DiaryObserverProvider: AnyObject {
    func diaryEntriesObserver() -> CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry>
    func diaryEntriesObserver(habit: Habit) -> CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry>
    func diaryEntriesObserver(goal: Goal) -> CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry>
    func diaryEntriesObserver(sprint: Sprint) -> CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry>
}

public protocol DiaryManager: AnyObject {
    func createOrUpdateDiaryEntry(_ diaryEntry: DiaryEntry, completion: @escaping (Bool) -> Void)
    func createOrUpdateDiaryEntries(_ diaryEntries: [DiaryEntry], completion: @escaping (Bool) -> Void)
    func removeDiaryEntry(_ diaryEntry: DiaryEntry, completion: @escaping (Bool) -> Void)
    func removeDiaryEntries(_ diaryEntries: [DiaryEntry], completion: @escaping (Bool) -> Void)
}

public final class DiaryService {
    private let database = Database.localStorage
    
    private func createDiaryEntryEntity() -> DiaryEntryEntity {
        return DiaryEntryEntity(context: database.writeContext)
    }
}

extension DiaryService: DiaryProvider {
    
    public func fetchDiaryEntry(id: String) -> DiaryEntry? {
        return fetchDiaryEntryEntity(id: id).map { DiaryEntry(entity: $0) }
    }
    
    public func fetchDiaryEntries(habit: Habit) -> [DiaryEntry] {
        return DiaryEntryEntity.request()
            .filtered(predicate: DiaryEntry.Attachment.habit(id: habit.id).filteringPredicate)
            .sorted(keyPath: \DiaryEntryEntity.date, ascending: false)
            .execute()
            .map { DiaryEntry(entity: $0) }
    }
    
    public func fetchDiaryEntries(goal: Goal) -> [DiaryEntry] {
        return DiaryEntryEntity.request()
            .filtered(predicate: DiaryEntry.Attachment.goal(id: goal.id).filteringPredicate)
            .sorted(keyPath: \DiaryEntryEntity.date, ascending: false)
            .execute()
            .map { DiaryEntry(entity: $0) }
    }
    
    public func fetchDiaryEntries(sprint: Sprint) -> [DiaryEntry] {
        return DiaryEntryEntity.request()
            .filtered(predicate: DiaryEntry.Attachment.sprint(id: sprint.id).filteringPredicate)
            .sorted(keyPath: \DiaryEntryEntity.date, ascending: false)
            .execute()
            .map { DiaryEntry(entity: $0) }
    }
    
}

extension DiaryService: DiaryEntitiesProvider {
    
    public func fetchDiaryEntryEntity(id: String) -> DiaryEntryEntity? {
        return DiaryEntryEntity.request()
            .filtered(key: "id", value: id)
            .limited(value: 1)
            .execute()
            .first
    }
    
}

extension DiaryService: DiaryEntitiesBackgroundProvider {
    
    public func fetchDiaryEntryEntityInBackground(id: String) -> DiaryEntryEntity? {
        return DiaryEntryEntity.request()
            .filtered(key: "id", value: id)
            .limited(value: 1)
            .executeInBackground()
            .first
    }
    
}

extension DiaryService: DiaryObserverProvider {
    
    public func diaryEntriesObserver() -> CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry> {
        let request: NSFetchRequest<DiaryEntryEntity> = DiaryEntryEntity.request()
            .sorted(keyPath: \DiaryEntryEntity.date, ascending: false)
            .batchSize(20)
            .nsFetchRequest
        let context = Database.localStorage.readContext
        
        // TODO: Group by day???
        return CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry>(context: context,
                                                                    baseRequest: request,
                                                                    grouping: nil,
                                                                    mapping: { DiaryEntry(entity: $0) })
    }
    
    public func diaryEntriesObserver(habit: Habit) -> CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry> {
        let request: NSFetchRequest<DiaryEntryEntity> = DiaryEntryEntity.request()
            .filtered(predicate: DiaryEntry.Attachment.habit(id: habit.id).filteringPredicate)
            .sorted(keyPath: \DiaryEntryEntity.date, ascending: false)
            .batchSize(20)
            .nsFetchRequest
        let context = Database.localStorage.readContext
        
        // TODO: Group by day???
        return CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry>(context: context,
                                                                    baseRequest: request,
                                                                    grouping: nil,
                                                                    mapping: { DiaryEntry(entity: $0) })
    }
    
    public func diaryEntriesObserver(goal: Goal) -> CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry> {
        let request: NSFetchRequest<DiaryEntryEntity> = DiaryEntryEntity.request()
            .filtered(predicate: DiaryEntry.Attachment.goal(id: goal.id).filteringPredicate)
            .sorted(keyPath: \DiaryEntryEntity.date, ascending: false)
            .batchSize(20)
            .nsFetchRequest
        let context = Database.localStorage.readContext
        
        // TODO: Group by day???
        return CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry>(context: context,
                                                                    baseRequest: request,
                                                                    grouping: nil,
                                                                    mapping: { DiaryEntry(entity: $0) })
    }
    
    public func diaryEntriesObserver(sprint: Sprint) -> CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry> {
        let request: NSFetchRequest<DiaryEntryEntity> = DiaryEntryEntity.request()
            .filtered(predicate: DiaryEntry.Attachment.sprint(id: sprint.id).filteringPredicate)
            .sorted(keyPath: \DiaryEntryEntity.date, ascending: false)
            .batchSize(20)
            .nsFetchRequest
        let context = Database.localStorage.readContext
        
        // TODO: Group by day???
        return CachedEntitiesObserver<DiaryEntryEntity, DiaryEntry>(context: context,
                                                                    baseRequest: request,
                                                                    grouping: nil,
                                                                    mapping: { DiaryEntry(entity: $0) })
    }
    
}

extension DiaryService: DiaryManager {
    
    public func createOrUpdateDiaryEntry(_ diaryEntry: DiaryEntry, completion: @escaping (Bool) -> Void) {
        createOrUpdateDiaryEntries([diaryEntry], completion: completion)
    }
    
    public func createOrUpdateDiaryEntries(_ diaryEntries: [DiaryEntry], completion: @escaping (Bool) -> Void) {
        guard !diaryEntries.isEmpty else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        Database.localStorage.write({ (context, save) in
            diaryEntries.forEach { diaryEntry in
                let diaryEntryEntity = self.fetchDiaryEntryEntityInBackground(id: diaryEntry.id) ?? self.createDiaryEntryEntity()
                
                diaryEntryEntity.map(from: diaryEntry)
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
    public func removeDiaryEntry(_ diaryEntry: DiaryEntry, completion: @escaping (Bool) -> Void) {
        removeDiaryEntries([diaryEntry], completion: completion)
    }
    
    public func removeDiaryEntries(_ diaryEntries: [DiaryEntry], completion: @escaping (Bool) -> Void) {
        guard !diaryEntries.isEmpty else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        Database.localStorage.write({ (context, save) in
            diaryEntries.forEach { diaryEntry in
                guard let diaryEntryEntity = self.fetchDiaryEntryEntityInBackground(id: diaryEntry.id) else { return }
                context.delete(diaryEntryEntity)
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
}
