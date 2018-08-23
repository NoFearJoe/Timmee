//
//  TargetAndHabitInteractorTrait.swift
//  Agile diary
//
//  Created by i.kharabet on 23.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

protocol TargetAndHabitInteractorTrait: class {
    var tasksService: TaskEntitiesCountProvider & TasksManager & TasksObserverProvider & TasksProvider { get }
    
    func saveTask(_ task: Task, listID: String?, completion: ((Bool) -> Void)?)
    func removeTask(_ task: Task, completion: ((Bool) -> Void)?)
}

extension TargetAndHabitInteractorTrait {
    
    func saveTask(_ task: Task, listID: String?, completion: ((Bool) -> Void)?) {
        guard isValidTask(task) else {
            completion?(false)
            return
        }
        
        tasksService.updateTask(task, listID: listID) { error in
            completion?(error == nil)
        }
    }
    
    func removeTask(_ task: Task, completion: ((Bool) -> Void)?) {
        tasksService.removeTask(task) { error in
            completion?(error == nil)
        }
    }
    
    private func isValidTask(_ task: Task) -> Bool {
        return !task.title.trimmed.isEmpty
    }
    
}
