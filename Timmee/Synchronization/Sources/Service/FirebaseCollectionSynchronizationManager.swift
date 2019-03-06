//
//  FirebaseCollectionSynchronizationManager.swift
//  Synchronization
//
//  Created by i.kharabet on 06.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import CoreData
import TasksKit
import NotificationsKit
import FirebaseCore
import FirebaseFirestore

final class FirebaseCollectionSynchronizationManager {
    
    @discardableResult
    func syncCollection<T: NSManagedObject & ModifiableEntity>(context: NSManagedObjectContext,
                                                               data: [[String: Any]],
                                                               entityType: T.Type,
                                                               parentEntityID: String?) -> [String] {
        let cachedEntities = (T.request() as FetchRequest<T>).execute(context: context)
        let locallyDeletedEntities = (LocallyDeletedEntity.request() as FetchRequest<LocallyDeletedEntity>).execute(context: context)
        var deletedEntityIDs: [String] = []
        if T.self is IdentifiableEntity.Type {
            let cachedEntitiesIDs = cachedEntities
                .filter {
                    if let childEntity = $0 as? ChildEntity {
                        return childEntity.parent?.id == parentEntityID
                    }
                    return true
                }
                .compactMap { ($0 as? IdentifiableEntity)?.id }
            let remoteEntitiesIDs = data.map { $0["id"] as? String }
            
            let removedEntitiesIDs = Array(Set(cachedEntitiesIDs).subtracting(remoteEntitiesIDs))
            let insertedEntitiesIDs = Array(Set(remoteEntitiesIDs).subtracting(cachedEntitiesIDs))
            let updatedEntitiesIDs = Array(Set(cachedEntitiesIDs).intersection(remoteEntitiesIDs))
            
            removedEntitiesIDs.forEach { id in
                guard let cachedEntity = cachedEntities.first(where: { ($0 as? IdentifiableEntity)?.id == id }) else { return }
                // Если сущность синхронизирована, значит ее удалили, иначе - добавили
                if let deletedEntity = locallyDeletedEntities.first(where: { $0.entityType == T.entityName && $0.entityID == id }) {
                    context.delete(deletedEntity)
                }
                guard let syncableEntity = cachedEntity as? SyncableEntity, syncableEntity.isSynced else { return }
                context.delete(cachedEntity)
                
                removeNotificationsForRemovedEntity(entity: cachedEntity)
            }
            insertedEntitiesIDs.forEach { id in
                guard let entityData = data.first(where: { ($0["id"] as? String) == id }) else { return }
                // Если существует сущность, помоченная как удаленная, то удаляем ее, а новую не добавляем
                if let deletedEntity = locallyDeletedEntities.first(where: { $0.entityType == T.entityName && $0.entityID == id }) {
                    context.delete(deletedEntity)
                    id.map { deletedEntityIDs.append($0) }
                    removeNotificationsForRemovedEntity(entity: deletedEntity)
                    return
                }
                let entity = try? context.create() as T
                (entity as? DictionaryDecodable)?.decode(entityData)
                addRelationToParent(entity: entity, parentEntityID: parentEntityID, context: context)
                
                scheduleNotificationsForInsertedOrUpdatedEntity(entity: entity)
            }
            updatedEntitiesIDs.forEach { id in
                guard let cachedEntity = cachedEntities.first(where: { ($0 as? IdentifiableEntity)?.id == id }) else { return }
                guard let remoteEntityData = data.first(where: { ($0["id"] as? String) == id }) else { return }
                
                let remoteModificationDate = remoteEntityData["modificationDate"] as? TimeInterval ?? 0
                if cachedEntity.modificationDate < remoteModificationDate {
                    (cachedEntity as? DictionaryDecodable)?.decode(remoteEntityData)
                    scheduleNotificationsForInsertedOrUpdatedEntity(entity: cachedEntity)
                }
            }
        } else {
            if let cachedEntity = cachedEntities.first {
                if let remoteEntityData = data.first {
                    // Modified
                    let remoteModificationDate = remoteEntityData["modificationDate"] as? TimeInterval ?? 0
                    if cachedEntity.modificationDate < remoteModificationDate {
                        (cachedEntity as? DictionaryDecodable)?.decode(remoteEntityData)
                        scheduleNotificationsForInsertedOrUpdatedEntity(entity: cachedEntity)
                    }
                } else {
                    // Removed
                    if let deletedEntity = locallyDeletedEntities.first(where: { $0.entityType == T.entityName }) {
                        context.delete(deletedEntity)
                    }
                    guard let syncableEntity = cachedEntity as? SyncableEntity, syncableEntity.isSynced else { return deletedEntityIDs }
                    context.delete(cachedEntity)
                    removeNotificationsForRemovedEntity(entity: cachedEntity)
                }
            } else if let firstEntityData = data.first {
                // Inserted
                if let deletedEntity = locallyDeletedEntities.first(where: { $0.entityType == T.entityName }) {
                    context.delete(deletedEntity)
                    return deletedEntityIDs
                }
                let entity = try? context.create() as T
                (entity as? DictionaryDecodable)?.decode(firstEntityData)
                addRelationToParent(entity: entity, parentEntityID: parentEntityID, context: context)
                scheduleNotificationsForInsertedOrUpdatedEntity(entity: entity)
            }
        }
        
        return deletedEntityIDs
    }
    
    private func addRelationToParent(entity: NSManagedObject?, parentEntityID: String?, context: NSManagedObjectContext) {
        guard let entity = entity, let parentEntityID = parentEntityID else { return }
        switch entity {
        case let subtask as SubtaskEntity:
            subtask.goal = GoalEntity.request().execute(context: context).first(where: { $0.id == parentEntityID })
        case let goal as GoalEntity:
            goal.sprint = SprintEntity.request().execute(context: context).first(where: { $0.id == parentEntityID })
        case let habit as HabitEntity:
            habit.sprint = SprintEntity.request().execute(context: context).first(where: { $0.id == parentEntityID })
        default: return
        }
    }
    
    private func scheduleNotificationsForInsertedOrUpdatedEntity<T: NSManagedObject>(entity: T?) {
        if let habitEntity = entity as? HabitEntity {
            let habit = Habit(habit: habitEntity)
            HabitsSchedulerService().scheduleHabit(habit)
        } else if let sprintEntity = entity as? SprintEntity {
            let sprint = Sprint(sprintEntity: sprintEntity)
            SprintSchedulerService().scheduleSprint(sprint)
        } else if let waterControlEntity = entity as? WaterControlEntity {
            let waterControl = WaterControl(entity: waterControlEntity)
            let existingSprints = ServicesAssembly.shared.sprintsService.fetchSprints()
            let currentSprint = existingSprints.first(where: { sprint in
                sprint.startDate <= Date().startOfDay && sprint.endDate >= Date().endOfDay
            })
            if let currentSprint = currentSprint {
                WaterControlSchedulerService().scheduleWaterControl(waterControl,
                                                                    startDate: currentSprint.startDate,
                                                                    endDate: currentSprint.endDate)
            }
        }
    }
    
    func removeNotificationsForRemovedEntity<T: NSManagedObject>(entity: T?) {
        if let habitEntity = entity as? HabitEntity {
            let habit = Habit(habit: habitEntity)
            HabitsSchedulerService().removeNotifications(for: habit) {}
            HabitsSchedulerService().removeDeferredNotifications(for: habit) {}
        } else if let sprintEntity = entity as? SprintEntity {
            let sprint = Sprint(sprintEntity: sprintEntity)
            SprintSchedulerService().removeSprintNotifications(sprint: sprint) {}
            // TODO: Remove notifications for habits
        } else if entity is WaterControlEntity {
            WaterControlSchedulerService().removeWaterControlNotifications() {}
        }
    }
    
}
