//
//  SubtasksEditorInteractor.swift
//  Timmee
//
//  Created by i.kharabet on 13.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

final class SubtasksEditorInteractor {
    
    weak var output: SubtasksEditorInteractorOutput?
    weak var taskProvider: SubtasksEditorTaskProvider!
    
    let subtasksService = SubtasksService()
    
    fileprivate var sortedSubtasks: [Subtask] {
        return taskProvider?.task?.subtasks.sorted(by: { $0.0.sortPosition < $0.1.sortPosition }) ?? []
    }
    
}

extension SubtasksEditorInteractor: SubtasksEditorOutput {
    
    func addSubtask(with title: String) {
        guard let taskProvider = taskProvider else { return  }
        
        let subtask = createSubtask(sortPosition: nextSubtaskSortPosition())
        subtask.title = title
        taskProvider.task.subtasks.append(subtask)
        
        addSubtask(subtask, task: taskProvider.task) { [weak self] in
            if let index = self?.sortedSubtasks.index(where: { $0.id == subtask.id }) {
                self?.output?.subtasksInserted(at: [index])
            }
        }
    }
    
    func updateSubtask(at index: Int, newTitle: String) {
        if let subtask = sortedSubtasks.item(at: index) {
            subtask.title = newTitle
            saveSubtask(subtask, completion: { [weak self] in
                self?.output?.subtasksUpdated(at: [index])
            })
        }
    }
    
    func removeSubtask(at index: Int) {
        if let subtask = sortedSubtasks.item(at: index) {
            removeSubtask(subtask, completion: { [weak self] in
                guard let `self` = self else { return }
                guard let taskProvider = self.taskProvider else { return  }
                guard let deletionIndex = taskProvider.task.subtasks.index(where: { $0.id == subtask.id }) else { return }
                taskProvider.task.subtasks.remove(at: deletionIndex)
                self.output?.subtasksRemoved(at: [index])
            })
        }
    }
    
    func exchangeSubtasks(at indexes: (Int, Int)) {
        guard indexes.0 != indexes.1 else { return }
        if let fromSubtask = sortedSubtasks.item(at: indexes.0),
            let toSubtask = sortedSubtasks.item(at: indexes.1) {
            
            let targetPosition = toSubtask.sortPosition
            
            let range = Int(min(indexes.0, indexes.1))...Int(max(indexes.0, indexes.1))
            let subtasks = sortedSubtasks
            range.forEach { index in
                guard index != indexes.0 else { return }
                if let subtask = subtasks.item(at: index) {
                    if indexes.0 > indexes.1 {
                        subtask.sortPosition += 1
                    } else {
                        subtask.sortPosition -= 1
                    }
                }
            }
            
            fromSubtask.sortPosition = targetPosition
            
            output?.subtasksUpdated(at: range.map { $0 })
        }
    }
    
    func doneSubtask(at index: Int) {
        if let subtask = sortedSubtasks.item(at: index) {
            subtask.isDone = !subtask.isDone
            saveSubtask(subtask, completion: { [weak self] in
                self?.output?.subtasksUpdated(at: [index])
            })
        }
    }
    
}

extension SubtasksEditorInteractor: SubtasksEditorDataSource {
    
    func subtasksCount() -> Int {
        return sortedSubtasks.count
    }
    
    func subtask(at index: Int) -> Subtask? {
        return sortedSubtasks.item(at: index)
    }
    
}

fileprivate extension SubtasksEditorInteractor {
    
    func createSubtask(sortPosition: Int) -> Subtask {
        return Subtask(id: RandomStringGenerator.randomString(length: 24),
                       title: "",
                       sortPosition: sortPosition)
    }
    
    func addSubtask(_ subtask: Subtask, task: Task, completion: (() -> Void)?) {
        subtasksService.addSubtask(subtask, to: task, completion: completion)
    }
    
    func saveSubtask(_ subtask: Subtask, completion: (() -> Void)?) {
        subtasksService.updateSubtask(subtask, completion: completion)
    }
    
    func removeSubtask(_ subtask: Subtask, completion: (() -> Void)?) {
        subtasksService.removeSubtask(subtask, completion: completion)
    }
    
}

fileprivate extension SubtasksEditorInteractor {
    
    func nextSubtaskSortPosition() -> Int {
        return (sortedSubtasks.last?.sortPosition ?? 0) + 1
    }
    
}
