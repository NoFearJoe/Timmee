//
//  AgileeHabitsSynchronizationService.swift
//  Synchronization
//
//  Created by i.kharabet on 06.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import CoreData
import TasksKit
import Authorization
import NotificationsKit
import FirebaseCore
import FirebaseFirestore

public final class AgileeHabitsSynchronizationService {
    
    private let authorizationService = AuthorizationService()
    private let sprintsService = EntityServicesAssembly.shared.sprintsService
    private let habitsService = EntityServicesAssembly.shared.habitsService
    
    private let collectionSynchronizationManager = FirebaseCollectionSynchronizationManager()
    private let synchronizationAvailabilityChecker = SynchronizationAvailabilityChecker.shared
    
    public func sync(habit: Habit, sprintID: String, completion: @escaping (Bool) -> Void) {
        guard synchronizationAvailabilityChecker.synchronizationEnabled else { completion(false); return }
        
        pullHabit(habit, sprintID: sprintID) { [weak self] success, deleted in
            guard success else { completion(false); return }
            if deleted {
                self?.deleteHabit(habit, sprintID: sprintID, completion: completion)
            } else {
                self?.pushHabit(habit, sprintID: sprintID, completion: completion)
            }
        }
    }
    
    private func pullHabit(_ habit: Habit, sprintID: String, completion: @escaping (Bool, _ isDeleted: Bool) -> Void) {
        guard let user = authorizationService.authorizedUser else {
            completion(false, false)
            return
        }
        
        let sprintsCollection = Firestore.firestore().collection("user").document("\(user.id)").collection("sprints")
        let habitDocument = sprintsCollection.document(sprintID).collection("habits").document("\(habit.id)")
        habitDocument.getDocument { snapshot, error in
            var isDeleted: Bool = false
            Database.localStorage.synchronize({ context, save in
                let deletedHabitIDs = self.collectionSynchronizationManager
                    .syncCollection(context: context,
                                    data: snapshot?.data().map { [$0] } ?? [],
                                    entityType: HabitEntity.self,
                                    parentEntityID: sprintID)
                isDeleted = !deletedHabitIDs.isEmpty
                save()
            }, completion: { success in
                completion(success, isDeleted)
            })
        }
    }
    
    private func pushHabit(_ habit: Habit, sprintID: String, completion: @escaping (Bool) -> Void) {
        guard let user = authorizationService.authorizedUser,
              let habitEntity = habitsService.fetchHabitEntityInBackground(id: habit.id)
        else {
            completion(false)
            return
        }
        
        let sprintsCollection = Firestore.firestore().collection("user").document("\(user.id)").collection("sprints")
        let habitDocument = sprintsCollection.document(sprintID).collection("habits").document("\(habit.id)")
        
        habitDocument.setData(habitEntity.encode()) { error in
            completion(error == nil)
        }
    }
    
    private func deleteHabit(_ habit: Habit, sprintID: String, completion: @escaping (Bool) -> Void) {
        guard let user = authorizationService.authorizedUser else {
            completion(false)
            return
        }
        
        let sprintsCollection = Firestore.firestore().collection("user").document("\(user.id)").collection("sprints")
        let habitDocument = sprintsCollection.document(sprintID).collection("habits").document("\(habit.id)")
        
        habitDocument.delete { error in
            completion(error == nil)
        }
    }
    
}
