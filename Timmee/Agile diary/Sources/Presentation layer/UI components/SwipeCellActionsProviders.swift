//
//  SwipeCellActionsProviders.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class CellDeleteSwipeActionProvider {
    
    var onDelete: ((IndexPath) -> Void)?
    
    static var backgroundColor: UIColor {
        return .clear
    }
    
    fileprivate lazy var swipeTableOptions: SwipeTableOptions = {
        var options = SwipeTableOptions()
        options.expansionStyle = nil
        options.transitionStyle = SwipeTransitionStyle.drag
        options.backgroundColor = CellDeleteSwipeActionProvider.backgroundColor
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
        deleteAction.textColor = AppTheme.current.colors.wrongElementColor
        deleteAction.title = nil
        deleteAction.backgroundColor = CellDeleteSwipeActionProvider.backgroundColor
        deleteAction.transitionDelegate = nil
        return deleteAction
    }()
    
}

extension CellDeleteSwipeActionProvider: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left: return nil
        case .right: return [swipeDeleteAction]
        }
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        return swipeTableOptions
    }
    
}

final class TodayHabitCellSwipeActionsProvider {
    
    var shouldShowLinkAction: ((IndexPath) -> Bool)?
    var shouldShowEditAction: ((IndexPath) -> Bool)?
    
    var onLink: ((IndexPath) -> Void)?
    var onEdit: ((IndexPath) -> Void)?
    
    static var backgroundColor: UIColor {
        return .clear
    }
    
    private lazy var swipeTableOptions: SwipeTableOptions = {
        var options = SwipeTableOptions()
        options.expansionStyle = nil
        options.transitionStyle = SwipeTransitionStyle.drag
        options.backgroundColor = TodayHabitCellSwipeActionsProvider.backgroundColor
        return options
    }()
    
    private lazy var swipeLinkAction: SwipeAction = {
        let action = SwipeAction(style: .default,
                                 title: "open_link".localized,
                                 handler:
            { [weak self] (action, indexPath) in
                self?.onLink?(indexPath)
                action.fulfill(with: .reset)
        })
        action.image = #imageLiteral(resourceName: "link")
        action.textColor = AppTheme.current.colors.mainElementColor
        action.title = nil
        action.backgroundColor = TodayHabitCellSwipeActionsProvider.backgroundColor
        action.transitionDelegate = nil
        return action
    }()
    
    private lazy var swipeEditAction: SwipeAction = {
        let action = SwipeAction(style: .default,
                                 title: "edit".localized,
                                 handler:
            { [weak self] (action, indexPath) in
                self?.onEdit?(indexPath)
                action.fulfill(with: .reset)
        })
        action.image = #imageLiteral(resourceName: "edit")
        action.title = nil
        action.backgroundColor = TodayHabitCellSwipeActionsProvider.backgroundColor
        action.transitionDelegate = nil
        return action
    }()
    
}

extension TodayHabitCellSwipeActionsProvider: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left: return nil
        case .right:
            var actions: [SwipeAction] = []
            if shouldShowEditAction?(indexPath) == true {
                swipeEditAction.textColor = AppTheme.current.colors.activeElementColor
                actions.append(swipeEditAction)
            }
            if shouldShowLinkAction?(indexPath) == true {
                actions.append(swipeLinkAction)
            }
            return actions
        }
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        return swipeTableOptions
    }
    
}

final class TodayTargetCellSwipeActionsProvider {
    
    var shouldShowDoneAction: ((IndexPath) -> Bool)?
    var shouldShowEditAction: ((IndexPath) -> Bool)?
    
    var onDone: ((IndexPath) -> Void)?
    var onEdit: ((IndexPath) -> Void)?
    
    static var backgroundColor: UIColor {
        return .clear
    }
    
    private lazy var swipeTableOptions: SwipeTableOptions = {
        var options = SwipeTableOptions()
        options.expansionStyle = nil
        options.transitionStyle = SwipeTransitionStyle.drag
        options.backgroundColor = TodayTargetCellSwipeActionsProvider.backgroundColor
        return options
    }()
    
    private lazy var swipeDoneAction: SwipeAction = {
        let action = SwipeAction(style: .default,
                                 title: "done_target".localized,
                                 handler:
            { [weak self] (action, indexPath) in
                self?.onDone?(indexPath)
                action.fulfill(with: .reset)
        })
        action.image = #imageLiteral(resourceName: "checkmark")
        action.textColor = AppTheme.current.colors.mainElementColor
        action.title = nil
        action.backgroundColor = TodayTargetCellSwipeActionsProvider.backgroundColor
        action.transitionDelegate = nil
        return action
    }()
    
    private lazy var swipeRecoverAction: SwipeAction = {
        let action = SwipeAction(style: .default,
                                 title: "recover_target".localized,
                                 handler:
            { [weak self] (action, indexPath) in
                self?.onDone?(indexPath)
                action.fulfill(with: .reset)
        })
        action.image = #imageLiteral(resourceName: "repeat")
        action.textColor = AppTheme.current.colors.mainElementColor
        action.title = nil
        action.backgroundColor = TodayTargetCellSwipeActionsProvider.backgroundColor
        action.transitionDelegate = nil
        return action
    }()
    
    private lazy var swipeEditAction: SwipeAction = {
        let action = SwipeAction(style: .default,
                                 title: "edit".localized,
                                 handler:
            { [weak self] (action, indexPath) in
                self?.onEdit?(indexPath)
                action.fulfill(with: .reset)
        })
        action.image = #imageLiteral(resourceName: "edit")
        action.title = nil
        action.backgroundColor = TodayHabitCellSwipeActionsProvider.backgroundColor
        action.transitionDelegate = nil
        return action
    }()
    
}

extension TodayTargetCellSwipeActionsProvider: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left: return nil
        case .right:
            var actions: [SwipeAction] = []
            if shouldShowEditAction?(indexPath) == true {
                swipeEditAction.textColor = AppTheme.current.colors.activeElementColor
                actions.append(swipeEditAction)
            }
            if shouldShowDoneAction?(indexPath) == true {
                actions.append(swipeDoneAction)
            } else {
                actions.append(swipeRecoverAction)
            }
            return actions
        }
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        return swipeTableOptions
    }
    
}
