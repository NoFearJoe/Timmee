//
//  TaskEditorInteractor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

protocol TaskEditorInteractorInput: class {
    func createTask() -> Task
    func saveTask(_ task: Task, listID: String?, success: (() -> Void)?, fail: (() -> Void)?)
    
    func scheduleTask(_ task: Task)
}

protocol TaskEditorInteractorOutput: class {}

final class TaskEditorInteractor {

    weak var output: TaskEditorInteractorOutput!
    
    let tasksService = TasksService()
    let taskSchedulerService = TaskSchedulerService()

}

extension TaskEditorInteractor: TaskEditorInteractorInput {

    func createTask() -> Task {
        return Task(id: RandomStringGenerator.randomString(length: 24),
                    title: "")
    }
    
    func saveTask(_ task: Task, listID: String?, success: (() -> Void)?, fail: (() -> Void)?) {
        guard isValidTask(task) else {
            fail?()
            return
        }
        
        tasksService.updateTask(task, listID: listID) { error in
            if error == nil {
                success?()
            } else {
                fail?()
            }
        }
    }
    
    
    func scheduleTask(_ task: Task) {
        let listTitle = tasksService.retrieveList(of: task)?.title
        taskSchedulerService.scheduleTask(task, listTitle: listTitle ?? "all_tasks".localized)
    }

}

fileprivate extension TaskEditorInteractor {

    func isValidTask(_ task: Task) -> Bool {
        return !task.title.trimmed.isEmpty
    }

}
