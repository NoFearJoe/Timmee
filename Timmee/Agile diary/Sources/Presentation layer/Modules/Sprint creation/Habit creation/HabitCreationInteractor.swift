//
//  HabitCreationInteractor.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

final class HabitCreationInteractor: TargetAndHabitInteractorTrait {
    
    weak var targetProvider: TargetProvider!
    
    let tasksService = ServicesAssembly.shared.tasksService
    
    var sortedStages: [Subtask] {
        return targetProvider.target.subtasks.sorted(by: { $0.sortPosition > $1.sortPosition })
    }
    
}

extension HabitCreationInteractor {
    
    func createHabit() -> Habit {
        return Habit(habitID: RandomStringGenerator.randomString(length: 24))
    }
    
}
