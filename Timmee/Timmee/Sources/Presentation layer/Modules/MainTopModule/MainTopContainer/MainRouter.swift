//
//  MainRouter.swift
//  Timmee
//
//  Created by i.kharabet on 13.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol MainRouterInput: class {
    func showTaskEditor(with task: Task?, list: List?, output: TaskEditorOutput?)
    func showTaskEditor(with taskTitle: String, list: List?, output: TaskEditorOutput?)
}

final class MainRouter {
    
    weak var transitionHandler: UIViewController!
    
}

extension MainRouter: MainRouterInput {
    
    func showTaskEditor(with task: Task?, list: List?, output: TaskEditorOutput?) {
        showTaskEditor(list: list, output: output) { taskEditorInput in
            taskEditorInput.setTask(task)
        }
    }
    
    func showTaskEditor(with taskTitle: String, list: List?, output: TaskEditorOutput?) {
        showTaskEditor(list: list, output: output) { taskEditorInput in
            taskEditorInput.setTask(nil)
            taskEditorInput.setTaskTitle(taskTitle)
        }
    }
    
    private func showTaskEditor(list: List?, output: TaskEditorOutput?, configuration: (TaskEditorInput) -> Void) {
        let taskEditorView = ViewControllersFactory.taskEditor
        
        let taskEditorInput = TaskEditorAssembly.assembly(with: taskEditorView)
        taskEditorInput.output = output
        taskEditorInput.setListID(list?.id)
        
        taskEditorView.loadViewIfNeeded()
        
        configuration(taskEditorInput)
        
        if let smartList = list as? SmartList, smartList.smartListType == .today {
            taskEditorInput.setDueDate(Date().startOfHour + 1.asHours)
        }
        
        transitionHandler.present(taskEditorView, animated: true, completion: nil)
    }
    
}
