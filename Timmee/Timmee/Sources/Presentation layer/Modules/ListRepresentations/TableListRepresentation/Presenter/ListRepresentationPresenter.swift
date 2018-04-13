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
        
        if let smartList = list as? SmartList, smartList.smartListType == .important {
            view.setImportancy(true)
        }
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

extension ListRepresentationPresenter: TableListRepresentationEditingInput {
    
    func setEditingMode(_ mode: ListRepresentationEditingMode) {
        
    }
    
}

//extension ListRepresentationPresenter: TableListRepresentationOutput {
//
//    func didPressEdit(for task: Task) {
//        self.output?.didAskToShowTaskEditor(with: task)
//    }
//
//    func tasksCountChanged(count: Int) {
//        if count == 0 {
//            editingOutput?.setGroupEditingVisible(false)
//        } else {
//            editingOutput?.setGroupEditingVisible(true)
//        }
//    }
//
//    func groupEditingOperationCompleted() {
//        view.setGroupEditingActionsEnabled(false)
//    }
//
//}

extension ListRepresentationPresenter: ListRepresentationViewOutput {
    
    func didInputTaskTitle(_ title: String?) {
        state.enteredTaskTitle = title
    }
    
    func didToggleImportancyInShortTaskEditor(to isImportant: Bool) {
        state.shouldCreateImportantTask = isImportant
    }
    
    func didPressAddTaskButton() {
        if let title = state.enteredTaskTitle, let listID = state.list?.id {
//            view.setInteractionsEnabled(false)
//            interactor.addShortTask(with: title,
//                                    dueDate: dateForTodaySmartList(),
//                                    inProgress: progressStateForInProgressSmartList(),
//                                    isImportant: state.shouldCreateImportantTask,
//                                    listID: listID)
        }
    }
    
    func didPressMoreButton() {
//        if let title = state.enteredTaskTitle, !title.isEmpty {
//            output?.didAskToShowTaskEditor(with: title)
//        } else {
//            output?.didAskToShowTaskEditor(with: nil)
//        }
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
    
    func groupEditingWillToggle(to isEditing: Bool) {
        editingOutput?.groupEditingWillToggle(to: isEditing)
    }
    
    func groupEditingToggled(to isEditing: Bool) {
        editingOutput?.groupEditingToggled(to: isEditing)
        state.checkedTasks = []
    }
    
    func didSelectGroupEditingAction(_ action: GroupEditingAction) {        
        switch action {
        case .delete:
            let message = "are_you_sure_you_want_to_delete_tasks".localized
            view.showConfirmationAlert(title: "remove_tasks".localized,
                                       message: message,
                                       confirmationTitle: "remove".localized) { [weak self] in
//                self?.representationInput?.performGroupEditingAction(.delete)
                self?.setEditingMode(.default)
            }
        case .complete: break
//            representationInput?.performGroupEditingAction(.complete)
        case .move:
            editingOutput?.didAskToShowListsForMoveTasks { [weak self] list in
                let message = "are_you_sure_you_want_to_move_tasks".localized + " \"\(list.title)\""
                self?.view.showConfirmationAlert(title: "move_tasks".localized,
                                                 message: message,
                                                 confirmationTitle: "move".localized) { [weak self] in
//                    self?.representationInput?.performGroupEditingAction(.move(list: list))
                    self?.setEditingMode(.default)
                }
            }
        }
    }
    
}

private extension ListRepresentationPresenter {

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
