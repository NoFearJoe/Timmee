//
//  AgileeSynchronizationService.swift
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

// TODO: Обработать ситуацию, когда после синхронизации может появиться несколько одинаковых спринтов (с одинаковыми number или пересекающимися startDate-endDate). Надо в этом случае либо предлагать пользователю выбрать актуальный спринт или смержить их

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
    
    private let collectionSynchronizationManager = FirebaseCollectionSynchronizationManager()
    private let synchronizationAvailabilityChecker = SynchronizationAvailabilityChecker.shared
    
    private var isSynchronizationInProgress = false
    
    private init() {}
    
    public func sync(completion: ((Bool) -> Void)?) {
        guard synchronizationAvailabilityChecker.synchronizationEnabled else { completion?(false); return }
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
                        deletedEntities.sprints = self.collectionSynchronizationManager
                            .syncCollection(context: context,
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
                                let deletedHabitIDs = self.collectionSynchronizationManager
                                    .syncCollection(context: context,
                                                    data: habitsSnapshot?.documents.map { $0.data() } ?? [],
                                                    entityType: HabitEntity.self,
                                                    parentEntityID: sprintID)
                                if !deletedHabitIDs.isEmpty {
                                    deletedEntities.habits.append((sprintID, deletedHabitIDs))
                                }
                            })
                            dispatchGroup.leave() // Leave habits document
                        })
                        
                        let goalsCollection = sprintsCollection.document(sprintID).collection("goals")
                        dispatchGroup.enter() // Enter goals document
                        
                        goalsCollection.getDocuments(completion: { goalsSnapshot, error in
                            // Goals save
                            synchronizationActions.append({ context in
                                let deletedGoalIDs = self.collectionSynchronizationManager
                                    .syncCollection(context: context,
                                                    data: goalsSnapshot?.documents.map { $0.data() } ?? [],
                                                    entityType: GoalEntity.self,
                                                    parentEntityID: sprintID)
                                if !deletedGoalIDs.isEmpty {
                                    deletedEntities.goals.append((sprintID, deletedGoalIDs))
                                }
                            })
                            
                            goalsSnapshot?.documents.forEach { goalSnapshot in
                                guard let goalID = goalSnapshot.data()["id"] as? String else { return }
                                let stagesCollection = goalsCollection.document(goalID).collection("stages")
                                dispatchGroup.enter() // Enter stages document
                                stagesCollection.getDocuments(completion: { stagesSnapshot, error in
                                    // Stages save
                                    synchronizationActions.append({ context in
                                        let deletedStageIDs = self.collectionSynchronizationManager
                                            .syncCollection(context: context,
                                                            data: stagesSnapshot?.documents.map { $0.data() } ?? [],
                                                            entityType: SubtaskEntity.self,
                                                            parentEntityID: goalID)
                                        if !deletedStageIDs.isEmpty {
                                            deletedEntities.stages.append((sprintID, goalID, deletedStageIDs))
                                        }
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
                        self.collectionSynchronizationManager
                            .syncCollection(context: context,
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
    
    private func pushDeletedEntities(_ deletedEntities: DeletedEntities, batch: WriteBatch, userDocument: DocumentReference) {
        let dispatchGroup = DispatchGroup()
        
        deletedEntities.sprints.forEach { sprintID in
            let sprintDocument = userDocument.collection("sprints").document(sprintID)
            batch.deleteDocument(sprintDocument)
            
            dispatchGroup.enter()
            sprintDocument.collection("habits").getDocuments(completion: { documents, error in
                documents?.documents.forEach {
                    batch.deleteDocument($0.reference)
                }
                dispatchGroup.leave()
            })
            dispatchGroup.enter()
            sprintDocument.collection("goals").getDocuments(completion: { documents, error in
                documents?.documents.forEach {
                    batch.deleteDocument($0.reference)
                    
                    dispatchGroup.enter()
                    $0.reference.collection("stages").getDocuments(completion: { documents, error in
                        documents?.documents.forEach {
                            batch.deleteDocument($0.reference)
                        }
                        dispatchGroup.leave()
                    })
                }
                dispatchGroup.leave()
            })
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
                let goalDocument = sprintDocument.collection("goals").document(goalID)
                batch.deleteDocument(goalDocument)
                
                dispatchGroup.enter()
                goalDocument.collection("stages").getDocuments(completion: { documents, error in
                    documents?.documents.forEach {
                        batch.deleteDocument($0.reference)
                    }
                    dispatchGroup.leave()
                })
            }
        }
        
        deletedEntities.stages.forEach { sprintID, goalID, stages in
            let goalDocument = userDocument.collection("sprints").document(sprintID).collection("goals").document(goalID)
            stages.forEach { stageID in
                batch.deleteDocument(goalDocument.collection("stages").document(stageID))
            }
        }
        
        dispatchGroup.wait()
    }
    
}

struct DeletedEntities {
    var sprints: [String] = []
    var habits: [(String, [String])] = []
    var goals: [(String, [String])] = []
    var stages: [(String, String, [String])] = []
}
