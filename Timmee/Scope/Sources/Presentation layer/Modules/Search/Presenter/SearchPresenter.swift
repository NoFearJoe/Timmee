//
//  SearchPresenter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 07.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.IndexPath

final class SearchPresenter {
    
    weak var view: SearchViewInput!
    var interactor: SearchInteractorInput!
    
}

extension SearchPresenter: SearchViewOutput {
    
    func searchStringChanged(to string: String) {
        interactor.search(string)
    }
    
    func searchStringCleared() {
        interactor.search("")
        view.setInitialPlaceholderVisible(true)
    }
    
    func didPressDelete(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.deleteTask(task)
    }
    
    func didPressComplete(task: Task) {
        view.setInteractionsEnabled(false)
        interactor.completeTask(task, doneDate: Date()) { [weak self] in
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
    
    func toggleImportancy(of task: Task) {
        view.setInteractionsEnabled(false)
        interactor.toggleImportancy(of: task)
    }
    
}

extension SearchPresenter: SearchInteractorOutput {
    
    func tasksFetched(count: Int) {
        view.updateSearchResults()
        view.setNoSearchResultsPlaceholderVisible(count == 0)
    }
    
    func operationCompleted() {
        view.setInteractionsEnabled(true)
    }
    
    func prepareCacheObserver(_ cacheSubscribable: CacheSubscribable) {
        view.subscribeToCacheObserver(cacheSubscribable)
    }
    
}
