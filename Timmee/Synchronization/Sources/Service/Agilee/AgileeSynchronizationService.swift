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

// TODO: Обработать ситуацию, когда после синхронизации может появиться несколько одинаковых спринтов (с одинаковыми number или пересекающимися startDate-endDate). Надо в этом случае либо предлагать пользователю выбрать актуальный спринт или смержить их

public final class AgileeSynchronizationService: SynchronizationService {
    
    public static let shared = AgileeSynchronizationService()
    
    public static func initializeSynchronization(firestore: FirebaseFirestoreProtocol) {
        Self.firestore = firestore
    }
    
    private static var firestore: FirebaseFirestoreProtocol!
    
    private let firestore: FirebaseFirestoreProtocol = AgileeSynchronizationService.firestore
    
    private let authorizationService = AuthorizationService()
    private let sprintsService = EntityServicesAssembly.shared.sprintsService
    private let habitsService = EntityServicesAssembly.shared.habitsService
    private let goalsService = EntityServicesAssembly.shared.goalsService
    private let diaryService = EntityServicesAssembly.shared.diaryService
    
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
        
        let userDocument = firestore._collection("user")._document("\(user.id)")
        
        let dispatchGroup = DispatchGroup()
        
        var synchronizationActions: [(NSManagedObjectContext) -> Void] = []
        
        var deletedEntities = DeletedEntities()
        
        dispatchGroup.enter() // Enter user document
        userDocument._getDocument { snapshot, error in
            defer { dispatchGroup.leave() }
            
            guard error == nil else { return }
            
            let sprintsCollection = userDocument._collection("sprints")
            
            dispatchGroup.enter() // Enter sprint document
            sprintsCollection._getDocuments(completion: { [weak self] sprintSnapshot, error in
                defer { dispatchGroup.leave() }
                
                guard
                    let self = self,
                    error == nil,
                    let data = sprintSnapshot?._documents.compactMap({ $0._data() })
                else { return }
                
                // Sprints save
                synchronizationActions.append({ context in
                    deletedEntities.sprints = self.collectionSynchronizationManager
                        .syncCollection(context: context,
                                        data: data,
                                        entityType: SprintEntity.self,
                                        parentEntityID: nil)
                })
                
                sprintSnapshot?._documents.forEach { sprintSnapshot in
                    guard let sprintID = sprintSnapshot._data()?["id"] as? String else { return }
                    
                    // Goals
                    let goalsCollection = sprintsCollection._document(sprintID)._collection("goals")
                    
                    dispatchGroup.enter() // Enter goals document
                    goalsCollection._getDocuments(completion: { [weak self] goalsSnapshot, error in
                        defer { dispatchGroup.leave() }
                        
                        guard
                            let self = self,
                            error == nil,
                            let data = goalsSnapshot?._documents.compactMap({ $0._data() })
                        else { return }
                        
                        // Goals save
                        synchronizationActions.append({ context in
                            let deletedGoalIDs = self.collectionSynchronizationManager
                                .syncCollection(context: context,
                                                data: data,
                                                entityType: GoalEntity.self,
                                                parentEntityID: sprintID)
                            if !deletedGoalIDs.isEmpty {
                                deletedEntities.goals.append((sprintID, deletedGoalIDs))
                            }
                        })
                        
                        goalsSnapshot?._documents.forEach { goalSnapshot in
                            guard let goalID = goalSnapshot._data()?["id"] as? String else { return }
                            
                            let stagesCollection = goalsCollection._document(goalID)._collection("stages")
                            
                            dispatchGroup.enter() // Enter stages document
                            stagesCollection._getDocuments(completion: { [weak self] stagesSnapshot, error in
                                defer { dispatchGroup.leave() }
                                
                                guard
                                    let self = self,
                                    error == nil,
                                    let data = stagesSnapshot?._documents.compactMap({ $0._data() })
                                else { return }
                                
                                // Stages save
                                synchronizationActions.append({ context in
                                    let deletedStageIDs = self.collectionSynchronizationManager
                                        .syncCollection(context: context,
                                                        data: data,
                                                        entityType: SubtaskEntity.self,
                                                        parentEntityID: goalID)
                                    if !deletedStageIDs.isEmpty {
                                        deletedEntities.stages.append((sprintID, goalID, deletedStageIDs))
                                    }
                                })
                            })
                        }
                    })
                    
                    // Habits
                    let habitsCollection = sprintsCollection._document(sprintID)._collection("habits")
                    
                    dispatchGroup.enter() // Enter habits document
                    habitsCollection._getDocuments(completion: { [weak self] habitsSnapshot, error in
                        defer { dispatchGroup.leave() }
                        
                        guard
                            let self = self,
                            error == nil,
                            let data = habitsSnapshot?._documents.compactMap({ $0._data() })
                        else { return }
                        
                        // Habits save
                        synchronizationActions.append({ context in
                            let deletedHabitIDs = self.collectionSynchronizationManager
                                .syncCollection(context: context,
                                                data: data,
                                                entityType: HabitEntity.self,
                                                parentEntityID: sprintID)
                            if !deletedHabitIDs.isEmpty {
                                deletedEntities.habits.append((sprintID, deletedHabitIDs))
                            }
                        })
                    })
                }
            })
            
            // Diary
            
            let diaryEntriesCollection = userDocument._collection("diary")
            
            dispatchGroup.enter() // Enter diary collection
            diaryEntriesCollection._getDocuments(completion: { [weak self] diaryEntriesSnapshot, error in
                defer { dispatchGroup.leave() }
                
                guard
                    let self = self,
                    error == nil,
                    let data = diaryEntriesSnapshot?._documents.compactMap({ $0._data() })
                else { return }
                
                synchronizationActions.append({ context in
                    self.collectionSynchronizationManager
                        .syncCollection(context: context,
                                        data: data,
                                        entityType: DiaryEntryEntity.self,
                                        parentEntityID: nil)
                })
            })
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
    
    func push(deletedEntities: DeletedEntities, completion: @escaping (Bool) -> Void) {
        guard let user = authorizationService.authorizedUser else {
            completion(false)
            return
        }
        
        let userDocument = firestore._collection("user")._document("\(user.id)")
            
        let batch = firestore._batch()

        // Sprints
        
        let sprints = self.sprintsService.fetchSprintEntitiesInBackground()
        
        sprints.forEach { sprint in
            guard let sprintID = sprint.id else { return }
            
            let sprintDocument = userDocument._collection("sprints")._document(sprintID)
            
            batch._setData(sprint.encode(), forDocument: sprintDocument)
            
            // Habits
            let habitsCollection = sprintDocument._collection("habits")
            let habits = self.habitsService.fetchHabitEntitiesInBackground(sprintID: sprintID)
            habits.forEach { habit in
                guard let habitID = habit.id else { return }
                batch._setData(habit.encode(), forDocument: habitsCollection._document(habitID))
            }
            
            // Goals
            let goalsCollection = sprintDocument._collection("goals")
            let goals = self.goalsService.fetchGoalEntitiesInBackground(sprintID: sprintID)
            goals.forEach { goal in
                guard let goalID = goal.id else { return }
                batch._setData(goal.encode(), forDocument: goalsCollection._document(goalID))
                
                let stagesCollection = goalsCollection._document(goalID)._collection("stages")
                
                if let stages = goal.stages.map({ Array($0) }) as? [SubtaskEntity] {
                    stages.forEach { stage in
                        guard let stageID = stage.id else { return }
                        batch._setData(stage.encode(), forDocument: stagesCollection._document(stageID))
                    }
                }
            }
        }
        
        // Diary
        
        let diaryEntryEntities = diaryService.fetchAllDiaryEntryEntitiesInBackground()
        let diaryEntriesCollection = userDocument._collection("diary")
        diaryEntryEntities.forEach { diaryEntry in
            guard let id = diaryEntry.id else { return }
            let diaryEntryDocument = diaryEntriesCollection._document(id)
            batch._setData(diaryEntry.encode(), forDocument: diaryEntryDocument)
        }
        
        pushDeletedEntities(deletedEntities, batch: batch, userDocument: userDocument)
        
        batch._commit { error in
            completion(error == nil)
        }
    }
    
    private func pushDeletedEntities(_ deletedEntities: DeletedEntities,
                                     batch: FirebaseFirestoreBatchProtocol,
                                     userDocument: FirebaseFirestoreDocumentProtocol) {
        guard !deletedEntities.isEmpty else { return }
        
        let dispatchGroup = DispatchGroup()
        
        deletedEntities.sprints.forEach { sprintID in
            let sprintDocument = userDocument._collection("sprints")._document(sprintID)
            batch._deleteDocument(sprintDocument)
            
            dispatchGroup.enter()
            sprintDocument._collection("habits")._getDocuments(completion: { documents, error in
                documents?._documents.forEach {
                    batch._deleteDocument($0._reference)
                }
                dispatchGroup.leave()
            })
            dispatchGroup.enter()
            sprintDocument._collection("goals")._getDocuments(completion: { documents, error in
                documents?._documents.forEach {
                    batch._deleteDocument($0._reference)
                    
                    dispatchGroup.enter()
                    $0._reference._collection("stages")._getDocuments(completion: { documents, error in
                        documents?._documents.forEach {
                            batch._deleteDocument($0._reference)
                        }
                        dispatchGroup.leave()
                    })
                }
                dispatchGroup.leave()
            })
        }
        
        deletedEntities.habits.forEach { sprintID, habits in
            let sprintDocument = userDocument._collection("sprints")._document(sprintID)
            habits.forEach { habitID in
                batch._deleteDocument(sprintDocument._collection("habits")._document(habitID))
            }
        }
        
        deletedEntities.goals.forEach { sprintID, goals in
            let sprintDocument = userDocument._collection("sprints")._document(sprintID)
            goals.forEach { goalID in
                let goalDocument = sprintDocument._collection("goals")._document(goalID)
                batch._deleteDocument(goalDocument)
                
                dispatchGroup.enter()
                goalDocument._collection("stages")._getDocuments(completion: { documents, error in
                    documents?._documents.forEach {
                        batch._deleteDocument($0._reference)
                    }
                    dispatchGroup.leave()
                })
            }
        }
        
        deletedEntities.stages.forEach { sprintID, goalID, stages in
            let goalDocument = userDocument._collection("sprints")._document(sprintID)._collection("goals")._document(goalID)
            stages.forEach { stageID in
                batch._deleteDocument(goalDocument._collection("stages")._document(stageID))
            }
        }
        
        deletedEntities.diaryEntries.forEach { diaryEntryID in
            let diaryEntryDocument = userDocument._collection("diary")._document(diaryEntryID)
            batch._deleteDocument(diaryEntryDocument)
        }
        
        dispatchGroup.wait()
    }
    
}

struct DeletedEntities {
    var sprints: [String] = []
    var habits: [(String, [String])] = []
    var goals: [(String, [String])] = []
    var stages: [(String, String, [String])] = []
    var diaryEntries: [String] = []
    
    var isEmpty: Bool {
        return sprints.isEmpty
            && habits.isEmpty
            && goals.isEmpty
            && stages.isEmpty
            && diaryEntries.isEmpty
    }
}
