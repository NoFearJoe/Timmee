//
//  SwipeTableActionsProvider.swift
//  Timmee
//
//  Created by Ilya Kharabet on 13.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.IndexPath
import SwipeCellKit

enum ProgressAction {
    case none
    case start
    case stop
}

class SwipeTableActionsProvider {

    var onDelete: ((IndexPath) -> Void)?
    var onStart: ((IndexPath) -> Void)?
    var onStop: ((IndexPath) -> Void)?
    var progressActionForRow: ((IndexPath) -> ProgressAction)?
    
    class var backgroundColor: UIColor {
        return AppTheme.current.panelColor
    }
    
    fileprivate lazy var rightSwipeTableOptions: SwipeTableOptions = {
        var options = SwipeTableOptions()
        options.expansionStyle = type(of: self).rightExpansionStyle
        options.transitionStyle = SwipeTransitionStyle.reveal
        options.backgroundColor = type(of: self).backgroundColor
        return options
    }()
    
    fileprivate lazy var leftSwipeTableOptions: SwipeTableOptions = {
        var options = SwipeTableOptions()
        options.expansionStyle = type(of: self).leftExpansionStyle
        options.transitionStyle = SwipeTransitionStyle.reveal
        options.backgroundColor = type(of: self).backgroundColor
        return options
    }()
    
    fileprivate lazy var swipeDeleteAction: SwipeAction = {
        let deleteAction = SwipeAction(style: .default,
                                       title: "delete".localized,
                                       handler:
        { [weak self] (action, indexPath) in
            self?.onDelete?(indexPath)
            action.fulfill(with: .delete)
        })
        deleteAction.image = #imageLiteral(resourceName: "trash")
        deleteAction.textColor = AppTheme.current.redColor
        deleteAction.title = nil
        deleteAction.accessibilityLabel = ""
        deleteAction.backgroundColor = type(of: self).backgroundColor
        deleteAction.transitionDelegate = nil
        return deleteAction
    }()
    
    fileprivate lazy var swipeStartAction: SwipeAction = {
        let startAction = SwipeAction(style: .default,
                                     title: "start".localized,
                                     handler:
        { [weak self] (action, indexPath) in
            self?.onStart?(indexPath)
            action.fulfill(with: .reset)
        })
        startAction.textColor = AppTheme.current.blueColor
        startAction.accessibilityLabel = ""
        startAction.backgroundColor = type(of: self).backgroundColor
        startAction.transitionDelegate = nil
        return startAction
    }()
    
    fileprivate lazy var swipeStopAction: SwipeAction = {
        let stopAction = SwipeAction(style: .default,
                                     title: "stop".localized,
                                     handler:
            { [weak self] (action, indexPath) in
                self?.onStop?(indexPath)
                action.fulfill(with: .reset)
        })
        stopAction.textColor = AppTheme.current.blueColor
        stopAction.accessibilityLabel = ""
        stopAction.backgroundColor = type(of: self).backgroundColor
        stopAction.transitionDelegate = nil
        return stopAction
    }()
    
    func rightSwipeActions(for indexPath: IndexPath) -> [SwipeAction] {
        guard let progressAction = progressActionForRow?(indexPath), progressAction != .none
            else { return [swipeDeleteAction] }
        
        if progressAction == .start {
            return [swipeDeleteAction, swipeStartAction]
        } else {
            return [swipeDeleteAction, swipeStopAction]
        }
    }
    
    var leftSwipeActions: [SwipeAction] {
        return []
    }
    
    func configureLeftSwipeAction(at indexPath: IndexPath) {}
    
    class var rightExpansionStyle: SwipeExpansionStyle? {
        return nil
    }
    
    class var leftExpansionStyle: SwipeExpansionStyle? {
        return nil
    }
    
}

extension SwipeTableActionsProvider: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left:
            configureLeftSwipeAction(at: indexPath)
            return leftSwipeActions
        case .right:
            return rightSwipeActions(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        switch orientation {
        case .left: return leftSwipeTableOptions
        case .right: return rightSwipeTableOptions
        }
    }
    
}

final class ListsSwipeTableActionsProvider: SwipeTableActionsProvider {
    
    var onEdit: ((IndexPath) -> Void)?
    
    fileprivate lazy var swipeEditAction: SwipeAction = {
        let editAction = SwipeAction(style: .default,
                                     title: "edit".localized,
                                     handler:
            { [weak self] (action, indexPath) in
                self?.onEdit?(indexPath)
                action.fulfill(with: .reset)
        })
        editAction.image = #imageLiteral(resourceName: "edit_thin")
        editAction.textColor = AppTheme.current.blueColor
        editAction.title = nil
        editAction.accessibilityLabel = ""
        editAction.backgroundColor = type(of: self).backgroundColor
        editAction.transitionDelegate = nil
        return editAction
    }()
    
    override func rightSwipeActions(for indexPath: IndexPath) -> [SwipeAction] {
        return [swipeDeleteAction, swipeEditAction]
    }
    
}
