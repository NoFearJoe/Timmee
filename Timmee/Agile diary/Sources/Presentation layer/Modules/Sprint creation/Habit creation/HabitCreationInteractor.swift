//
//  HabitCreationInteractor.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

final class HabitCreationInteractor {
    
    weak var targetProvider: TargetProvider!
    
    let habitsService = ServicesAssembly.shared.tasksService
    
    var sortedStages: [Subtask] {
        return targetProvider.target.subtasks.sorted(by: { $0.sortPosition > $1.sortPosition })
    }
    
}

extension HabitCreationInteractor {
    
    func createHabit() -> Habit {
        return Habit(id: RandomStringGenerator.randomString(length: 24))
    }
    
    func saveHabit(_ habit: Habit, listID: String?, success: (() -> Void)?, fail: (() -> Void)?) {
        guard isValidHabit(habit) else {
            fail?()
            return
        }
        
        habitsService.updateTask(habit, listID: listID) { error in
            if error == nil {
                success?()
            } else {
                fail?()
            }
        }
    }
    
    func isValidHabit(_ habit: Habit) -> Bool {
        return !habit.title.trimmed.isEmpty
    }
    
}
