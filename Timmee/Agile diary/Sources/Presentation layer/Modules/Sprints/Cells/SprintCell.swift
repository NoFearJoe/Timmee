//
//  SprintCell.swift
//  Agile diary
//
//  Created by i.kharabet on 08.02.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

final class SprintCell: UICollectionViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tenseLabel: UILabel!
    // Результаты спринта (для законченного и текущего)
    @IBOutlet private var sprintResultsView: UIView!
    
    func configure(sprint: Sprint) {
        titleLabel.text = sprint.title
        tenseLabel.text = sprint.tense.localized
    }
    
}
