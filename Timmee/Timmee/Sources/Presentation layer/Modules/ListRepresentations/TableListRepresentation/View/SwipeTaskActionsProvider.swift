//
//  SwipeTaskActionsProvider.swift
//  Timmee
//
//  Created by Ilya Kharabet on 25.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class SwipeTaskActionsProvider: SwipeTableActionsProvider {

    var onDone: ((IndexPath) -> Void)?
    var isDone: ((IndexPath) -> Bool)?
    
    override static var backgroundColor: UIColor {
        return .clear
    }
    
    lazy var doneAction: SwipeAction = {
        let doneAction = SwipeAction(style: .default,
                                     title: "",
                                     handler:
        { [weak self] (action, indexPath) in
            self?.onDone?(indexPath)
            action.fulfill(with: .delete)
        })
        doneAction.textColor = AppTheme.current.scheme.greenColor
        doneAction.title = nil
        doneAction.backgroundColor = type(of: self).backgroundColor
        doneAction.transitionDelegate = nil
        return doneAction
    }()
    
    override func configureLeftSwipeAction(at indexPath: IndexPath) {
        doneAction.image = isDone?(indexPath) == true ? #imageLiteral(resourceName: "repeat") : #imageLiteral(resourceName: "checkmark")
    }
    
    override var leftSwipeActions: [SwipeAction] {
        return [doneAction]
    }
    
    override static var expansionStyle: SwipeExpansionStyle? {
        return SwipeExpansionStyle.selection
    }

}
