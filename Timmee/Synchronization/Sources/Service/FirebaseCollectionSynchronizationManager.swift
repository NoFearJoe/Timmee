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

final class FirebaseCollectionSynchronizationManager {
    
    @discardableResult
    func syncCollection<T: NSManagedObject & ModifiableEntity>(context: NSManagedObjectContext,
                                                               data: [[String: Any]],
                                                               entityType: T.Type,
                                                               request: FetchRequest<T> = T.request(),
                                                               parentEntityID: String?) -> [String] {
        let cachedEntities = request.execute(context: context)
        let locallyDeletedEntities = (LocallyDeletedEntity.request() as FetchRequest<LocallyDeletedEntity>).execute(context: context)
        var deletedEntityIDs: [String] = []
        if T.self is IdentifiableEntity.Type {
            let cachedEntitiesMap: [String: T] = cachedEntities
                .filter {
                    if let childEntity = $0 as? ChildEntity {
                        return childEntity.parent?.id == parentEntityID
                    }
                    return true
                }
            .dictionarised { entity -> String in
                (entity as! IdentifiableEntity).id ?? ""
            }
            
            let cachedEntitiesIDs = Set(cachedEntitiesMap.keys)
            
            let remoteEntitiesIDs = data.compactMap { $0["id"] as? String }
            
            let removedEntitiesIDs = Array(cachedEntitiesIDs.subtracting(remoteEntitiesIDs))
            let insertedEntitiesIDs = Array(Set(remoteEntitiesIDs).subtracting(cachedEntitiesIDs))
            let updatedEntitiesIDs = Array(cachedEntitiesIDs.intersection(remoteEntitiesIDs))
            
            removedEntitiesIDs.forEach { id in
                guard let cachedEntity = cachedEntitiesMap[id] else { return }
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
                    deletedEntityIDs.append(id)
                    removeNotificationsForRemovedEntity(entity: deletedEntity)
                    return
                }
                let entity = try? context.create() as T
                (entity as? DictionaryDecodable)?.decode(entityData)
                addRelationToParent(entity: entity, parentEntityID: parentEntityID, context: context)
                
                if let habit = entity as? HabitEntity {
                    addRelation(habit: habit, goalID: entityData["goalID"] as? String, context: context)
                }
                
                scheduleNotificationsForInsertedOrUpdatedEntity(entity: entity)
            }
            updatedEntitiesIDs.forEach { id in
                guard let cachedEntity = cachedEntitiesMap[id] else { return }
                guard let remoteEntityData = data.first(where: { ($0["id"] as? String) == id }) else { return }
                
                let remoteModificationDate = remoteEntityData["modificationDate"] as? TimeInterval ?? 0
                if cachedEntity.modificationDate < remoteModificationDate {
                    (cachedEntity as? DictionaryDecodable)?.decode(remoteEntityData)
                    
                    if let habit = cachedEntity as? HabitEntity {
                        addRelation(habit: habit, goalID: remoteEntityData["goalID"] as? String, context: context)
                    }
                    
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
    
    private func addRelation(habit: HabitEntity, goalID: String?, context: NSManagedObjectContext) {
        guard let goalID = goalID else { return }
        
        habit.goal = GoalEntity.request().execute(context: context).first(where: { $0.id == goalID })
    }
    
    private func scheduleNotificationsForInsertedOrUpdatedEntity<T: NSManagedObject>(entity: T?) {
        if let habitEntity = entity as? HabitEntity {
            let habit = Habit(habit: habitEntity)
            HabitsSchedulerService().scheduleHabit(habit)
        } else if let sprintEntity = entity as? SprintEntity {
            let sprint = Sprint(sprintEntity: sprintEntity)
            SprintSchedulerService().scheduleSprint(sprint)
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
        }
    }
    
}
