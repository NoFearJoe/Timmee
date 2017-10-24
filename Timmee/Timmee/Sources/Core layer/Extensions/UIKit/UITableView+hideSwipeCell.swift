//
//  UITableView+hideSwipeCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 14.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UITableView
import SwipeCellKit

extension UITableView {

    var swipeCells: [SwipeTableViewCell] {
        return visibleCells.flatMap({ $0 as? SwipeTableViewCell })
    }
    
    func hideSwipeCell(animated: Bool = true) {
        swipeCells.forEach { $0.hideSwipe(animated: animated) }
    }

}
