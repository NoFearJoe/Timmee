//
//  TargetCreationInteractor.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

protocol GoalProvider: AnyObject {
    var goal: Goal! { get }
}

protocol GoalCreationInteractorOutput: AnyObject {
    func stagesInserted(at indexes: [Int])
    func stagesRemoved(at indexes: [Int])
    func stagesUpdated(at indexes: [Int])
}

protocol GoalCreationDataSource: AnyObject {
    func stagesCount() -> Int
    func stage(at index: Int) -> Stage?
}

final class GoalCreationInteractor {
    
    weak var output: GoalCreationInteractorOutput?
    weak var goalProvider: GoalProvider!
    
    let goalsService = ServicesAssembly.shared.goalsService
    let stagesService = ServicesAssembly.shared.stagesService
    
    var sortedStages: [Stage] {
        return goalProvider.goal.stages.sorted(by: { $0.sortPosition < $1.sortPosition })
    }
    
}

extension GoalCreationInteractor {
    
    func createGoal() -> Goal {
        return Goal(goalID: RandomStringGenerator.randomString(length: 24))
    }
    
}

extension GoalCreationInteractor {
    
    func addStage(with title: String) {
        let stage = createStage(sortPosition: nextStageSortPosition())
        stage.title = title
        goalProvider.goal.stages.append(stage)
        
        addStage(stage, goal: goalProvider.goal) { [weak self] in
            if let index = self?.sortedStages.firstIndex(where: { $0.id == stage.id }) {
                self?.output?.stagesInserted(at: [index])
            }
        }
    }
    
    func updateStage(at index: Int, newTitle: String) {
        if let stage = sortedStages.item(at: index) {
            stage.title = newTitle
            saveStage(stage, completion: { [weak self] in
                self?.output?.stagesUpdated(at: [index])
            })
        }
    }
    
    func removeStage(at index: Int) {
        if let stage = sortedStages.item(at: index) {
            removeStage(stage, completion: { [weak self] in
                guard let `self` = self else { return }
                guard let deletionIndex = self.goalProvider.goal.stages.firstIndex(where: { $0.id == stage.id }) else { return }
                self.goalProvider.goal.stages.remove(at: deletionIndex)
                self.output?.stagesRemoved(at: [index])
            })
        }
    }
    
    func exchangeStages(at indexes: (Int, Int)) {
        guard indexes.0 != indexes.1 else { return }
        if let fromStage = sortedStages.item(at: indexes.0),
            let toStage = sortedStages.item(at: indexes.1) {
            
            let targetPosition = toStage.sortPosition
            
            let range = Int(min(indexes.0, indexes.1))...Int(max(indexes.0, indexes.1))
            let stages = sortedStages
            range.forEach { index in
                guard index != indexes.0 else { return }
                if let stage = stages.item(at: index) {
                    if indexes.0 < indexes.1 {
                        stage.sortPosition -= 1
                    } else {
                        stage.sortPosition += 1
                    }
                }
            }
            
            fromStage.sortPosition = targetPosition
            
            output?.stagesUpdated(at: range.map { $0 })
        }
    }
    
}

extension GoalCreationInteractor: GoalCreationDataSource {
    
    func stagesCount() -> Int {
        return sortedStages.count
    }
    
    func stage(at index: Int) -> Stage? {
        return sortedStages.item(at: index)
    }
    
}

fileprivate extension GoalCreationInteractor {
    
    func createStage(sortPosition: Int) -> Stage {
        Stage(
            id: RandomStringGenerator.randomString(length: 24),
            title: "",
            sortPosition: sortPosition
        )
    }
    
    func addStage(_ stage: Stage, goal: Goal, completion: (() -> Void)?) {
        stagesService.addStage(stage, to: goal, completion: completion)
    }
    
    func saveStage(_ stage: Stage, completion: (() -> Void)?) {
        stagesService.updateStage(stage, completion: completion)
    }
    
    func removeStage(_ stage: Stage, completion: (() -> Void)?) {
        stagesService.removeStage(stage, completion: completion)
    }
    
}

fileprivate extension GoalCreationInteractor {
    
    func nextStageSortPosition() -> Int {
        return (sortedStages.last?.sortPosition ?? 0) + 1
    }
    
}
