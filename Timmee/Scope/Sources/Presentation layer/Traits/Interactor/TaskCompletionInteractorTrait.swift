//
//  TaskCompletionInteractorTrait.swift
//  Timmee
//
//  Created by Илья Харабет on 05/01/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public protocol TaskCompletionInteractorTrait: AnyObject {
    var tasksService: TaskEntitiesCountProvider & TasksManager & TasksObserverProvider & TasksProvider { get }
    var taskSchedulerService: TaskSchedulerService { get }
    
    func completeTask(_ task: Task, doneDate: Date?, completion: @escaping () -> Void)
    func completeTasks(_ tasks: [Task], doneDate: Date?, completion: @escaping () -> Void)
}

extension TaskCompletionInteractorTrait {
    func completeTask(_ task: Task, doneDate: Date?, completion: @escaping () -> Void) {
        let doneDate = (doneDate ?? Date()).startOfDay
        let shouldBeDone = !task.isDone(at: doneDate)
        task.setDone(shouldBeDone, at: doneDate)
        if shouldBeDone { task.inProgress = false }
        
        tasksService.updateTask(task) { [weak self] error in
            guard let `self` = self else { return }
            
            if task.isDone(at: doneDate) {
                self.taskSchedulerService.removeNotifications(for: task)
            } else {
                NotificationsConfigurator.registerForLocalNotifications(application: UIApplication.shared) { isAuthorized in
                    guard isAuthorized else { return }
                    self.taskSchedulerService.scheduleTask(task)
                }
            }
            
            completion()
        }
    }
    
    func completeTasks(_ tasks: [Task], doneDate: Date?, completion: @escaping () -> Void) {
        let doneDate = (doneDate ?? Date()).startOfDay
        let shouldBeDone = tasks.contains(where: { !$0.isDone(at: doneDate) })
        tasks.forEach { task in
            task.setDone(shouldBeDone, at: doneDate)
            if shouldBeDone { task.inProgress = false }
        }
        
        tasksService.updateTasks(tasks) { [weak self] error in
            guard let `self` = self else { return }
            
            tasks.forEach { task in
                if task.isDone(at: doneDate) {
                    self.taskSchedulerService.removeNotifications(for: task)
                } else {
                    NotificationsConfigurator.registerForLocalNotifications(application: UIApplication.shared) { isAuthorized in
                        guard isAuthorized else{ return }
                        self.taskSchedulerService.scheduleTask(task)
                    }
                }
            }
            
            completion()
        }
    }
}
