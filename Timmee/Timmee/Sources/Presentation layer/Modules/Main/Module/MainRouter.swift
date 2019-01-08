//
//  MainRouter.swift
//  Timmee
//
//  Created by i.kharabet on 13.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol MainRouterInput: class {
    func showTaskEditor(with task: Task?, list: List?, taskKind: Task.Kind, isImportant: Bool, output: TaskEditorOutput?)
    func showTaskEditor(with taskTitle: String, list: List?, taskKind: Task.Kind, isImportant: Bool, output: TaskEditorOutput?)
}

final class MainRouter {
    
    weak var transitionHandler: UIViewController!
    
}

extension MainRouter: MainRouterInput {
    
    func showTaskEditor(with task: Task?, list: List?, taskKind: Task.Kind, isImportant: Bool, output: TaskEditorOutput?) {
        showTaskEditor(list: list, isImportant: isImportant, output: output) { taskEditorInput in
            taskEditorInput.setTask(task)
            taskEditorInput.setTaskKind(task?.kind ?? taskKind)
            if let smartList = list as? SmartList, smartList.smartListType == .today, task?.dueDate == nil {
                taskEditorInput.setDueDate(Date().startOfHour + 1.asHours)
            }
        }
    }
    
    func showTaskEditor(with taskTitle: String, list: List?, taskKind: Task.Kind, isImportant: Bool, output: TaskEditorOutput?) {
        showTaskEditor(list: list, isImportant: isImportant, output: output) { taskEditorInput in
            taskEditorInput.setTask(nil)
            taskEditorInput.setTaskKind(taskKind)
            taskEditorInput.setTaskTitle(taskTitle)
            if let smartList = list as? SmartList, smartList.smartListType == .today {
                taskEditorInput.setDueDate(Date().startOfHour + 1.asHours)
            }
        }
    }
    
    private func showTaskEditor(list: List?, isImportant: Bool, output: TaskEditorOutput?, configuration: (TaskEditorInput) -> Void) {
        let taskEditorView = ViewControllersFactory.taskEditor
        
        let taskEditorInput = TaskEditorAssembly.assembly(with: taskEditorView)
        taskEditorInput.output = output
        taskEditorInput.setListID(list?.id)
        
        taskEditorView.loadViewIfNeeded()
        
        configuration(taskEditorInput)
        
        if isImportant { taskEditorView.setTaskImportant(true) }
        
        transitionHandler.present(taskEditorView, animated: true, completion: nil)
    }
    
}
