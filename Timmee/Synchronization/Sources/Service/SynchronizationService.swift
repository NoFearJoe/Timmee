//
//  SynchronizationService.swift
//  Synchronization
//
//  Created by i.kharabet on 23.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit
import Authorization
import FirebaseCore
import FirebaseFirestore

public final class SynchronizationService {
    
    public static let shared = SynchronizationService()
    
    public static func initializeSynchronization() {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    private let authorizationService = AuthorizationService()
    private let sprintsService = EntityServicesAssembly.shared.sprintsService
    private let habitsService = EntityServicesAssembly.shared.habitsService
    private let goalsService = EntityServicesAssembly.shared.goalsService
    private let waterControlService = EntityServicesAssembly.shared.waterControlService
    
    private init() {}
    
    public func sync(completion: ((Bool) -> Void)?) {
        guard let user = authorizationService.authorizedUser else {
            completion?(false)
            return
        }
        
        let batch = Firestore.firestore().batch()
        
        let userDocument = Firestore.firestore().collection("user").document("\(user.id)")
        
        let sprints = sprintsService.fetchSprintEntitiesInBackground()
        
        sprints.forEach { sprint in
            guard let sprintID = sprint.id else { return }
            
            let sprintDocument = userDocument.collection("sprints").document(sprintID)
            
            batch.setData(sprint.encode(), forDocument: sprintDocument)
            
            let habitsCollection = sprintDocument.collection("habits")
            let habits = habitsService.fetchHabitEntitiesInBackground(sprintID: sprintID)
            habits.forEach { habit in
                guard let habitID = habit.id else { return }
                batch.setData(habit.encode(), forDocument: habitsCollection.document(habitID))
            }
            
            let goalsCollection = sprintDocument.collection("goals")
            let goals = goalsService.fetchGoalEntitiesInBackground(sprintID: sprintID)
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
        
        if let waterControl = waterControlService.fetchWaterControlEntityInBakground() {
            let waterControlDocument = userDocument.collection("water_control").document("water_control")
        
            batch.setData(waterControl.encode(), forDocument: waterControlDocument)
        }
        
        batch.commit { error in
            completion?(error == nil)
        }
    }
    
}
