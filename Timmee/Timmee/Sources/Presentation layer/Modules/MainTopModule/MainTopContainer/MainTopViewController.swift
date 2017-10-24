//
//  MainTopViewController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol MainTopViewControllerOutput: class {
    func currentListChanged(to list: List)
    func listCreated()
}

final class MainTopViewController: UIViewController {

    @IBOutlet fileprivate weak var overlayView: UIView!
    @IBOutlet fileprivate weak var controlPanel: ControlPanel!
    @IBOutlet fileprivate weak var listsView: UITableView!
    @IBOutlet fileprivate weak var listsViewHeightConstrint: NSLayoutConstraint!
    
    weak var output: MainTopViewControllerOutput?
    
    fileprivate let listsInteractor = ListsInteractor()
    fileprivate var currentListIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    fileprivate var isListsVisible: Bool = false {
        didSet {
            listsView.hideSwipeCell()
        }
    }
    
    fileprivate let swipeTableActionsProvider = SwipeTableActionsProvider()
    
    
    @IBAction fileprivate func didPressSettingsButton() {
        // Show settings
    }
    
    @IBAction fileprivate func didPressSearchButton() {
//        hideLists(animated: true)
//        // Show add list VC
    }
    
    @IBAction fileprivate func didPressAddListButton() {
        showListEditor(with: nil)
    }
    
    @IBAction fileprivate func didPressOverlayView() {
        if isListsVisible {
            hideLists(animated: true)
        }
    }
    
    @IBAction fileprivate func didPressControlPanel() {
        isListsVisible ? hideLists(animated: true) : showLists(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listsInteractor.output = self
        
        listsInteractor.requestLists()
                
        swipeTableActionsProvider.onDelete = { [weak self] indexPath in
            self?.handleListDeletion(at: indexPath)
        }
        swipeTableActionsProvider.onEdit = { [weak self] indexPath in
            if let list = self?.listsInteractor.list(at: indexPath.row, in: indexPath.section) {
                self?.showListEditor(with: list)
            }
        }
        
        hideLists(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        controlPanel.applyAppearance()
        listsView.separatorColor = AppTheme.current.scheme.panelColor
        
        listsView.hideSwipeCell(animated: false)
    }
    
    func showLists(animated: Bool) {
        listsView.reloadData()
        
        isListsVisible = true
        (view as? PassthrowView)?.shouldPassTouches = false
        overlayView.isHidden = false
        
        listsViewHeightConstrint.constant = max(view.frame.height * 0.5, 256)
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.overlayView.backgroundColor = UIColor(rgba: "202020").withAlphaComponent(0.5)
                self.view.layoutIfNeeded()
            }
        } else {
            overlayView.backgroundColor = UIColor(rgba: "202020").withAlphaComponent(0.5)
        }
    }
    
    func hideLists(animated: Bool) {
        isListsVisible = false
        (view as? PassthrowView)?.shouldPassTouches = true
        
        listsViewHeightConstrint.constant = 0
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.overlayView.backgroundColor = .clear
                self.view.layoutIfNeeded()
            }) { _ in
                self.overlayView.isHidden = true
            }
        } else {
            view.backgroundColor = .clear
            overlayView.isHidden = true
        }
    }
    
    
    func setCurrentList(_ indexPath: IndexPath) {        
        currentListIndexPath = indexPath
        
        if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) {
            controlPanel.showList(list)
            output?.currentListChanged(to: list)
            listsView.reloadRows(at: [indexPath], with: .none)
        }
    }

}

extension MainTopViewController: ListsInteractorOutput {
    
    func prepareCoreDataObserver(_ tableViewManageble: TableViewManageble) {
        tableViewManageble.setTableView(listsView)
    }
    
    func didFetchInitialLists() {
        setCurrentList(IndexPath(row: 0, section: 0))
    }
    
    func didUpdateListsCount(_ count: Int) {
        if count == 0 {
            // TODO
        } else {
            
        }
    }
    
    func didUpdateLists(with change: CoreDataItemChange) {
        switch change {
        case .insertion(let indexPath):
            setCurrentList(indexPath)
        case .deletion(let indexPath):
            if indexPath == currentListIndexPath {
                setCurrentList(IndexPath(row: 0, section: 0))
            }
        case .update(let indexPath):
            guard indexPath == currentListIndexPath else { return }
            if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) {
                controlPanel.showList(list)
            }
        case .move(let indexPath, let newIndexPath):
            if indexPath == currentListIndexPath {
                setCurrentList(newIndexPath)
            }
        }
    }
    
}

extension MainTopViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return listsInteractor.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listsInteractor.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell",
                                                 for: indexPath) as! ListCell
        
        if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) {
            cell.setList(list)
            cell.setListSelected(indexPath == currentListIndexPath)
            
            if !(list is SmartList) {
                cell.delegate = swipeTableActionsProvider
            } else {
                cell.delegate = nil
            }
        }
        
        return cell
    }
    
}

extension MainTopViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setCurrentList(indexPath)
        tableView.reloadData()
        hideLists(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? ListCell)?.applyAppearance()
    }
    
}

extension MainTopViewController: ListEditorOutput {

    func listCreated() {
        hideLists(animated: false)
        output?.listCreated()
    }

}

fileprivate extension MainTopViewController {

    func showListEditor(with list: List?) {
        let listEditorView = ViewControllersFactory.listEditor
        listEditorView.loadViewIfNeeded()
        
        let listEditorInput = ListEditorAssembly.assembly(with: listEditorView)
        listEditorInput.output = self
        listEditorInput.setList(list)
        
        present(listEditorView, animated: true, completion: nil)
    }
    
    func handleListDeletion(at indexPath: IndexPath) {
        if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) {
            if listsInteractor.tasksCount(in: list) > 0 {
                showListDeletionAlert(with: list)
            } else {
                removeList(list)
            }
        }
    }
    
    func showListDeletionAlert(with list: List) {
        let alert = UIAlertController(title: "remove_list".localized,
                                      message: "are_you_sure_you_want_to_delete_the_list_with_all_tasks".localized,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "i_am_sure".localized, style: .destructive, handler: { [weak self] _ in
            self?.removeList(list)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func removeList(_ list: List) {
        listsInteractor.removeList(list)
    }

}
