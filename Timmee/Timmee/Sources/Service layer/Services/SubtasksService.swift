//
//  SubtasksService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSPredicate
import class Foundation.NSSortDescriptor
import class Foundation.DispatchQueue
import class CoreData.NSFetchRequest
import class CoreData.NSManagedObjectContext

final class SubtasksService {}

extension SubtasksService {

    func addSubtask(_ subtask: Subtask, to task: Task, completion: (() -> Void)?) {
        DefaultStorage.instance.database.write({ (context, save) in
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
        }) { _ in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func updateSubtask(_ subtask: Subtask, completion: (() -> Void)?) {
        DefaultStorage.instance.database.write({ (context, save) in
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
        }) { _ in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func removeSubtask(_ subtask: Subtask, completion: (() -> Void)?) {
        DefaultStorage.instance.database.write({ (context, save) in
            if let existingSubtask = context.fetchSubtask(id: subtask.id) {
                context.delete(existingSubtask)
                save()
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }) { _ in
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

}

fileprivate extension SubtasksService {

    static func subtaskFetchRequest(id: String) -> NSFetchRequest<SubtaskEntity> {
        let request: NSFetchRequest<SubtaskEntity> = SubtaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        return request
    }
    
    static func subtasksFetchRequest(taskID: String) -> NSFetchRequest<SubtaskEntity> {
        let request: NSFetchRequest<SubtaskEntity> = SubtaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "task.id = %@", taskID)
        request.sortDescriptors = [NSSortDescriptor.init(key: "sortPosition", ascending: true)]
        return request
    }

}


extension NSManagedObjectContext {
    
    func fetchSubtask(id: String) -> SubtaskEntity? {
        return (try? fetch(SubtasksService.subtaskFetchRequest(id: id)))?.first
    }
    
    func createSubtask() -> SubtaskEntity? {
        return try? create()
    }
    
}
