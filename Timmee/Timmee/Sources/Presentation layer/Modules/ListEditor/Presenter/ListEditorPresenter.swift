//
//  ListEditorPresenter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 10.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.DispatchQueue

protocol ListEditorInput: class {
    weak var output: ListEditorOutput? { get set }
    
    func setList(_ list: List?)
}

protocol ListEditorOutput: class {
    func listCreated()
}

final class ListEditorPresenter {

    var interactor: ListEditorInteractorInput!
    var router: ListEditorRouterInput!
    weak var view: ListEditorViewInput!
    
    weak var output: ListEditorOutput?
    
    fileprivate var list: List!
    
    fileprivate var importedTasks: [Task] = []
    
    fileprivate var isNewList = false

}

extension ListEditorPresenter: ListEditorInput {

    func setList(_ list: List?) {
        isNewList = list == nil
        self.list = list?.copy ?? interactor.createList()
        
        view.setListTitle(self.list.title)
        view.setListNote(self.list.note)
        view.setListIcon(self.list.icon)
        view.setImportedTasksCount(importedTasks.count)
    }

}

extension ListEditorPresenter: ListEditorViewOutput {

    func doneButtonPressed() {
        list.title = self.view.getTitle()
        list.note = self.view.getNote()
        
        saveList(force: true, success: { [weak self] in
            DispatchQueue.main.async {
                if self?.isNewList == true {
                    self?.output?.listCreated()
                }
            }
            self?.router.close()
        })
    }
    
    func closeButtonPressed() {
        router.close()
    }
    
    func importTasksButtonPressed() {
        router.showTasksImport()
    }
    
    func listTitleEntered(_ title: String) {
        list.title = title
    }
    
    func listNoteEntered(_ note: String) {
        list.note = note
    }
    
    func listIconSelected(_ icon: ListIcon) {
        list.icon = icon
    }

}

extension ListEditorPresenter: ListEditorInteractorOutput {

    

}

extension ListEditorPresenter: ListEditorRouterOutput {

    func willShowTasksImport(_ input: TasksImportInput) {
        input.setList(list)
        input.setSelectedTasks(importedTasks)
        input.output = self
    }

}

extension ListEditorPresenter: TasksImportOutput {

    func tasksSelectionFinished(with tasks: [Task]) {
        importedTasks = tasks
        view.setImportedTasksCount(tasks.count)
    }

}

fileprivate extension ListEditorPresenter {
    
    func saveList(force: Bool = false, success: (() -> Void)? = nil) {
        interactor.saveList(list, tasks: importedTasks, success: success, fail: nil)
    }

}
