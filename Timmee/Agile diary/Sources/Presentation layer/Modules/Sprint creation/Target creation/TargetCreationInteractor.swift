//
//  TargetCreationInteractor.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

protocol TargetProvider: class {
    var target: Task! { get }
}

protocol TargetCreationInteractorOutput: class {
    func stagesInserted(at indexes: [Int])
    func stagesRemoved(at indexes: [Int])
    func stagesUpdated(at indexes: [Int])
}

protocol TargetCreationDataSource: class {
    func stagesCount() -> Int
    func stage(at index: Int) -> Subtask?
}

final class TargetCreationInteractor: TargetAndHabitInteractorTrait {
    
    weak var output: TargetCreationInteractorOutput?
    weak var targetProvider: TargetProvider!
    
    let tasksService = ServicesAssembly.shared.tasksService
    let stagesService = ServicesAssembly.shared.subtasksService
    
    var sortedStages: [Subtask] {
        return targetProvider.target.subtasks.sorted(by: { $0.sortPosition > $1.sortPosition })
    }
    
}

extension TargetCreationInteractor {
    
    func createTarget() -> Task {
        return Task(id: RandomStringGenerator.randomString(length: 24),
                    title: "")
    }
    
}

extension TargetCreationInteractor {
    
    func addStage(with title: String) {
        let stage = createStage(sortPosition: nextStageSortPosition())
        stage.title = title
        targetProvider.target.subtasks.append(stage)
        
        addStage(stage, task: targetProvider.target) { [weak self] in
            if let index = self?.sortedStages.index(where: { $0.id == stage.id }) {
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
                guard let deletionIndex = self.targetProvider.target.subtasks.index(where: { $0.id == stage.id }) else { return }
                self.targetProvider.target.subtasks.remove(at: deletionIndex)
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
                    if indexes.0 > indexes.1 {
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

extension TargetCreationInteractor: TargetCreationDataSource {
    
    func stagesCount() -> Int {
        return sortedStages.count
    }
    
    func stage(at index: Int) -> Subtask? {
        return sortedStages.item(at: index)
    }
    
}

fileprivate extension TargetCreationInteractor {
    
    func createStage(sortPosition: Int) -> Subtask {
        return Subtask(id: RandomStringGenerator.randomString(length: 24),
                       title: "",
                       sortPosition: sortPosition)
    }
    
    func addStage(_ stage: Subtask, task: Task, completion: (() -> Void)?) {
        stagesService.addSubtask(stage, to: task, completion: completion)
    }
    
    func saveStage(_ stage: Subtask, completion: (() -> Void)?) {
        stagesService.updateSubtask(stage, completion: completion)
    }
    
    func removeStage(_ stage: Subtask, completion: (() -> Void)?) {
        stagesService.removeSubtask(stage, completion: completion)
    }
    
}

fileprivate extension TargetCreationInteractor {
    
    func nextStageSortPosition() -> Int {
        return (sortedStages.first?.sortPosition ?? 0) + 1
    }
    
}
