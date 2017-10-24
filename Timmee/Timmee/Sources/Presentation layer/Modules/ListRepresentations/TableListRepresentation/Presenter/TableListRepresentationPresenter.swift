//
//  TableListRepresentationPresenter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIViewController
import struct Foundation.Date
import struct Foundation.IndexPath
import class UIKit.UITableView

final class TableListRepresentationPresenter {

    struct State {
        var list: List?
        var isClear: Bool = false
        var enteredTaskTitle: String?
        
        var isCompletedTasksVisible: Bool = false
        var shouldResetOffsetAfterReload: Bool = false
        
        mutating func reset() {
            isCompletedTasksVisible = false
            shouldResetOffsetAfterReload = false
        }
    }
    
    weak var output: ListRepresentationOutput?
    
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
        view.setTaskTitleFieldFirstResponder()
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
        } else {
            view.hideNoTasksPlaceholder()
        }
        
        if interactor.sectionInfo(forSectionWithName: "0") == nil
            || interactor.sectionInfo(forSectionWithName: "0")!.numberOfItems == 0 {
            state.isCompletedTasksVisible = true
        }
        view.reloadCompletedTasks()
    }
    
    func operationCompleted() {
        view.setInteractionsEnabled(true)
    }
    
    func shouldShowCompletedTasks() -> Bool {
        return state.isCompletedTasksVisible
    }
    
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble) {
        view.connect(with: tableViewManageble)
    }

}

extension TableListRepresentationPresenter: TableListRepresentationViewOutput {

    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        guard let list = state.list else { return }
        interactor.fetchTasks(by: list.id)
    }
    
    func didInputTaskTitle(_ title: String?) {
        state.enteredTaskTitle = title
    }
    
    func didPressAddTaskButton() {
        if let title = state.enteredTaskTitle {
            view.setInteractionsEnabled(false)
            interactor.addShortTask(with: title, dueDate: dateForTodaySmartList())
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
    
    func toggleCompletedTasksVisibility() {
        state.isCompletedTasksVisible = !state.isCompletedTasksVisible
        view.reloadCompletedTasks()
    }
    
    func isCompletedTasksVisible() -> Bool {
        return state.isCompletedTasksVisible
    }
    
    func toggleImportancy(of task: Task) {
        view.setInteractionsEnabled(false)
        interactor.toggleImportancy(of: task)
    }
    
}

fileprivate extension TableListRepresentationPresenter {

    func dateForTodaySmartList() -> Date? {
        if let smartList = state.list as? SmartList, smartList.smartListType == .today {
            return Date.startOfNextHour
        }
        return nil
    }

}
