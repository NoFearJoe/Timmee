//
//  TargetsAndHabitsInteractorTrait.swift
//  Agile diary
//
//  Created by i.kharabet on 13.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

protocol TargetsAndHabitsInteractorTrait: class {
    var tasksService: TaskEntitiesCountProvider & TasksManager & TasksObserverProvider & TasksProvider { get }
    
    func getTasks(listID: String) -> [Task]
    func saveTasks(_ tasks: [Task], completion: (() -> Void)?)
}

extension TargetsAndHabitsInteractorTrait {
    
    func getTasks(listID: String) -> [Task] {
        return tasksService.fetchTasks(listID: listID)
    }
    
    func saveTasks(_ tasks: [Task], completion: (() -> Void)?) {
        tasksService.updateTasks(tasks, completion: { _ in completion?() })
    }
    
}
