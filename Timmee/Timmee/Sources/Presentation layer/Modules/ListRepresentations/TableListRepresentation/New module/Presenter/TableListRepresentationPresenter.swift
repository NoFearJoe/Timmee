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
    
    func performGroupEditingAction(_ action: TargetGroupEditingAction) {
        view.setInteractionsEnabled(false)
        switch action {
        case .delete:
            interactor.deleteTasks(state.checkedTasks)
        case .complete:
            interactor.completeTasks(state.checkedTasks)
        case let .move(list):
            interactor.moveTasks(state.checkedTasks, toList: list)
        }
        state.checkedTasks = []
//        view.setEditingMode(.default)
    }
    
}

extension TableListRepresentationPresenter: TableListRepresentationEditingInput {
    
    func setEditingMode(_ mode: ListRepresentationEditingMode) {
        state.editingMode = mode
        view.setEditingMode(mode)
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
    
    func didToggleImportancy(of task: Task) {
        view.setInteractionsEnabled(false)
        interactor.toggleImportancy(of: task)
    }
    
    func didCheckTask(_ task: Task) {
        state.checkedTasks.append(task)
        //        view.setGroupEditingActionsEnabled(!state.checkedTasks.isEmpty)
        //        if state.checkedTasks.contains(where: { !$0.isDone }) || state.checkedTasks.isEmpty {
        //            view.setCompletionGroupEditingAction(.complete)
        //        } else {
        //            view.setCompletionGroupEditingAction(.recover)
        //        }
    }
    
    func didUncheckTask(_ task: Task) {
        state.checkedTasks.remove(object: task)
        //        view.setGroupEditingActionsEnabled(!state.checkedTasks.isEmpty)
        //        if state.checkedTasks.contains(where: { !$0.isDone }) || state.checkedTasks.isEmpty {
        //            view.setCompletionGroupEditingAction(.complete)
        //        } else {
        //            view.setCompletionGroupEditingAction(.recover)
        //        }
    }
    
    func taskIsChecked(_ task: Task) -> Bool {
        return state.checkedTasks.contains(task)
    }
    
    func groupEditingWillToggle(to isEditing: Bool) {
        //        editingOutput?.groupEditingWillToggle(to: isEditing)
    }
    
    func groupEditingToggled(to isEditing: Bool) {
        //        editingOutput?.groupEditingToggled(to: isEditing)
        state.checkedTasks = []
    }
    
}