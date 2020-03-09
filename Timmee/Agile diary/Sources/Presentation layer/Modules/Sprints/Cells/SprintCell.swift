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
    
    var onTapToAlert: ((UIButton) -> Void)?
    var onTapToCharts: (() -> Void)?
    
    private let habitsService = ServicesAssembly.shared.habitsService
    private let goalsService = ServicesAssembly.shared.goalsService
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var tenseLabel: UILabel!
    
    @IBOutlet private var habitsCountLabel: UILabel!
    @IBOutlet private var habitsProgressLabel: UILabel!
    @IBOutlet private var goalsCountLabel: UILabel!
    @IBOutlet private var goalsProgressLabel: UILabel!
    
    @IBOutlet private var alertButton: UIButton!
    @IBOutlet private var chartsButton: UIButton!
    
    @IBOutlet private var separatorViews: [UIView]!
    
    @IBAction private func onTapToAlertButton() {
        onTapToAlert?(alertButton)
    }
    
    @IBAction private func onTapToChartsButton() {
        onTapToCharts?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    func configure(sprint: Sprint) {
        titleLabel.text = sprint.title
        
        switch sprint.tense {
        case .past:
            subtitleLabel.text = sprint.startDate.asString(format: "dd.MM.yyyy") + " - " + sprint.endDate.asString(format: "dd.MM.yyyy")
            
            let habits = habitsService.fetchHabits(sprintID: sprint.id)
            let habitsProgress = habits.reduce(0, { $0 + Double($1.doneDates.count).safeDivide(by: Double($1.dueDays.count * sprint.duration)) }).safeDivide(by: Double(habits.count))
            habitsProgressLabel.text = "\(Int(habitsProgress * 100))%"
            habitsProgressLabel.textColor = progressLabelColor(progress: habitsProgress)
            
            let goals = goalsService.fetchGoals(sprintID: sprint.id)
            let goalsProgress = Double(goals.filter { $0.isDone }.count).safeDivide(by: Double(goals.count))
            goalsProgressLabel.text = "\(Int(goalsProgress * 100))%"
            goalsProgressLabel.textColor = progressLabelColor(progress: goalsProgress)
            
            configureAppearanceForPastStatus()
        case .current:
            subtitleLabel.text = "remains_n_days".localized(with: Date.now.days(before: sprint.endDate))
            
            configureAppearanceForCurrentStatus()
        case .future:
            subtitleLabel.text = "starts".localized + " " + sprint.startDate.asNearestShortDateString.lowercased()
            
            configureAppearanceForFutureStatus()
        }
        
        tenseLabel.text = sprint.tense == .current ? sprint.tense.localized : nil
        habitsCountLabel.text = "n_habits".localized(with: sprint.habitsCount)
        goalsCountLabel.text = "n_goals".localized(with: sprint.goalsCount)
        
        alertButton.isHidden = sprint.isReady
        chartsButton.isHidden = sprint.tense == .future        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tenseLabel.text = nil
        habitsProgressLabel.isHidden = true
        goalsProgressLabel.isHidden = true
    }
    
    private func setupAppearance() {
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = AppTheme.current.colors.foregroundColor
        
        titleLabel.font = AppTheme.current.fonts.medium(26)
        subtitleLabel.font = AppTheme.current.fonts.regular(14)
        tenseLabel.font = AppTheme.current.fonts.medium(14)
        habitsCountLabel.font = AppTheme.current.fonts.regular(16)
        habitsProgressLabel.font = AppTheme.current.fonts.bold(40)
        habitsProgressLabel.textColor = AppTheme.current.colors.selectedElementColor
        goalsCountLabel.font = AppTheme.current.fonts.regular(16)
        goalsProgressLabel.font = AppTheme.current.fonts.bold(40)
        goalsProgressLabel.textColor = AppTheme.current.colors.selectedElementColor
        alertButton.tintColor = AppTheme.current.colors.incompleteElementColor
    }
    
    private func progressLabelColor(progress: Double) -> UIColor {
        switch progress {
        case ...0.33: return AppTheme.current.colors.wrongElementColor
        case 0.33...0.66: return AppTheme.current.colors.incompleteElementColor
        default: return AppTheme.current.colors.selectedElementColor
        }
    }
    
    private func configureAppearanceForFutureStatus() {
        contentView.backgroundColor = AppTheme.current.colors.foregroundColor
        [titleLabel, subtitleLabel, tenseLabel].forEach {
            $0?.alpha = 1
        }
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        [subtitleLabel, habitsCountLabel, goalsCountLabel].forEach {
            $0?.textColor = AppTheme.current.colors.inactiveElementColor
        }
        
        chartsButton.tintColor = AppTheme.current.colors.mainElementColor
        
        separatorViews.forEach { $0.backgroundColor = AppTheme.current.colors.decorationElementColor }
        
        habitsProgressLabel.isHidden = true
        goalsProgressLabel.isHidden = true
        
        contentView.layer.shadowRadius = 0
    }
    
    private func configureAppearanceForCurrentStatus() {
        contentView.backgroundColor = AppTheme.current.colors.mainElementColor
        [titleLabel, subtitleLabel, tenseLabel].forEach {
            $0?.alpha = 1
        }
        titleLabel.textColor = AppTheme.dark.colors.activeElementColor
        [subtitleLabel, habitsCountLabel, goalsCountLabel].forEach {
            $0?.textColor = AppTheme.dark.colors.activeElementColor
        }
        
        chartsButton.tintColor = AppTheme.dark.colors.activeElementColor
        
        tenseLabel.textColor = AppTheme.dark.colors.incompleteElementColor
        
        separatorViews.forEach { $0.backgroundColor = AppTheme.current.colors.middlegroundColor.withAlphaComponent(0.5) }
        
        habitsProgressLabel.isHidden = true
        goalsProgressLabel.isHidden = true
        
        contentView.configureShadow(radius: 8, opacity: 0.1)
    }
    
    private func configureAppearanceForPastStatus() {
        contentView.backgroundColor = AppTheme.current.colors.foregroundColor
        [titleLabel, subtitleLabel, tenseLabel].forEach {
            $0?.alpha = 0.5
        }
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        [subtitleLabel, habitsCountLabel, goalsCountLabel].forEach {
            $0?.textColor = AppTheme.current.colors.inactiveElementColor
        }
        
        chartsButton.tintColor = AppTheme.current.colors.mainElementColor
        
        separatorViews.forEach { $0.backgroundColor = AppTheme.current.colors.decorationElementColor }
        
        habitsProgressLabel.isHidden = false
        goalsProgressLabel.isHidden = false
        
        contentView.layer.shadowRadius = 0
    }
    
}
