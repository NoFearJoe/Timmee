//
//  UITableView+hideSwipeCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 14.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UITableView
import class SwipeCellKit.SwipeTableViewCell

public extension UITableView {

    public var swipeCells: [SwipeTableViewCell] {
        return visibleCells.compactMap({ $0 as? SwipeTableViewCell })
    }
    
    public func hideSwipeCell(animated: Bool = true) {
        swipeCells.forEach { $0.hideSwipe(animated: animated) }
    }

}
