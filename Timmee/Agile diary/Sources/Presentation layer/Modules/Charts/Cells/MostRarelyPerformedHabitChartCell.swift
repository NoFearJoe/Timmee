//
//  MostRarelyPerformedHabitChartCell.swift
//  Agile diary
//
//  Created by i.kharabet on 22.10.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

fileprivate typealias Progress = (done: Int, total: Int, percent: Double)

final class MostRarelyPerformedHabitChartCell: BaseChartCell {
    
    let habitsService = ServicesAssembly.shared.habitsService
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "most_rarely_performed_habit".localized
            titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        }
    }
    
    @IBOutlet private var habitTitleLabel: UILabel! {
        didSet {
            habitTitleLabel.font = AppTheme.current.fonts.medium(18)
            habitTitleLabel.textColor = AppTheme.current.colors.activeElementColor
        }
    }
    
    @IBOutlet private var habitPerformingFrequencyLabel: UILabel! {
        didSet {
            habitPerformingFrequencyLabel.font = AppTheme.current.fonts.bold(20)
            habitPerformingFrequencyLabel.textColor = AppTheme.current.colors.wrongElementColor
        }
    }
    
    override func update(sprint: Sprint) {
        let habits = habitsService.fetchHabits(sprintID: sprint.id)
        
        var progressForHabit: [Habit: Progress] = [:]
        
        habits.forEach {
            progressForHabit[$0] = (0, 0, 0)
        }
        
        let startDate: Date = sprint.endDate.isGreater(than: Date.now) ? Date.now : sprint.endDate
        let daysFromSprintStart = sprint.startDate.days(before: startDate)
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (startDate - i.asDays).startOfDay
            let repeatDay = DayUnit(weekday: date.weekday)
            let allHabits = habits.filter { $0.creationDate.startOfDay <= date && $0.dueDays.contains(repeatDay) }
            let completedHabits = allHabits.filter { $0.doneDates.contains(where: { $0.isWithinSameDay(of: date) }) }
            
            allHabits.forEach {
                let progress = completedHabits.contains($0) ? 1 : 0
                if progressForHabit[$0] == nil {
                    progressForHabit[$0] = (progress, 1, Double(progress) / Double(1))
                } else {
                    let progress = progressForHabit[$0]!.done + progress
                    let allHabits = progressForHabit[$0]!.total + 1
                    progressForHabit[$0]! = (progress, allHabits, Double(progress) / Double(allHabits))
                }
            }
        }
        
        if let mostRarelyPerformedHabit = progressForHabit.min(by: { $0.value.percent < $1.value.percent }), mostRarelyPerformedHabit.value.percent < 1 {
            habitTitleLabel.text = mostRarelyPerformedHabit.key.title
            habitPerformingFrequencyLabel.text = "\(Int(mostRarelyPerformedHabit.value.percent * 100))%"
        } else {
            habitTitleLabel.text = "no".localized
            habitPerformingFrequencyLabel.text = nil
        }
    }
    
    override static func size(for collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width - 30, height: 72)
    }
    
}
