//
//  TodayGoalCell.swift
//  Agile diary
//
//  Created by i.kharabet on 11.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import TasksKit
import SwipeCellKit
import UIComponents

final class TodayGoalCell: SwipeTableViewCell {
    
    static let identifier = "TodayGoalCell"
    
    var onChangeHabitCheckedState: ((Bool, Habit) -> Void)?
    var onChangeStageCheckedState: ((Bool, Stage) -> Void)?
    
    private let containerView = UIView()
    private let contentStackView = UIStackView()
    
    private let statusLabel = UILabel()
    
    private let titleLabel = UILabel()
    
    private let habitsTitleLabel = UILabel()
    private let habitsContainer = UIStackView()
    
    private let stagesTitleLabel = UILabel()
    private let stagesContainer = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(goal: Goal, currentDate: Date) {
        setupAppearance()
                
        containerView.alpha = goal.isDone ? AppTheme.current.style.alpha.inactive : AppTheme.current.style.alpha.enabled
                
        statusLabel.text = goal.isDone ? "completed".localized : nil
        statusLabel.isHidden = !goal.isDone
        
        titleLabel.text = goal.title
        
        let habitsForCurrentDate = goal.habits.filter {
            $0.dueDays.contains(DayUnit(weekday: currentDate.weekday)) && $0.creationDate.startOfDay() <= currentDate
        }.sorted {
            let lhsIsDone = $0.isDone(at: currentDate)
            let rhsIsDone = $1.isDone(at: currentDate)
            
            if lhsIsDone == rhsIsDone {
                return $0 < $1
            } else {
                return !lhsIsDone && rhsIsDone
            }
        }
        
        habitsTitleLabel.isHidden = habitsForCurrentDate.isEmpty
        habitsContainer.isHidden = habitsForCurrentDate.isEmpty
        
        addHabitViews(habits: habitsForCurrentDate, currentDate: currentDate)
        
        stagesTitleLabel.isHidden = goal.stages.isEmpty
        stagesContainer.isHidden = goal.stages.isEmpty
        
        addStageViews(goal: goal)
    }
    
    private func addStageViews(goal: Goal) {
        stagesContainer.subviews.forEach { $0.removeFromSuperview() }
        
        let stages = goal.stages.sorted(by: { $0.sortPosition < $1.sortPosition }).prefix(5)
        for (index, stage) in stages.enumerated() {
            let stageView = StageView.loadedFromNib()
            stageView.title = stage.title
            stageView.isChecked = stage.isDone
            stageView.setupAppearance()
            stageView.onChangeCheckedState = { [unowned self] isChecked in
                self.onChangeStageCheckedState?(isChecked, stage)
            }
            stagesContainer.addSubview(stageView)
            if stages.count == 1 {
                stageView.allEdges().toSuperview()
            } else if index == 0 {
                [stageView.top(), stageView.leading(), stageView.trailing()].toSuperview()
            } else if index >= stages.count - 1 {
                [stageView.leading(), stageView.trailing(), stageView.bottom()].toSuperview()
                let previousView = stagesContainer.subviews[index - 1]
                stageView.topToBottom().to(previousView, addTo: stagesContainer)
            } else {
                [stageView.leading(), stageView.trailing()].toSuperview()
                let previousView = stagesContainer.subviews[index - 1]
                stageView.topToBottom().to(previousView, addTo: stagesContainer)
            }
        }
    }
    
    private func addHabitViews(habits: [Habit], currentDate: Date) {
        habitsContainer.arrangedSubviews.forEach {
            habitsContainer.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        habits.prefix(5).forEach { habit in
            let stageView = StageView.loadedFromNib()
            
            stageView.title = habit.title
            stageView.isChecked = habit.isDone(at: currentDate)
            
            stageView.setupAppearance()
            
            stageView.onChangeCheckedState = { [unowned self] isChecked in
                self.onChangeHabitCheckedState?(isChecked, habit)
            }
                        
            habitsContainer.addArrangedSubview(stageView)
        }
    }
    
    private func setupAppearance() {
        containerView.backgroundColor = AppTheme.current.colors.foregroundColor
        statusLabel.textColor = AppTheme.current.colors.mainElementColor
        statusLabel.font = AppTheme.current.fonts.medium(13)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.medium(18)
        habitsTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        habitsTitleLabel.font = AppTheme.current.fonts.regular(14)
        stagesTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        stagesTitleLabel.font = AppTheme.current.fonts.regular(14)
    }
    
}

private extension TodayGoalCell {
    
    func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(statusLabel)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(habitsTitleLabel)
        contentStackView.addArrangedSubview(habitsContainer)
        contentStackView.addArrangedSubview(stagesTitleLabel)
        contentStackView.addArrangedSubview(stagesContainer)
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        if #available(iOS 11.0, *) {
            contentStackView.setCustomSpacing(6, after: statusLabel)
        }
        
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.layer.cornerRadius = 8
        containerView.configureShadow(radius: 4, opacity: 0.05)
        
        titleLabel.font = AppTheme.current.fonts.medium(18)
        
        habitsTitleLabel.text = "habits".localized
        
        habitsContainer.axis = .vertical
        habitsContainer.spacing = 2
        
        stagesTitleLabel.text = "stages".localized
    }
    
    func setupLayout() {
        [containerView.leading(15), containerView.trailing(15), containerView.top(6), containerView.bottom(6)].toSuperview()
        [contentStackView.leading(8), contentStackView.trailing(8), contentStackView.top(12), contentStackView.bottom(12)].toSuperview()
    }
    
}
