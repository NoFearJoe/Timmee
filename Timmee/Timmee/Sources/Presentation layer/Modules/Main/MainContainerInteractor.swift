//
//  MainContainerInteractor.swift
//  Timmee
//
//  Created by Илья Харабет on 20.01.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Foundation

final class MainContainerInteractor {
    
    private let tasksService = TasksService()
    
    func updateTaskDueDates() {
        DispatchQueue.global().async {
            let tasksToUpdate = self.tasksService.fetchTaskEntitiesInBackground(with: self.tasksService.tasksToUpdateDueDateFetchRequest())
            let updatedTasks = tasksToUpdate.map { entity -> Task in
                let task = Task(task: entity)
                task.dueDate = task.nextDueDate
                return task
            }
            self.tasksService.updateTasks(updatedTasks, completion: { _ in })
        }
    }
    
}
