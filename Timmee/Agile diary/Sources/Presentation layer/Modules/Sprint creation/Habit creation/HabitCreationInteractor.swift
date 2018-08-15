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
    
    func createTarget() -> Task {
        return Task(id: RandomStringGenerator.randomString(length: 24),
                    title: "")
    }
    
    func saveTarget(_ target: Task, listID: String?, success: (() -> Void)?, fail: (() -> Void)?) {
        guard isValidTarget(target) else {
            fail?()
            return
        }
        
        habitsService.updateTask(target, listID: listID) { error in
            if error == nil {
                success?()
            } else {
                fail?()
            }
        }
    }
    
    func isValidTarget(_ target: Task) -> Bool {
        return !target.title.trimmed.isEmpty
    }
    
}
