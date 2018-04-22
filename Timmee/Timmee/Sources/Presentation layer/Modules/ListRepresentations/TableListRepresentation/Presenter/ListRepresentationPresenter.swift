//
//  ListRepresentationPresenter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.IndexPath
import class UIKit.UITableView
import class UIKit.UIViewController

final class ListRepresentationPresenter {
    
    weak var output: ListRepresentationOutput?
    weak var editingOutput: ListRepresentationEditingOutput?
    
    weak var view: ListRepresentationViewInput!
    
    private var state = State()

}

extension ListRepresentationPresenter: ListRepresentationInput {
    func performGroupEditingAction(_ action: TargetGroupEditingAction) {
        
    }
    

    var viewController: UIViewController {
        return view as! UIViewController
    }
    
    func setList(list: List) {
        state.list = list
    }
    
    func clearInput() {
        view.clearTaskTitleInput()
    }
    
    func forceTaskCreation() {
        view.setTaskTitleFieldFirstResponder(true)
    }
    
    func finishShortTaskEditing() {
        view.setTaskTitleFieldFirstResponder(false)
    }
    
    func setEditingMode(_ mode: ListRepresentationEditingMode, completion: @escaping () -> Void) {
        
    }
    
}

extension ListRepresentationPresenter: ListRepresentationViewOutput {
    
    func didInputTaskTitle(_ title: String?) {
        state.enteredTaskTitle = title
    }
    
    func didToggleImportancyInShortTaskEditor(to isImportant: Bool) {
        state.shouldCreateImportantTask = isImportant
    }
    
    func didPressAddTaskButton() {

    }
    
    func didPressMoreButton() {

    }
    
    func didCheckTask(_ task: Task) {
        state.checkedTasks.append(task)
        view.setGroupEditingActionsEnabled(!state.checkedTasks.isEmpty)
        if state.checkedTasks.contains(where: { !$0.isDone }) || state.checkedTasks.isEmpty {
            view.setCompletionGroupEditingAction(.complete)
        } else {
            view.setCompletionGroupEditingAction(.recover)
        }
    }
    
    func didUncheckTask(_ task: Task) {
        state.checkedTasks.remove(object: task)
        view.setGroupEditingActionsEnabled(!state.checkedTasks.isEmpty)
        if state.checkedTasks.contains(where: { !$0.isDone }) || state.checkedTasks.isEmpty {
            view.setCompletionGroupEditingAction(.complete)
        } else {
            view.setCompletionGroupEditingAction(.recover)
        }
    }
}
