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
    func willShowLists()
}

final class MainTopViewController: UIViewController {

    @IBOutlet fileprivate weak var overlayView: UIView!
    @IBOutlet fileprivate weak var controlPanel: ControlPanel!
    
    @IBOutlet fileprivate weak var listsViewContainer: BarView!
    @IBOutlet fileprivate weak var addListView: AddListView!
    @IBOutlet fileprivate weak var listsView: UITableView!
    
    @IBOutlet fileprivate var addListViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var listsViewHeightConstrint: NSLayoutConstraint!
    
    weak var output: MainTopViewControllerOutput?
    weak var editingInput: ListRepresentationEditingInput?
    
    fileprivate let listsInteractor = ListsInteractor()
    fileprivate var currentListIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    fileprivate var isListsVisible: Bool = true {
        didSet {
            listsView.hideSwipeCell()
        }
    }
    
    fileprivate var isGroupEditing: Bool = false
    
    fileprivate var isPickingList: Bool = false {
        didSet {
            addListViewHeightConstraint.constant = isPickingList ? 0 : 44
        }
    }
    fileprivate var pickingListCompletion: ((List) -> Void)?
    
    fileprivate let swipeTableActionsProvider = ListsSwipeTableActionsProvider()
    
    
    @IBAction fileprivate func didPressSettingsButton() {
        let viewController = ViewControllersFactory.settings
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction fileprivate func didPressSearchButton() {
        hideLists(animated: true)
        let viewController = ViewControllersFactory.search
        SearchAssembly.assembly(with: viewController)
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction fileprivate func didPressEditButton() {
        controlPanel.setGroupEditingButtonEnabled(false)
        editingInput?.toggleGroupEditing()
        hideLists(animated: true)
    }
    
    @IBAction fileprivate func didPressOverlayView() {
        if isListsVisible {
            hideLists(animated: true)
        }
    }
    
    @IBAction fileprivate func didPressControlPanel() {
        guard !isGroupEditing else { return }
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
        
        addListView.onTap = { [unowned self] in
            self.showListEditor(with: nil)
        }
                
        hideLists(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        controlPanel.applyAppearance()
        listsView.separatorColor = AppTheme.current.panelColor
        addListView.barColor = AppTheme.current.foregroundColor
        listsViewContainer.barColor = AppTheme.current.foregroundColor
        
        listsView.hideSwipeCell(animated: false)
    }
    
    func showLists(animated: Bool) {
        guard !isListsVisible else { return }
        
        output?.willShowLists()
        
        listsView.reloadData()
        listsView.setContentOffset(.zero, animated: false)
        
        (view as? PassthrowView)?.shouldPassTouches = false
        overlayView.isHidden = false
        
        let estimatedHeight = view.frame.height * 0.75
        let extraHeight = estimatedHeight.truncatingRemainder(dividingBy: 44)
        listsViewHeightConstrint.constant = estimatedHeight - extraHeight
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.overlayView.backgroundColor = UIColor(rgba: "202020").withAlphaComponent(0.5)
                self.view.layoutIfNeeded()
            }) { _ in
                self.isListsVisible = true
            }
        } else {
            overlayView.backgroundColor = UIColor(rgba: "202020").withAlphaComponent(0.5)
            isListsVisible = true
        }
    }
    
    func hideLists(animated: Bool) {
        guard isListsVisible else { return }
        
        isPickingList = false
        (view as? PassthrowView)?.shouldPassTouches = true
        
        listsViewHeightConstrint.constant = 0
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.overlayView.backgroundColor = .clear
                self.view.layoutIfNeeded()
            }) { _ in
                self.overlayView.isHidden = true
                self.isListsVisible = false
            }
        } else {
            view.backgroundColor = .clear
            overlayView.isHidden = true
            isListsVisible = false
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
                cell.delegate = isPickingList ? nil : swipeTableActionsProvider
            } else {
                cell.contentView.alpha = isPickingList ? 0.5 : 1
                cell.delegate = nil
            }
        }
        
        return cell
    }
    
}

extension MainTopViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPickingList {
            if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) {
                guard !(list is SmartList) else { return }
                pickingListCompletion?(list)
                hideLists(animated: true) // TODO: Может сначала алерт?
            }
        } else {
            setCurrentList(indexPath)
            tableView.reloadData()
            hideLists(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? ListCell)?.applyAppearance()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return ListsSeparatorView()
    }
    
}

extension MainTopViewController: ListEditorOutput {

    func listCreated() {
        hideLists(animated: false)
        output?.listCreated()
    }

}

extension MainTopViewController: ListRepresentationEditingOutput {
    
    func groupEditingToggled(to isEditing: Bool) {
        isGroupEditing = isEditing
        controlPanel.setGroupEditingButtonEnabled(true)
        controlPanel.changeGroupEditingState(to: isEditing)
    }
    
    func didAskToShowListsForMoveTasks(completion: @escaping (List) -> Void) {
        isPickingList = true
        pickingListCompletion = completion
        showLists(animated: true)
    }
    
    func setGroupEditingVisible(_ isVisible: Bool) {
        controlPanel.setGroupEditingVisible(isVisible)
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
        
        alert.addAction(UIAlertAction(title: "remove".localized, style: .destructive, handler: { [weak self] _ in
            self?.removeList(list)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func removeList(_ list: List) {
        listsInteractor.removeList(list)
    }

}

final class ListsSeparatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(AppTheme.current.panelColor.cgColor)
        context.setLineWidth(1)
        context.setLineDash(phase: 2, lengths: [4, 4])
        
        context.move(to: CGPoint(x: 0, y: 0.5))
        context.addLine(to: CGPoint(x: rect.width, y: 0.5))
        context.strokePath()
    }
    
}
