//
//  GoalsService.swift
//  TasksKit
//
//  Created by i.kharabet on 16.10.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Workset
import class CoreData.NSManagedObjectContext

public protocol GoalsProvider: class {
    func createGoal() -> GoalEntity?
    func fetchGoal(id: String) -> Goal?
    func fetchGoals(sprintID: String) -> [Goal]
}

public protocol GoalsManager: class {
    func addGoal(_ goal: Goal, sprintID: String, completion: @escaping (Bool) -> Void)
    func updateGoal(_ goal: Goal, completion: @escaping (Bool) -> Void)
    func updateGoal(_ goal: Goal, sprintID: String?, completion: @escaping (Bool) -> Void)
    func updateGoals(_ goals: [Goal], completion: @escaping (Bool) -> Void)
    func updateGoals(_ goals: [Goal], sprintID: String?, completion: @escaping (Bool) -> Void)
    func removeGoal(_ goal: Goal, completion: @escaping (Bool) -> Void)
    func removeGoals(_ goals: [Goal], completion: @escaping (Bool) -> Void)
}

public protocol GoalsObserverProvider: class {
    func goalsObserver(sprintID: String) -> CacheObserver<Goal>
    func goalsScope(sprintID: String) -> CachedEntitiesObserver<GoalEntity, Goal>
}

public protocol GoalEntitiesProvider: class {
    func fetchGoalEntity(id: String) -> GoalEntity?
}

public protocol GoalEntitiesBackgroundProvider: class {
    func fetchGoalEntityInBackground(id: String) -> GoalEntity?
    func fetchGoalEntitiesInBackground(sprintID: String) -> [GoalEntity]
}

public final class GoalsService {
    
    private let sprintsProvider: SprintEntitiesProvider
    private let subtasksProvider: SubtaskEntitiesBackgroundProvider
    
    init(sprintsProvider: SprintEntitiesProvider,
         subtasksProvider: SubtaskEntitiesBackgroundProvider) {
        self.sprintsProvider = sprintsProvider
        self.subtasksProvider = subtasksProvider
    }
    
}

extension GoalsService: GoalsProvider {
    
    public func createGoal() -> GoalEntity? {
        return try? Database.localStorage.writeContext.create()
    }
    
    public func fetchGoal(id: String) -> Goal? {
        guard let entity = fetchGoalEntity(id: id) else { return nil }
        return Goal(goal: entity)
    }
    
    public func fetchGoals(sprintID: String) -> [Goal] {
        return GoalsService.goalsFetchRequest(sprintID: sprintID)
            .execute()
            .map { Goal(goal: $0) }
    }
    
}

extension GoalsService: GoalsManager {
    
    public func addGoal(_ goal: Goal, sprintID: String, completion: @escaping (Bool) -> Void) {
        Database.localStorage.write({ (context, save) in
            guard self.fetchGoalEntityInBackground(id: goal.id) == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            if let newGoal = self.createGoal() {
                newGoal.map(from: goal)
                newGoal.sprint = self.sprintsProvider.fetchSprintEntity(id: sprintID, context: context)
                newGoal.stages = NSSet(array: self.retrieveSubtaskEntities(from: goal.stages,
                                                                           in: context))
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
    public func updateGoal(_ goal: Goal, completion: @escaping (Bool) -> Void) {
        updateGoal(goal, sprintID: nil, completion: completion)
    }
    
    public func updateGoal(_ goal: Goal, sprintID: String?, completion: @escaping (Bool) -> Void) {
        updateGoals([goal], sprintID: sprintID, completion: completion)
    }
    
    public func updateGoals(_ goals: [Goal], completion: @escaping (Bool) -> Void) {
        updateGoals(goals, sprintID: nil, completion: completion)
    }
    
    public func updateGoals(_ goals: [Goal], sprintID: String?, completion: @escaping (Bool) -> Void) {
        guard !goals.isEmpty else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        Database.localStorage.write({ (context, save) in
            goals.forEach { goal in
                guard let goalEntity = self.fetchGoalEntityInBackground(id: goal.id) ?? self.createGoal() else { return }
                
                goalEntity.map(from: goal)
                
                if let sprintID = sprintID {
                    goalEntity.sprint = self.sprintsProvider.fetchSprintEntity(id: sprintID,
                                                                                context: context)
                }
                
                goalEntity.stages = NSSet(array: self.retrieveSubtaskEntities(from: goal.stages,
                                                                              in: context))
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
    public func removeGoal(_ goal: Goal, completion: @escaping (Bool) -> Void) {
        removeGoals([goal], completion: completion)
    }
    
    public func removeGoals(_ goals: [Goal], completion: @escaping (Bool) -> Void) {
        guard !goals.isEmpty else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        Database.localStorage.write({ (context, save) in
            goals.forEach { goal in
                guard let existingGoal = self.fetchGoalEntityInBackground(id: goal.id) else { return }
                context.delete(existingGoal)
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
}

extension GoalsService: GoalsObserverProvider {
    
    public func goalsObserver(sprintID: String) -> CacheObserver<Goal> {
        let predicate = NSPredicate(format: "sprint.id = %@", sprintID)
        let request = GoalsService.allGoalsFetchRequest().filtered(predicate: predicate).batchSize(10).nsFetchRequestWithResult
        let context = Database.localStorage.readContext
        let goalsObserver = CacheObserver<Goal>(request: request,
                                                  section: nil,
                                                  cacheName: nil,
                                                  context: context)
        
        goalsObserver.setMapping { entity in
            let entity = entity as! GoalEntity
            return Goal(goal: entity)
        }
        
        return goalsObserver
    }
    
    public func goalsScope(sprintID: String) -> CachedEntitiesObserver<GoalEntity, Goal> {
        let predicate = NSPredicate(format: "sprint.id = %@", sprintID)
        let request = GoalsService.allGoalsFetchRequest().filtered(predicate: predicate).batchSize(10).nsFetchRequest
        let context = Database.localStorage.readContext
        
        let observer = CachedEntitiesObserver<GoalEntity, Goal>(context: context,
                                            baseRequest: request,
                                            mapping: { Goal(goal: $0) })
        
        return observer
    }
    
}

extension GoalsService: GoalEntitiesProvider {
    
    public func fetchGoalEntity(id: String) -> GoalEntity? {
        return GoalsService.goalFetchRequest(id: id).execute().first
    }
    
}

extension GoalsService: GoalEntitiesBackgroundProvider {
    
    public func fetchGoalEntityInBackground(id: String) -> GoalEntity? {
        return GoalsService.goalFetchRequest(id: id).executeInBackground().first
    }
    
    public func fetchGoalEntitiesInBackground(sprintID: String) -> [GoalEntity] {
        return GoalsService.goalsFetchRequest(sprintID: sprintID).executeInBackground()
    }
    
}

private extension GoalsService {
    
    static func goalFetchRequest(id: String) -> FetchRequest<GoalEntity> {
        return GoalEntity.request().filtered(key: "id", value: id)
    }
    
    static func goalsFetchRequest(sprintID: String) -> FetchRequest<GoalEntity> {
        return GoalEntity.request().filtered(key: "sprint.id", value: sprintID)
    }
    
    static func allGoalsFetchRequest() -> FetchRequest<GoalEntity> {
        return GoalEntity.request()
            .sorted(keyPath: \.title, ascending: true)
            .sorted(keyPath: \.creationDate, ascending: false)
    }
    
}

private extension GoalsService {
    
    func retrieveSubtaskEntities(from subtasks: [Subtask],
                                 in context: NSManagedObjectContext) -> [SubtaskEntity] {
        return subtasks.compactMap { subtask in
            let entity = self.subtasksProvider.fetchSubtaskEntityInBackground(id: subtask.id)
                ?? self.subtasksProvider.createSubtaskEntity()
            entity?.map(from: subtask)
            return entity
        }
    }
    
}
