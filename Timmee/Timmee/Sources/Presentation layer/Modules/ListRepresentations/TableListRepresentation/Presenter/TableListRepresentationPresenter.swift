//
//  TableListRepresentationPresenter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.IndexPath
import class UIKit.UITableView
import class UIKit.UIViewController

final class TableListRepresentationPresenter {

    struct State {
        var list: List?
        var isClear: Bool = false
        var enteredTaskTitle: String?
        
        var isCompletedTasksVisible: Bool = false
        var shouldResetOffsetAfterReload: Bool = false
        
        var checkedTasks: [Task] = []
        
        var shouldCreateImportantTask: Bool = false
        
        mutating func reset() {
            isCompletedTasksVisible = false
            shouldResetOffsetAfterReload = false
        }
    }
    
    weak var output: ListRepresentationOutput?
    weak var editingOutput: ListRepresentationEditingOutput?
    
    var interactor: TableListRepresentationInteractorInput!
    weak var view: TableListRepresentationViewInput!
    
    fileprivate var state = State()

}

extension TableListRepresentationPresenter: ListRepresentationInput {

    var viewController: UIViewController {
        return view as! UIViewController
    }
    
    func setList(list: List) {
        state.list = list
        
        state.isCompletedTasksVisible = false
        state.shouldResetOffsetAfterReload = true
        
        interactor.fetchTasks(by: list.id)
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
    
}

extension TableListRepresentationPresenter: ListRepresentationEditingInput {
    
    func toggleGroupEditing() {
        view.toggleGroupEditing()
    }
    
}

extension TableListRepresentationPresenter: TableListRepresentationInteractorOutput {
    
    func initialTasksFetched() {
        if state.shouldResetOffsetAfterReload {
            view.resetOffset()
            state.shouldResetOffsetAfterReload = false
        }
    }
    
    func tasksCountChanged(count: Int) {
        if count == 0 {
            view.showNoTasksPlaceholder()
            editingOutput?.setGroupEditingVisible(false)
        } else {
            view.hideNoTasksPlaceholder()
            editingOutput?.setGroupEditingVisible(true)
        }
    }
    
    func operationCompleted() {
        view.setInteractionsEnabled(true)
    }
    
    func groupEditingOperationCompleted() {
        view.setInteractionsEnabled(true)
        view.setGroupEditingActionsEnabled(false)
    }
    
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble) {
        view.connect(with: tableViewManageble)
    }

}

extension TableListRepresentationPresenter: TableListRepresentationViewOutput {
    
    func viewWillAppear() {
        guard let list = state.list else { return }
        interactor.fetchTasks(by: list.id)
    }
    
    func didInputTaskTitle(_ title: String?) {
        state.enteredTaskTitle = title
    }
    
    func didToggleImportancyInShortTaskEditor(to isImportant: Bool) {
        state.shouldCreateImportantTask = isImportant
    }
    
    func didPressAddTaskButton() {
        if let title = state.enteredTaskTitle {
            view.setInteractionsEnabled(false)
            interactor.addShortTask(with: title,
                                    dueDate: dateForTodaySmartList(),
                                    inProgress: progressStateForInProgressSmartList(),
                                    isImportant: state.shouldCreateImportantTask)
        }
    }
    
    func didPressMoreButton() {
        if let title = state.enteredTaskTitle, !title.isEmpty {
            output?.didAskToShowTaskEditor(with: title)
        } else {
            output?.didAskToShowTaskEditor(with: nil)
        }
    }
    
    func didPressEdit(for task: Task) {
        output?.didAskToShowTaskEditor(with: task)
    }
    
    func didPressDelete(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.deleteTask(task)
    }
    
    func didPressComplete(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.completeTask(task)
    }
    
    func didPressStart(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.toggleTaskProgressState(task)
    }
    
    func didPressStop(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.toggleTaskProgressState(task)
    }
    
    func toggleImportancy(of task: Task) {
        view.setInteractionsEnabled(false)
        interactor.toggleImportancy(of: task)
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
    
    func taskIsChecked(_ task: Task) -> Bool {
        return state.checkedTasks.contains(task)
    }
    
    func groupEditingWillToggle(to isEditing: Bool) {
        editingOutput?.groupEditingWillToggle(to: isEditing)
    }
    
    func groupEditingToggled(to isEditing: Bool) {
        editingOutput?.groupEditingToggled(to: isEditing)
        state.checkedTasks = []
    }
    
    func didSelectGroupEditingAction(_ action: GroupEditingAction) {
        let tasks = state.checkedTasks
        
        switch action {
        case .delete:
            let message = "are_you_sure_you_want_to_delete_tasks".localized
            view.showConfirmationAlert(title: "remove_tasks".localized,
                                       message: message,
                                       confirmationTitle: "remove".localized) { [weak self] in
                self?.view.setInteractionsEnabled(false)
                self?.interactor.deleteTasks(tasks)
                self?.state.checkedTasks = []
                self?.view.toggleGroupEditing()
            }
        case .complete:
            view.setInteractionsEnabled(false)
            interactor.completeTasks(tasks)
            state.checkedTasks = []
            view.toggleGroupEditing()
        case .move:
            editingOutput?.didAskToShowListsForMoveTasks { [weak self] list in
                let message = "are_you_sure_you_want_to_move_tasks".localized + " \"\(list.title)\""
                self?.view.showConfirmationAlert(title: "move_tasks".localized,
                                                 message: message,
                                                 confirmationTitle: "move".localized) { [weak self] in
                    self?.view.setInteractionsEnabled(false)
                    self?.interactor.moveTasks(tasks, toList: list)
                    self?.state.checkedTasks = []
                    self?.view.toggleGroupEditing()
                }
            }
        }
    }
    
}

fileprivate extension TableListRepresentationPresenter {

    func dateForTodaySmartList() -> Date? {
        if let smartList = state.list as? SmartList, smartList.smartListType == .today {
            let startOfNextHour = Date().startOfHour + 1.asHours
            return startOfNextHour
        }
        return nil
    }
    
    func progressStateForInProgressSmartList() -> Bool {
        if let smartList = state.list as? SmartList, smartList.smartListType == .inProgress {
            return true
        }
        return false
    }

}
