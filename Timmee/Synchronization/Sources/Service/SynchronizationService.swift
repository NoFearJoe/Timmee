//
//  SynchronizationService.swift
//  Synchronization
//
//  Created by i.kharabet on 23.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import CoreData
import TasksKit
import NotificationsKit
import Authorization
import FirebaseCore
import FirebaseFirestore

public protocol SynchronizationService: AnyObject {
    var synchronizationEnabled: Bool { get }
    func sync(completion: ((Bool) -> Void)?)
}

public final class AgileeSynchronizationService: SynchronizationService {
    
    public static let shared = AgileeSynchronizationService()
    
    public static func initializeSynchronization() {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    private let authorizationService = AuthorizationService()
    private let sprintsService = EntityServicesAssembly.shared.sprintsService
    private let habitsService = EntityServicesAssembly.shared.habitsService
    private let goalsService = EntityServicesAssembly.shared.goalsService
    private let waterControlService = EntityServicesAssembly.shared.waterControlService
    
    private var isSynchronizationInProgress = false
    
    private init() {}
    
    public var checkSynchronizationConditions: (() -> Bool)?
    
    public var synchronizationEnabled: Bool {
        return authorizationService.authorizedUser != nil && (checkSynchronizationConditions == nil || checkSynchronizationConditions?() == true)
    }
    
    public func sync(completion: ((Bool) -> Void)?) {
        guard synchronizationEnabled else { completion?(false); return }
        guard !isSynchronizationInProgress else { completion?(false); return }
        isSynchronizationInProgress = true
        pull { [weak self] success, deletedEntities in
            guard let self = self, success else { completion?(false); return }
            self.push(deletedEntities: deletedEntities, completion: { success in
                self.isSynchronizationInProgress = false
                completion?(success)
            })
        }
    }
    
}

private extension AgileeSynchronizationService {
    
    func pull(completion: @escaping (Bool, DeletedEntities) -> Void) {
        guard let user = authorizationService.authorizedUser else {
            completion(false, DeletedEntities())
            return
        }
        
        let userDocument = Firestore.firestore().collection("user").document("\(user.id)")
        
        let dispatchGroup = DispatchGroup()
        
        var synchronizationActions: [(NSManagedObjectContext) -> Void] = []
        
        var deletedEntities = DeletedEntities()
        
        dispatchGroup.enter() // Enter user document
        userDocument.getDocument { snapshot, error in
            if error != nil {
                completion(false, deletedEntities)
            } else {
                let sprintsCollection = userDocument.collection("sprints")
                dispatchGroup.enter() // Enter sprint document
                sprintsCollection.getDocuments(completion: { sprintSnapshot, error in
                    // Sprints save
                    synchronizationActions.append({ context in
                        deletedEntities.sprints = self.syncCollection(context: context,
                                                                      data: sprintSnapshot?.documents.map { $0.data() } ?? [],
                                                                      entityType: SprintEntity.self,
                                                                      parentEntityID: nil)
                    })
                    
                    sprintSnapshot?.documents.forEach { sprintSnapshot in
                        guard let sprintID = sprintSnapshot.data()["id"] as? String else { return }
                        let habitsCollection = sprintsCollection.document(sprintID).collection("habits")
                        dispatchGroup.enter() // Enter habits document
                        habitsCollection.getDocuments(completion: { habitsSnapshot, error in
                            // Habits save
                            synchronizationActions.append({ context in
                                let deletedHabitIDs = self.syncCollection(context: context,
                                                                          data: habitsSnapshot?.documents.map { $0.data() } ?? [],
                                                                          entityType: HabitEntity.self,
                                                                          parentEntityID: sprintID)
                                deletedEntities.habits.append((sprintID, deletedHabitIDs))
                            })
                            dispatchGroup.leave() // Leave habits document
                        })
                        
                        let goalsCollection = sprintsCollection.document(sprintID).collection("goals")
                        dispatchGroup.enter() // Enter goals document
                        goalsCollection.getDocuments(completion: { goalsSnapshot, error in
                            // Goals save
                            synchronizationActions.append({ context in
                                let deletedGoalIDs = self.syncCollection(context: context,
                                                                         data: goalsSnapshot?.documents.map { $0.data() } ?? [],
                                                                         entityType: GoalEntity.self,
                                                                         parentEntityID: sprintID)
                                deletedEntities.goals.append((sprintID, deletedGoalIDs))
                            })
                            
                            goalsSnapshot?.documents.forEach { goalSnapshot in
                                guard let goalID = goalSnapshot.data()["id"] as? String else { return }
                                let stagesCollection = goalsCollection.document(goalID).collection("stages")
                                dispatchGroup.enter() // Enter stages document
                                stagesCollection.getDocuments(completion: { stagesSnapshot, error in
                                    // Stages save
                                    synchronizationActions.append({ context in
                                        let deletedStageIDs = self.syncCollection(context: context,
                                                                                  data: stagesSnapshot?.documents.map { $0.data() } ?? [],
                                                                                  entityType: SubtaskEntity.self,
                                                                                  parentEntityID: goalID)
                                        deletedEntities.stages.append((sprintID, goalID, deletedStageIDs))
                                    })
                                    dispatchGroup.leave() // Leave stages document
                                })
                            }
                            
                            dispatchGroup.leave() // Leave goals document
                        })
                    }
                    
                    dispatchGroup.leave() // Leave sprint document
                })
                
                let waterControlDocument = userDocument.collection("water_control").document("water_control")
                dispatchGroup.enter() // Enter water control document
                waterControlDocument.getDocument(completion: { [weak self] snapshot, error in
                    guard let self = self else { return }
                    synchronizationActions.append({ context in
                        self.syncCollection(context: context,
                                            data: snapshot?.data().flatMap({ [$0] }) ?? [],
                                            entityType: WaterControlEntity.self,
                                            parentEntityID: nil)
                    })
                    dispatchGroup.leave() // Leave water control document
                })
                
                dispatchGroup.leave() // Leave user document
            }
            
            dispatchGroup.notify(queue: .main) {
                guard !synchronizationActions.isEmpty else {
                    completion(true, deletedEntities)
                    return
                }
                
                Database.localStorage.synchronize({ context, save in
                    synchronizationActions.forEach { action in
                        action(context)
                    }
                    save()
                }, completion: { success in
                    completion(success, deletedEntities)
                })
            }
        }
    }
    
    @discardableResult
    func syncCollection<T: NSManagedObject & ModifiableEntity>(context: NSManagedObjectContext,
                                                               data: [[String: Any]],
                                                               entityType: T.Type,
                                                               parentEntityID: String?) -> [String] {
        let cachedEntities = (T.request() as FetchRequest<T>).execute(context: context)
        let locallyDeletedEntities = (LocallyDeletedEntity.request() as FetchRequest<LocallyDeletedEntity>).execute(context: context)
        var deletedEntityIDs: [String] = []
        if T.self is IdentifiableEntity.Type {
            let cachedEntitiesIDs = cachedEntities.compactMap { ($0 as? IdentifiableEntity)?.id }
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
                id.map { deletedEntityIDs.append($0) }
                
                removeNotificationsForRemovedEntity(entity: cachedEntity)
            }
            insertedEntitiesIDs.forEach { id in
                guard let entityData = data.first(where: { ($0["id"] as? String) == id }) else { return }
                // Если существует сущность, помоченная как удаленная, то удаляем ее, а новую не добавляем
                if let deletedEntity = locallyDeletedEntities.first(where: { $0.entityType == T.entityName && $0.entityID == id }) {
                    context.delete(deletedEntity)
                    id.map { deletedEntityIDs.append($0) }
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
    
    func addRelationToParent(entity: NSManagedObject?, parentEntityID: String?, context: NSManagedObjectContext) {
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
    
    func scheduleNotificationsForInsertedOrUpdatedEntity<T: NSManagedObject>(entity: T?) {
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
        } else if entity is WaterControlEntity {
            WaterControlSchedulerService().removeWaterControlNotifications() {}
        }
    }
    
    func push(deletedEntities: DeletedEntities, completion: @escaping (Bool) -> Void) {
        guard let user = authorizationService.authorizedUser else {
            completion(false)
            return
        }
        
        let userDocument = Firestore.firestore().collection("user").document("\(user.id)")
            
        let batch = Firestore.firestore().batch()

        let sprints = self.sprintsService.fetchSprintEntitiesInBackground()
        
        sprints.forEach { sprint in
            guard let sprintID = sprint.id else { return }
            
            let sprintDocument = userDocument.collection("sprints").document(sprintID)
            
            batch.setData(sprint.encode(), forDocument: sprintDocument)
            
            let habitsCollection = sprintDocument.collection("habits")
            let habits = self.habitsService.fetchHabitEntitiesInBackground(sprintID: sprintID)
            habits.forEach { habit in
                guard let habitID = habit.id else { return }
                batch.setData(habit.encode(), forDocument: habitsCollection.document(habitID))
            }
            
            let goalsCollection = sprintDocument.collection("goals")
            let goals = self.goalsService.fetchGoalEntitiesInBackground(sprintID: sprintID)
            goals.forEach { goal in
                guard let goalID = goal.id else { return }
                batch.setData(goal.encode(), forDocument: goalsCollection.document(goalID))
                
                let stagesCollection = goalsCollection.document(goalID).collection("stages")
                
                if let stages = goal.stages.map({ Array($0) }) as? [SubtaskEntity] {
                    stages.forEach { stage in
                        guard let stageID = stage.id else { return }
                        batch.setData(stage.encode(), forDocument: stagesCollection.document(stageID))
                    }
                }
            }
        }
        
        if let waterControl = self.waterControlService.fetchWaterControlEntityInBakground() {
            let waterControlDocument = userDocument.collection("water_control").document("water_control")
            
            batch.setData(waterControl.encode(), forDocument: waterControlDocument)
        }
        
        pushDeletedEntities(deletedEntities, batch: batch, userDocument: userDocument)
        
        batch.commit { error in
            completion(error == nil)
        }
    }
    
    // TODO: Не удаляются вложенные объекты - если удалился спринт, то в deletedEntities не попадут привычки и цели...
    private func pushDeletedEntities(_ deletedEntities: DeletedEntities, batch: WriteBatch, userDocument: DocumentReference) {
        deletedEntities.sprints.forEach { sprintID in
            let sprintDocument = userDocument.collection("sprints").document(sprintID)
            batch.deleteDocument(sprintDocument)
        }
        
        deletedEntities.habits.forEach { sprintID, habits in
            let sprintDocument = userDocument.collection("sprints").document(sprintID)
            habits.forEach { habitID in
                batch.deleteDocument(sprintDocument.collection("habits").document(habitID))
            }
        }
        
        deletedEntities.goals.forEach { sprintID, goals in
            let sprintDocument = userDocument.collection("sprints").document(sprintID)
            goals.forEach { goalID in
                batch.deleteDocument(sprintDocument.collection("goals").document(goalID))
            }
        }
        
        deletedEntities.stages.forEach { sprintID, goalID, stages in
            let goalDocument = userDocument.collection("sprints").document(sprintID).collection("goals").document(goalID)
            stages.forEach { stageID in
                batch.deleteDocument(goalDocument.collection("stages").document(stageID))
            }
        }
    }
    
}

struct DeletedEntities {
    var sprints: [String] = []
    var habits: [(String, [String])] = []
    var goals: [(String, [String])] = []
    var stages: [(String, String, [String])] = []
}
