//
//  AchievementsManager.swift
//  Agile diary
//
//  Created by Илья Харабет on 31/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

// TODO: Отмена обновления ачивок при повторном запросе обновления

final class AchievementsManager {
    
    static let shared = AchievementsManager()
    
    private let sprintsService = EntityServicesAssembly.shared.sprintsService
    
    private let achievementsService = EntityServicesAssembly.shared.achievementsService
    private let achievementsManagerService = ServicesAssembly.shared.achievementsService
    
    private let queue = DispatchQueue(label: "achievement_manager_queue")
    
    func updateAchievements() {
        queue.async {
            self.update()
        }
    }
    
    private func update() {
        let existingAchievements = achievementsService.fetchAchievementEntitiesInBackground()
        let sprints = sprintsService.fetchSprintEntitiesInBackground()
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        update(sprints: sprints, existingAchievements: existingAchievements) { success in
            dispatchGroup.leave()
        }
        
        dispatchGroup.wait()
    }
    
    private func update(sprints: [SprintEntity], existingAchievements: [AchievementEntity], completion: @escaping (Bool) -> Void) {
        var evaluatedAchievementUpdates: [() -> Void] = []
        
        func add(id: String, name: String, sprintID: String? = nil, habitID: String? = nil, goalID: String? = nil) {
            guard !existingAchievements.contains(where: { $0.id == id }) else { return }
            
            let entity = achievementsManagerService.createAchievementEntity()
            
            let update = {
                entity.id = id
                entity.name = name
                entity.sprintID = sprintID
                entity.habitID = habitID
                entity.goalID = goalID
                entity.receivingDate = Date.now
            }
            
            evaluatedAchievementUpdates.append(update)
        }
        
        // doneFirstSprint
        if !existingAchievements.contains(where: { $0.id == Achievement.doneFirstSprint.rawValue }),
            sprints.contains(where: { $0.endDate?.isLower(than: Date.now) == true }) {
            add(id: Achievement.doneFirstSprint.rawValue, name: Achievement.doneFirstSprint.rawValue)
        }
        
        sprints.forEach { sprint in
            guard let sprintID = sprint.id else { return }
            guard Sprint(sprintEntity: sprint).tense != .future else { return }
            
            var countOfCompletedHabitsInSprint = 0

            if let habits = sprint.habits?.allObjects as? [HabitEntity] {
                // doneAllHabitsInADayFirstTime
                if !habits.isEmpty, habits.allSatisfy({ Habit(habit: $0).isDone(at: .now) }) {
                    let id = "\(Achievement.doneAllHabitsInADayFirstTime.rawValue).\(sprintID)"
                    add(id: id, name: Achievement.doneAllHabitsInADayFirstTime.rawValue, sprintID: sprintID)
                }
                
                habits.forEach { entity in
                    let habit = Habit(habit: entity)
                    let dueDaysInSprint = habit.dueDays.count * Int(sprint.duration)
                    
                    // doneHabit_Percent
                    
                    // TODO: Не учитывается creationDate
                    let percent = Float(habit.doneDates.count) / Float(dueDaysInSprint)
                    if percent >= 1 {
                        countOfCompletedHabitsInSprint += 1
                        let id = "\(Achievement.doneHabit100Percent.rawValue).\(sprintID).\(habit.id)"
                        add(id: id, name: Achievement.doneHabit100Percent.rawValue, sprintID: sprintID, habitID: id)
                    } else if percent >= 0.75 {
                        let id = "\(Achievement.doneHabit75Percent.rawValue).\(sprintID).\(habit.id)"
                        add(id: id, name: Achievement.doneHabit75Percent.rawValue, sprintID: sprintID, habitID: id)
                    } else if percent >= 0.5 {
                        let id = "\(Achievement.doneHabit50Percent.rawValue).\(sprintID).\(habit.id)"
                        add(id: id, name: Achievement.doneHabit50Percent.rawValue, sprintID: sprintID, habitID: id)
                    } else if percent >= 0.25 {
                        let id = "\(Achievement.doneHabit25Percent.rawValue).\(sprintID).\(habit.id)"
                        add(id: id, name: Achievement.doneHabit25Percent.rawValue, sprintID: sprintID, habitID: id)
                    }
                    
                    // TODO
                    // doneHabit_TimesInARow
//                    let doneInARow = habit.doneDates.reversed().reduce(0) { totalCount, doneDate in
//
//                    }
                }
            }
            
            var areAllGoalsDone = false
            
            if let goals = sprint.goals?.allObjects as? [GoalEntity] {
                // doneFirstGoal
                if goals.contains(where: { $0.isDone }) {
                    let id = "\(Achievement.doneFirstGoal.rawValue).\(sprintID)"
                    add(id: id, name: Achievement.doneFirstGoal.rawValue, sprintID: sprintID)
                }
                
                // doneAllGoals
                if !goals.isEmpty, goals.allSatisfy({ $0.isDone }) {
                    areAllGoalsDone = true
                    let id = "\(Achievement.doneAllGoals.rawValue).\(sprintID)"
                    add(id: id, name: Achievement.doneAllGoals.rawValue, sprintID: sprintID)
                }
            }
            
            // doneAllTasksInASprint
            if countOfCompletedHabitsInSprint == sprint.habits?.count, areAllGoalsDone {
                let id = "\(Achievement.doneAllTasksInASprint.rawValue).\(sprintID)"
                add(id: id, name: Achievement.doneAllTasksInASprint.rawValue, sprintID: sprintID)
            }
        }
        
        achievementsManagerService.updateAchievement(
            update: {
                evaluatedAchievementUpdates.forEach { $0() }
            },
            completion: completion
        )
    }
    
}
