//
//  TasksImportPresenter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.IndexPath

protocol TasksImportInput: class {
    weak var output: TasksImportOutput? { get set }
    func setSelectedTasks(_ tasks: [Task])
    func setList(_ list: List)
}

protocol TasksImportOutput: class {
    func tasksSelectionFinished(with tasks: [Task])
}

final class TasksImportPresenter {

    var interactor: (TasksImportInteractorInput & TasksImportDataSource)!
    var router: TasksImportRouterInput!
    weak var view: TasksImportViewInput!
    
    weak var output: TasksImportOutput?
    
    fileprivate var list: List?
    
    fileprivate var selectedTasks: [Task] = [] {
        didSet {
            updateDoneButton()
        }
    }
    
    fileprivate var initialSelectedTasks: [Task] = [] {
        didSet {
            updateDoneButton()
        }
    }
    
    fileprivate var isSearching = false
    
    fileprivate func updateDoneButton() {
        view.setDoneButtonEnabled(selectedTasks.count + initialSelectedTasks.count > 0)
    }

}

extension TasksImportPresenter: TasksImportInput {

    func setSelectedTasks(_ tasks: [Task]) {
        self.initialSelectedTasks = tasks
        self.selectedTasks = tasks
    }
    
    func setList(_ list: List) {
        self.list = list
    }

}

extension TasksImportPresenter: TasksImportInteractorOutput {

    func tasksFetched(count: Int) {
        if count == 0 {
            if isSearching {
                view.showError("no_searched_tasks".localized)
            } else {
                view.showError("no_tasks_to_import".localized)
            }
        } else {
            view.hideError()
        }
    }
    
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble) {
        view.connect(with: tableViewManageble)
    }

}

extension TasksImportPresenter: TasksImportViewOutput {

    func viewDidLoad() {
        interactor.fetchTasks(excludeList: list)
    }
    
    func viewWillAppear() {
        updateDoneButton()
    }
    
    func didSelectTask(at indexPath: IndexPath) {
        if let selectedTask = self.task(at: indexPath) {
            if let index = selectedTasks.index(where: { $0.id == selectedTask.id }) {
                selectedTasks.remove(at: index)
            } else {
                selectedTasks.append(selectedTask)
            }
            view.reload(at: indexPath)
        }
    }
    
    func didChangeSearchString(to string: String) {
        if string.trimmed.characters.count > 0 {
            isSearching = true
            interactor.searchTasks(by: string, excludeList: list)
        } else {
            isSearching = false
            interactor.fetchTasks(excludeList: list)
        }
    }
    
    func didFinishSearching() {
        isSearching = false
        interactor.fetchTasks(excludeList: list)
    }
    
    func closeButtonPressed() {
        router.close()
    }
    
    func doneButtonPressed() {
        output?.tasksSelectionFinished(with: selectedTasks)
        router.close()
    }

}

extension TasksImportPresenter: TasksImportViewDataSource {

    func numberOfSections() -> Int {
        return interactor.sectionsCount()
    }
    
    func numberOfTasks(in section: Int) -> Int {
        return interactor.itemsCount(in: section)
    }
    
    func task(at indexPath: IndexPath) -> Task? {
        return interactor.item(at: indexPath)
    }
    
    func sectionTitle(forSectionAt index: Int) -> String? {
        return interactor.sectionTitle(forSectionAt: index)
    }
    
    func isTaskChecked(at indexPath: IndexPath) -> Bool {
        if let task = self.task(at: indexPath) {
            return selectedTasks.contains(where: { $0.id == task.id })
        }
        return false
    }

}
