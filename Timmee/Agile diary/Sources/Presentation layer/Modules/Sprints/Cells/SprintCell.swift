//
//  SprintCell.swift
//  Agile diary
//
//  Created by i.kharabet on 08.02.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit
import UIComponents

final class SprintCell: SwipableCollectionViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var tenseLabel: UILabel!
    
    @IBOutlet private var habitsCountLabel: UILabel!
    @IBOutlet private var habitsProgressLabel: UILabel!
    @IBOutlet private var goalsCountLabel: UILabel!
    @IBOutlet private var goalsProgressLabel: UILabel!
    
    @IBOutlet private var separatorViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    func configure(sprint: Sprint) {
        titleLabel.text = "Sprint".localized + " #\(sprint.number)"
        switch sprint.tense {
        case .past:
            subtitleLabel.text = sprint.startDate.asString(format: "dd.MM.yyyy") + " - " + sprint.endDate.asString(format: "dd.MM.yyyy")
            habitsProgressLabel.isHidden = false
            goalsProgressLabel.isHidden = false
        case .current:
            subtitleLabel.text = "remains_n_days".localized(with: Date.now.days(before: sprint.endDate))
            habitsProgressLabel.isHidden = true
            goalsProgressLabel.isHidden = true
        case .future:
            subtitleLabel.text = "after_n_days".localized(with: Date.now.days(before: sprint.startDate))
            habitsProgressLabel.isHidden = true
            goalsProgressLabel.isHidden = true
        }
        tenseLabel.text = sprint.tense == .current ? sprint.tense.localized : nil
        habitsCountLabel.text = "n_habits".localized(with: sprint.habitsCount)
        goalsCountLabel.text = "n_goals".localized(with: sprint.goalsCount)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tenseLabel.text = nil
        habitsProgressLabel.isHidden = true
        goalsProgressLabel.isHidden = true
    }
    
    private func setupAppearance() {
        layer.cornerRadius = 12
        configureShadow(radius: 10, opacity: 0.2)
        backgroundColor = AppTheme.current.colors.foregroundColor
        separatorViews.forEach { $0.backgroundColor = AppTheme.current.colors.decorationElementColor }
        titleLabel.font = AppTheme.current.fonts.medium(26)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        subtitleLabel.font = AppTheme.current.fonts.regular(14)
        subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        tenseLabel.font = AppTheme.current.fonts.regular(14)
        tenseLabel.textColor = AppTheme.current.colors.mainElementColor
        habitsCountLabel.font = AppTheme.current.fonts.regular(16)
        habitsCountLabel.textColor = AppTheme.current.colors.inactiveElementColor
        habitsProgressLabel.font = AppTheme.current.fonts.bold(40)
        habitsProgressLabel.textColor = AppTheme.current.colors.selectedElementColor
        goalsCountLabel.font = AppTheme.current.fonts.regular(16)
        goalsCountLabel.textColor = AppTheme.current.colors.inactiveElementColor
        goalsProgressLabel.font = AppTheme.current.fonts.bold(40)
        goalsProgressLabel.textColor = AppTheme.current.colors.selectedElementColor // TODO: Цвет в зависимости от процента
    }
    
}
