//
//  AchievementsService.swift
//  TasksKit
//
//  Created by Илья Харабет on 31/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation
import Workset
import CoreData

public protocol AchievementEntitiesProvider: AnyObject {
    func fetchAchievementEntities() -> [AchievementEntity]
    func fetchAchievementEntitiesInBackground() -> [AchievementEntity]
}

public protocol AchievemntEntitiesManager: AnyObject {
    func createAchievementEntity() -> AchievementEntity
    func updateAchievement(update: @escaping () -> Void, completion: @escaping (Bool) -> Void)
    func removeAchievement(_ achievement: AchievementEntity, completion: @escaping (Bool) -> Void)
}

public protocol AchievementObserverProvider: AnyObject {
    func achievementsObserver() -> CacheObserver<AchievementEntity>
}

final class AchievementsService {}

extension AchievementsService: AchievementEntitiesProvider {
    
    func fetchAchievementEntities() -> [AchievementEntity] {
        Self.achievementsFetchRequest().execute()
    }
    
    func fetchAchievementEntitiesInBackground() -> [AchievementEntity] {
        Self.achievementsFetchRequest().executeInBackground()
    }
    
    func fetchAchievementEntity(id: String, context: NSManagedObjectContext) -> AchievementEntity? {
        Self.achievementFetchRequest(id: id).execute(context: context).first
    }
    
}

extension AchievementsService: AchievemntEntitiesManager {
    
    func createAchievementEntity() -> AchievementEntity {
        AchievementEntity(context: Database.localStorage.writeContext)
    }
    
    func updateAchievement(update: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        Database.localStorage.write({ context, save in
            update()
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
    func removeAchievement(_ achievement: AchievementEntity, completion: @escaping (Bool) -> Void) {
        Database.localStorage.write({ context, save in
            context.delete(achievement)
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
}

extension AchievementsService: AchievementObserverProvider {
    
    func achievementsObserver() -> CacheObserver<AchievementEntity> {
        let observer: CacheObserver<AchievementEntity>
        observer = CacheObserver(request: Self.achievementsFetchRequest().nsFetchRequestWithResult,
                                 section: nil,
                                 cacheName: nil,
                                 context: Database.localStorage.readContext)
        observer.setSectionOffset(0)
        return observer
    }
    
}

private extension AchievementsService {
    
    /// Запрос всех ачивок
    static func achievementsFetchRequest() -> FetchRequest<AchievementEntity> {
        return AchievementEntity.request().sorted(keyPath: \.receivingDate, ascending: false)
    }
    
    /// Запрос ачивки по id
    static func achievementFetchRequest(id: String) -> FetchRequest<AchievementEntity> {
        return AchievementEntity.request().filtered(key: "id", value: id)
    }
    
}
