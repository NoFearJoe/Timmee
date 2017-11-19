//
//  SubtasksEditor.swift
//  Timmee
//
//  Created by i.kharabet on 13.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class SubtasksEditor: UIViewController {
    
    weak var output: SubtasksEditorOutput!
    weak var dataSource: SubtasksEditorDataSource!
    weak var taskProvider: SubtasksEditorTaskProvider! {
        didSet {
            interactor.taskProvider = taskProvider
        }
    }
    
    weak var contentScrollView: UIScrollView!
    weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate var addSubtaskView: AddSubtaskView!
    @IBOutlet fileprivate var tableView: ReorderableTableView!
    
    fileprivate let interactor = SubtasksEditorInteractor()
    
    fileprivate let keyboardManager = KeyboardManager()

    fileprivate let subtaskCellActionsProvider = SubtaskCellActionsProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDependencies()
        
        setupTabeViewContentSizeObserver()
        
        addSubtaskView.didEndEditing = { [weak self] title in
            if !title.trimmed.isEmpty {
                self?.output?.addSubtask(with: title)
            }
        }
        
        tableView.estimatedRowHeight = 36
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.longPressReorderDelegate = self
        
        subtaskCellActionsProvider.onDelete = { [weak self] indexPath in
            self?.output?.removeSubtask(at: indexPath.row)
        }
        
        keyboardManager.keyboardWillAppear = { [weak self] frame, duration in
            guard let `self` = self else { return }
            guard self.addSubtaskView.isFirstResponder else { return }
            
            let addSubtasksFrame = self.contentScrollView.convert(self.addSubtaskView.frame, from: self.view)
            let offsetY = addSubtasksFrame.minY
            UIView.animate(withDuration: duration, animations: {
                self.contentScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadSubtasks()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "contentSize" {
            if let contentSizeValue = change?[.newKey] as? NSValue {
                let contentHeight = max(0, contentSizeValue.cgSizeValue.height) + addSubtaskView.bounds.height
                updateContainerViewHeight(contentHeight)
            }
        }
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
}

extension SubtasksEditor {
    
    func reloadSubtasks() {
        tableView.reloadData()
    }
    
    func batchReloadSubtask(insertions: [Int] = [], deletions: [Int] = [], updates: [Int] = []) {
        UIView.performWithoutAnimation {
            let contentOffset = self.contentScrollView.contentOffset
            
            self.tableView.beginUpdates()
            
            deletions.forEach { index in
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)],
                                          with: .none)
            }
            
            insertions.forEach { index in
                self.tableView.insertRows(at: [IndexPath(row: index, section: 0)],
                                          with: .none)
            }
            
            updates.forEach { index in
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                          with: .none)
            }
            
            self.tableView.endUpdates()
            
            self.contentScrollView.contentOffset = contentOffset
        }
    }
    
}

extension SubtasksEditor: SubtasksEditorInteractorOutput {
    
    func subtasksInserted(at indexes: [Int]) {
        batchReloadSubtask(insertions: indexes)
    }
    
    func subtasksRemoved(at indexes: [Int]) {
        batchReloadSubtask(deletions: indexes)
    }
    
    func subtasksUpdated(at indexes: [Int]) {
        batchReloadSubtask(updates: indexes)
    }
    
}

extension SubtasksEditor: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.subtasksCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtaskCell",
                                                 for: indexPath) as! SubtaskCell
        
        if let subtask = dataSource.subtask(at: indexPath.row) {
            cell.title = subtask.title
            cell.isDone = subtask.isDone
            
            cell.onBeginEditing = { [unowned self] in
                let frame = cell.frame
                let normalFrame = self.contentScrollView.convert(frame, from: tableView)
                UIView.animate(withDuration: 0.2, animations: {
                    self.contentScrollView.contentOffset = CGPoint(x: 0, y: normalFrame.minY)
                })
            }
            cell.onDone = { [unowned self] in
                self.output?.doneSubtask(at: indexPath.row)
            }
            cell.onChangeTitle = { [unowned self] title in
                self.output?.updateSubtask(at: indexPath.row, newTitle: title)
            }
            cell.onChangeHeight = { [unowned self] height in
                let currentOffset = self.contentScrollView.contentOffset
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    
                    if currentOffset != .zero {
                        self.contentScrollView.contentOffset = currentOffset
                    }
                }
            }
            
            cell.delegate = subtaskCellActionsProvider
        }
        
        return cell
    }
    
}

extension SubtasksEditor: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SubtaskCell
        cell.beginEditing()
    }
    
}

extension SubtasksEditor: ReorderableTableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   reorderRowsFrom fromIndexPath: IndexPath,
                   to toIndexPath: IndexPath) {
        output.exchangeSubtasks(at: (fromIndexPath.row, toIndexPath.row))
    }
    
    func tableView(_ tableView: UITableView, showDraggingView view: UIView, at indexPath: IndexPath) {
        view.backgroundColor = AppTheme.current.foregroundColor
    }
    
    func tableView(_ tableView: UITableView, hideDraggingView view: UIView, at indexPath: IndexPath) {
        view.backgroundColor = .clear
    }
    
}

fileprivate extension SubtasksEditor {
    
    func setupDependencies() {
        interactor.output = self
        dataSource = interactor
        output = interactor
    }
    
    func setupTabeViewContentSizeObserver() {
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    func updateContainerViewHeight(_ newHeight: CGFloat) {
        containerViewHeightConstraint.constant = newHeight
        let offsetY = addSubtaskView.frame.minY
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            
            guard self.addSubtaskView.isFirstResponder else { return }
            self.contentScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }
    
}
