//
//  TableListRepresentationAdapter.swift
//  Timmee
//
//  Created by i.kharabet on 12.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

enum ListRepresentationEditingMode {
    case `default`
    case group
    
    var next: ListRepresentationEditingMode {
        switch self {
        case .default: return .group
        case .group: return .default
        }
    }
}

protocol TableListRepresentationAdapterInput: class {
    func setupTableView(_ tableView: UITableView)
    func setEditingMode(_ mode: ListRepresentationEditingMode)
    func applyEditingMode(_ mode: ListRepresentationEditingMode, toCell cell: TableListRepresentationCell)
}

protocol TableListRepresentationAdapterOutput: class {
    func didPressEdit(for task: Task)
    func didPressDelete(task: Task)
    func didPressComplete(task: Task)
    func didPressStart(task: Task)
    func didPressStop(task: Task)
    
    func didToggleImportancy(of task: Task)
    
    func didCheckTask(_ task: Task)
    func didUncheckTask(_ task: Task)
    func taskIsChecked(_ task: Task) -> Bool
}

final class TableListRepresentationAdapter: NSObject {
    
    weak var dataSource: TableListRepresentationDataSource!
    weak var output: TableListRepresentationAdapterOutput!
    
    private var editingMode: ListRepresentationEditingMode = .default
    
    private lazy var swipeTableActionsProvider: SwipeTaskActionsProvider = {
        let provider = SwipeTaskActionsProvider()
        setupSwipeActionsProvider(provider)
        return provider
    }()
    
}

extension TableListRepresentationAdapter: TableListRepresentationAdapterInput {
    
    func setupTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setEditingMode(_ mode: ListRepresentationEditingMode) {
        self.editingMode = mode
    }
    
    func applyEditingMode(_ mode: ListRepresentationEditingMode, toCell cell: TableListRepresentationCell) {
        cell.setGroupEditing(mode == .group, animated: true)
        
        switch mode {
        case .default: cell.delegate = swipeTableActionsProvider
        case .group: cell.delegate = nil
        }
    }
    
}

extension TableListRepresentationAdapter: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sectionsCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.itemsCount(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableListRepresentationCell",
                                                 for: indexPath) as! TableListRepresentationCell
        
        if let task = dataSource.item(at: indexPath.row, in: indexPath.section) {
            cell.setTask(task)
            
            cell.isChecked = output.taskIsChecked(task)
            
            cell.onTapToImportancy = { [unowned self] in
                guard let indexPath = tableView.indexPath(for: cell) else { return }
                if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                    self.output.didToggleImportancy(of: task)
                }
            }
            
            cell.onCheck = { [unowned self] isChecked in
                if isChecked { self.output.didCheckTask(task) }
                else { self.output.didUncheckTask(task) }
            }
        }
        
        applyEditingMode(editingMode, toCell: cell)
        
        return cell
    }
    
}

extension TableListRepresentationAdapter: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard editingMode == .default else { return }
        if let task = dataSource.item(at: indexPath.row, in: indexPath.section) {
            output.didPressEdit(for: task)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Если это секция незавершенных задач && есть секция завершенных задач и секция завершенных задач не пустая -> показывать кнопку
        if let sectionInfo = dataSource.sectionInfo(forSectionAt: section), sectionInfo.name == "1", sectionInfo.numberOfItems > 0 {
            return 40
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 56
        
        if let item = dataSource.item(at: indexPath.row, in: indexPath.section) {
            if item.isDone { height -= 15 }
            if item.tags.count > 0 { height += 6 }
            return height
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Если это секция незавершенных задач && есть секция завершенных задач и секция завершенных задач не пустая -> показывать кнопку
        if let sectionInfo = dataSource.sectionInfo(forSectionAt: section), sectionInfo.name == "1", sectionInfo.numberOfItems > 0 {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ListRepresentationFooter") as! ListRepresentationFooter
            
            view.title = "completed_tasks".localized
            
            view.applyAppearance()
            
            return view
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? TableListRepresentationCell)?.applyAppearance()
    }
    
}

private extension TableListRepresentationAdapter {
    
    func setupSwipeActionsProvider(_ provider: SwipeTaskActionsProvider) {
        func performWithTask(at indexPath: IndexPath, action: @escaping (Task) -> Void) {
            if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                action(task)
            }
        }
        
        provider.onDelete = { [unowned self] indexPath in
            performWithTask(at: indexPath) { [unowned self] task in
                self.output.didPressDelete(task: task)
            }
        }
        provider.onStart = { [unowned self] indexPath in
            performWithTask(at: indexPath) { [unowned self] task in
                self.output.didPressStart(task: task)
            }
        }
        provider.onStop = { [unowned self] indexPath in
            performWithTask(at: indexPath) { [unowned self] task in
                self.output.didPressStop(task: task)
            }
        }
        provider.onDone = { [unowned self] indexPath in
            performWithTask(at: indexPath) { [unowned self] task in
                self.output.didPressComplete(task: task)
            }
        }
        provider.isDone = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                return task.isDone
            }
            return false
        }
        provider.progressActionForRow = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                if task.isDone { return .none }
                else { return task.inProgress ? .stop : .start }
            }
            return .none
        }
    }
    
}
