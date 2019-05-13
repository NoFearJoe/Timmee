//
//  TaskEditorInteractor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foto.Photo
import class Foundation.DispatchGroup

protocol TaskEditorInteractorInput: class {
    func createTask() -> Task
    func saveTask(_ task: Task, listID: String?, success: (() -> Void)?, fail: (() -> Void)?)
    
    func scheduleTask(_ task: Task)
    
    func handleAttachmentsChange(oldAttachments: [String], newAttachments: [Photo], completion: @escaping ([String]) -> Void)
}

protocol TaskEditorInteractorOutput: class {}

final class TaskEditorInteractor {

    weak var output: TaskEditorInteractorOutput!
    
    let tasksService = ServicesAssembly.shared.tasksService
    let taskSchedulerService = TaskSchedulerService()
    let filesService = FilesService(directory: "attachments")

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
        taskSchedulerService.scheduleTask(task)
    }
    
    
    func handleAttachmentsChange(oldAttachments: [String], newAttachments: [Photo], completion: @escaping ([String]) -> Void) {
        let newAttachmentPaths = newAttachments.map { $0.name }
        
        let removedAttachments = Array(Set(oldAttachments).subtracting(newAttachmentPaths))
        
        let group = DispatchGroup()
        
        removedAttachments.forEach { attachment in
            group.enter()
            
            filesService.removeFileFromDocuments(withName: attachment)
            
            group.leave()
        }
        
        newAttachments.forEach { attachment in
            guard !filesService.isFileExistsInDocuments(withName: attachment.name) else { return }
            
            group.enter()
            
            attachment.loadImageData(completion: { [weak self] data in
                guard let data = data else { return }
                
                self?.filesService.saveFileInDocuments(withName: attachment.name, contents: data)
                
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            completion(newAttachmentPaths)
        }
    }

}

fileprivate extension TaskEditorInteractor {

    func isValidTask(_ task: Task) -> Bool {
        return !task.title.trimmed.isEmpty
    }

}
