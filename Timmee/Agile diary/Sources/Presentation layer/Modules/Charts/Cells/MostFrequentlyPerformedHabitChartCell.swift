//
//  MostFrequentlyPerformedHabitChartCell.swift
//  Agile diary
//
//  Created by i.kharabet on 22.10.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

final class MostFrequentlyPerformedHabitChartCell: BaseChartCell {
    
    private let habitsService = ServicesAssembly.shared.habitsService
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "most_frequently_performed_habit".localized
            titleLabel.textColor = AppTheme.current.colors.activeElementColor
        }
    }
    
    @IBOutlet private var habitTitleLabel: UILabel! {
        didSet {
            habitTitleLabel.font = AppTheme.current.fonts.medium(20)
            habitTitleLabel.textColor = AppTheme.current.colors.activeElementColor
        }
    }
    
    @IBOutlet private var habitPerformingFrequencyLabel: UILabel! {
        didSet {
            habitPerformingFrequencyLabel.font = AppTheme.current.fonts.bold(20)
            habitPerformingFrequencyLabel.textColor = AppTheme.current.colors.mainElementColor
        }
    }
    
}
