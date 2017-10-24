//
//  SwipeTableActionsProvider.swift
//  Timmee
//
//  Created by Ilya Kharabet on 13.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.IndexPath
import SwipeCellKit

class SwipeTableActionsProvider {

    var onDelete: ((IndexPath) -> Void)?
    var onEdit: ((IndexPath) -> Void)?
    
    class var backgroundColor: UIColor {
        return AppTheme.current.scheme.panelColor
    }
    
    fileprivate lazy var swipeTableOptions: SwipeTableOptions = {
        var options = SwipeTableOptions()
        options.expansionStyle = type(of: self).expansionStyle
        options.transitionStyle = SwipeTransitionStyle.reveal
        options.backgroundColor = type(of: self).backgroundColor
//        options.minimumButtonWidth = 48
//        options.maximumButtonWidth = 48
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
        deleteAction.image = UIImage(named: "trash")
        deleteAction.textColor = AppTheme.current.scheme.redColor
        deleteAction.title = nil
        deleteAction.backgroundColor = type(of: self).backgroundColor
        deleteAction.transitionDelegate = nil
        return deleteAction
    }()
    
    fileprivate lazy var swipeEditAction: SwipeAction = {
        let editAction = SwipeAction(style: .default,
                                     title: "edit".localized,
                                     handler:
        { [weak self] (action, indexPath) in
            self?.onEdit?(indexPath)
            action.fulfill(with: .reset)
        })
        editAction.image = UIImage(named: "edit")
        editAction.textColor = AppTheme.current.scheme.blueColor
        editAction.title = nil
        editAction.backgroundColor = type(of: self).backgroundColor
        editAction.transitionDelegate = nil
        return editAction
    }()
    
    var rightSwipeActions: [SwipeAction] {
        return [swipeDeleteAction, swipeEditAction]
    }
    
    var leftSwipeActions: [SwipeAction] {
        return []
    }
    
    func configureLeftSwipeAction(at indexPath: IndexPath) {}
    
    class var expansionStyle: SwipeExpansionStyle? {
        return nil
    }
    
}

extension SwipeTableActionsProvider: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left:
            configureLeftSwipeAction(at: indexPath)
            return leftSwipeActions
        case .right: return rightSwipeActions
        }
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        return swipeTableOptions
    }
    
}
