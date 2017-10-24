//
//  SubtasksService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSPredicate
import class Foundation.DispatchQueue
import class CoreData.NSManagedObjectContext
import struct SugarRecord.FetchRequest
import class SugarRecord.CoreDataDefaultStorage
import protocol SugarRecord.Context

final class SubtasksService {}

extension SubtasksService {

    func addSubtask(_ subtask: Subtask, to task: Task, completion: (() -> Void)?) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            guard context.fetchSubtask(id: subtask.id) == nil else {
                DispatchQueue.main.async {
                    completion?()
                }
                return
            }
            
            if let task = context.fetchTask(id: task.id),
               let newSubtask = context.createSubtask() {
                newSubtask.map(from: subtask)
                newSubtask.task = task
                save()
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }) { error in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func updateSubtask(_ subtask: Subtask, completion: (() -> Void)?) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            if let existingSubtask = context.fetchSubtask(id: subtask.id) {
                existingSubtask.map(from: subtask)
                save()
            } else if let newSubtask = context.createSubtask() {
                newSubtask.map(from: subtask)
                save()
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }) { error in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func removeSubtask(_ subtask: Subtask, completion: (() -> Void)?) {
        DefaultStorage.instance.storage.backgroundOperation({ (context, save) in
            if let existingSubtask = context.fetchSubtask(id: subtask.id) {
                try? context.remove(existingSubtask)
                save()
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }) { error in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

}

fileprivate extension SubtasksService {

    static func subtaskFetchRequest(id: String) -> FetchRequest<SubtaskEntity> {
        return FetchRequest<SubtaskEntity>().filtered(with: "id", equalTo: id)
    }
    
    static func subtasksFetchRequest(taskID: String) -> FetchRequest<SubtaskEntity> {
        return FetchRequest<SubtaskEntity>()
            .filtered(with: "task.id", equalTo: taskID)
            .sorted(with: "sortPosition", ascending: true)
    }

}


extension Context {
    
    func fetchSubtask(id: String) -> SubtaskEntity? {
        return (try? fetch(SubtasksService.subtaskFetchRequest(id: id)))?.first
    }
    
    func createSubtask() -> SubtaskEntity? {
        return try? create()
    }
    
}
