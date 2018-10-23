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

final class MostRarelyPerformedHabitChartCell: BaseChartCell, SprintInteractorTrait {
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    let habitsService = ServicesAssembly.shared.habitsService
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "most_rarely_performed_habit".localized
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
            habitPerformingFrequencyLabel.textColor = AppTheme.current.colors.wrongElementColor
        }
    }
    
    override func update() {
        guard let currentSprint = getCurrentSprint() else { return }
        let habits = habitsService.fetchHabits(sprintID: currentSprint.id)
        
        var progressForHabit: [Habit: Progress] = [:]
        
        habits.forEach {
            progressForHabit[$0] = (0, 0, 0)
        }
        
        let daysFromSprintStart = currentSprint.startDate.days(before: Date.now)
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
            let repeatDay = DayUnit(number: date.weekday - 1)
            let allHabits = habits.filter { $0.dueDays.contains(repeatDay) }
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
        
        guard let mostRarelyPerformedHabit = progressForHabit.min(by: { $0.value.percent > $1.value.percent }) else { return } // TODO: Handle
        habitTitleLabel.text = mostRarelyPerformedHabit.key.title
        habitPerformingFrequencyLabel.text = "\(Int(mostRarelyPerformedHabit.value.percent * 100))%"
    }
    
    override static func size(for collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width - 30, height: 72)
    }
    
}
