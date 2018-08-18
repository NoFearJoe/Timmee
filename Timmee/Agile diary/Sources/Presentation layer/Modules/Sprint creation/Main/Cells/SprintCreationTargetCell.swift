//
//  SprintCreationTargetCell.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class SprintCreationTargetCell: SwipeTableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    
    func configure(target: Target) {
        titleLabel.text = target.title
    }
    
}
