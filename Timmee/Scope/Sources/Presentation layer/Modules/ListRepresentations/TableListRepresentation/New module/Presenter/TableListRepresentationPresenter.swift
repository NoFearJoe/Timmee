//
//  TableListRepresentationPresenter.swift
//  Timmee
//
//  Created by i.kharabet on 12.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.IndexPath
import class UIKit.UITableView
import class UIKit.UIViewController

final class TableListRepresentationPresenter {
    
    weak var output: ListRepresentationOutput?
    weak var editingOutput: ListRepresentationEditingOutput?
    
    var interactor: TableListRepresentationInteractorInput!
    weak var view: TableListRepresentationViewInput!
    
    private var state = State()
    
}

extension TableListRepresentationPresenter: ListRepresentationInput {
    
    var viewController: UIViewController {
        return view as! UIViewController
    }
    
    func setList(list: List) {
        state.list = list
        state.shouldResetOffsetAfterReload = true
        
        interactor.subscribeToTasks(in: list)
    }
    
    func prepareToGroupEditing() {
        state.checkedTasks = []
    }
    
    func performGroupEditingAction(_ action: TargetGroupEditingAction, completion: (([Task]) -> Void)?) {
        view.setInteractionsEnabled(false)
        
        let tasks = state.checkedTasks
        switch action {
        case .delete:
            interactor.deleteTasks(tasks)
        case .complete:
            interactor.completeTasks(tasks, doneDate: state.list?.defaultDueDate) { [weak self] in
                self?.groupEditingOperationCompleted()
            }
        case let .move(list):
            interactor.moveTasks(tasks, toList: list) { [weak self] in
                self?.view.setInteractionsEnabled(true)
                completion?(tasks)
            }
        }
        state.checkedTasks = []
    }
    
}

extension TableListRepresentationPresenter: TableListRepresentationEditingInput {
    
    func setEditingMode(_ mode: ListRepresentationEditingMode, completion: @escaping () -> Void) {
        state.editingMode = mode
        view.setEditingMode(mode, completion: completion)
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
            output?.tasksCountChanged(count: count)
        } else {
            view.hideNoTasksPlaceholder()
            output?.tasksCountChanged(count: count)
        }
    }
    
    func taskChanged(change: CoreDataChange) {
        switch change {
        case let .insertion(indexPath): view.animateModification(at: indexPath)
        case let .move(fromIndexPath, toIndexPath):
            guard fromIndexPath != toIndexPath else { return }
            view.animateModification(at: toIndexPath)
        default: return
        }
    }
    
    func didNotSubscribeToTasks() {
        view.reloadTasks()
    }
    
    func operationCompleted() {
        view.setInteractionsEnabled(true)
    }
    
    func groupEditingOperationCompleted() {
        operationCompleted()
        output?.groupEditingOperationCompleted()
    }
    
    func prepareCacheObserver(_ cacheSubscribable: CacheSubscribable) {
        view.subscribeToCacheObserver(cacheSubscribable)
    }
    
}

extension TableListRepresentationPresenter: TableListRepresentationViewOutput {
    
    func viewWillAppear() {
        interactor.subscribeToTasks(in: state.list)
    }
    
}

extension TableListRepresentationPresenter: TableListRepresentationAdapterOutput {
    
    func didPressEdit(for task: Task) {
        output?.didPressEdit(for: task)
    }
    
    func didPressDelete(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.deleteTask(task)
    }
    
    func didPressComplete(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.completeTask(task, doneDate: state.list?.defaultDueDate) { [weak self] in
            self?.operationCompleted()
        }
    }
    
    func didPressStart(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.toggleTaskProgressState(task)
    }
    
    func didPressStop(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.toggleTaskProgressState(task)
    }
    
    func didToggleImportancy(of task: Task) {
        view.setInteractionsEnabled(false)
        interactor.toggleImportancy(of: task)
    }
    
    func didCheckTask(_ task: Task) {
        state.checkedTasks.append(task)
        editingOutput?.setGroupEditingActionsEnabled(!state.checkedTasks.isEmpty)
        let doneDate = state.list?.defaultDueDate
        if state.checkedTasks.contains(where: { !$0.isDone(at: doneDate) && !$0.isFinished(at: doneDate) }) || state.checkedTasks.isEmpty {
            editingOutput?.setCompletionGroupEditingAction(.complete)
        } else {
            editingOutput?.setCompletionGroupEditingAction(.recover)
        }
    }
    
    func didUncheckTask(_ task: Task) {
        state.checkedTasks.remove(object: task)
        editingOutput?.setGroupEditingActionsEnabled(!state.checkedTasks.isEmpty)
        let doneDate = state.list?.defaultDueDate
        if state.checkedTasks.contains(where: { !$0.isDone(at: doneDate) && !$0.isFinished(at: doneDate) }) || state.checkedTasks.isEmpty {
            editingOutput?.setCompletionGroupEditingAction(.complete)
        } else {
            editingOutput?.setCompletionGroupEditingAction(.recover)
        }
    }
    
    func taskIsChecked(_ task: Task) -> Bool {
        return state.checkedTasks.contains(task)
    }
    
    func taskIsDone(_ task: Task) -> Bool {
        let doneDate = state.list?.defaultDueDate ?? Date()
        return task.isDone(at: doneDate)
    }
    
    func taskIsFinished(_ task: Task) -> Bool {
        let doneDate = state.list?.defaultDueDate ?? Date()
        return task.isFinished(at: doneDate)
    }
    
    func didPressDeleteCompletedTasks() {
        view.showAlert(title: nil,
                       message: "are_you_sure_you_want_to_remove_completed_tasks".localized,
                       actions: [.cancel, .ok("remove".localized)]) { [unowned self] action in
            switch action {
            case .ok:
                self.view.setInteractionsEnabled(false)
                self.interactor.deleteCompletedTasks()
            case .cancel: return
            }
        }
    }
    
}
