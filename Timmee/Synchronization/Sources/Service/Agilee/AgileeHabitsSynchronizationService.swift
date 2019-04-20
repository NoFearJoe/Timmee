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
    
    public static let shared = AgileeHabitsSynchronizationService()
    
    private let authorizationService = AuthorizationService()
    private let sprintsService = EntityServicesAssembly.shared.sprintsService
    private let habitsService = EntityServicesAssembly.shared.habitsService
    
    private let collectionSynchronizationManager = FirebaseCollectionSynchronizationManager()
    private let synchronizationAvailabilityChecker = SynchronizationAvailabilityChecker.shared
    
    private let syncQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private class SyncOperation: Operation {
        let operation: (@escaping () -> Void) -> Void

        override var isConcurrent: Bool { return false }
        override var isAsynchronous: Bool { return true }
        
        private var _isExecuting: Bool = false
        override var isExecuting: Bool {
            get { return _isExecuting }
            set {
                willChangeValue(for: \.isExecuting)
                _isExecuting = newValue
                didChangeValue(for: \.isExecuting)
            }
        }
        
        private var _isFinished: Bool = false
        override var isFinished: Bool {
            get { return _isFinished }
            set {
                willChangeValue(for: \.isFinished)
                _isFinished = newValue
                didChangeValue(for: \.isFinished)
            }
        }
        
        init(operation: @escaping (@escaping () -> Void) -> Void) {
            self.operation = operation
            super.init()
        }
        
        override func main() {
            guard !isCancelled else {
                isFinished = true
                isExecuting = false
                return
            }
            isExecuting = true
            operation { [weak self] in
                self?.isExecuting = false
                self?.isFinished = true
            }
        }
    }
    
    private init() {}
    
    public func setSynchronizationSuspended(_ isSuspended: Bool) {
        if isSuspended { syncQueue.cancelAllOperations() }
        syncQueue.isSuspended = isSuspended
    }
    
    public func sync(habit: Habit, sprintID: String, completion: @escaping (Bool) -> Void) {
        let operation = SyncOperation { [weak self] complete in
            guard let self = self, self.synchronizationAvailabilityChecker.synchronizationEnabled
            else { completion(false); complete(); return }
            
            self.pullHabit(habit, sprintID: sprintID) { [weak self] success, deleted in
                guard success else { completion(false); complete(); return }
                if deleted {
                    self?.deleteHabit(habit, sprintID: sprintID, completion: { success in
                        complete()
                        completion(success)
                    })
                } else {
                    self?.pushHabit(habit, sprintID: sprintID, completion: { success in
                        complete()
                        completion(success)
                    })
                }
            }
        }
        syncQueue.addOperation(operation)
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
                                    request: HabitEntity.request().filtered(key: "id", value: habit.id),
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
