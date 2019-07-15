//
//  TableListRepresentationCellForFinishedTask.swift
//  Timmee
//
//  Created by i.kharabet on 10.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class TableListRepresentationCellForFinishedTask: TableListRepresentationBaseCell {
    
    @IBOutlet private var finishedLabel: UILabel!
    
    override func setTask(_ task: Task) {
        super.setTask(task)
        finishedLabel.text = "regular_task_finished".localized
    }
    
    override func applyAppearance() {
        super.applyAppearance()
        finishedLabel.textColor = AppTheme.current.redColor
    }
    
}
