//
//  ExtendedHabitsChartViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 09/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Charts

fileprivate typealias Progress = (done: Int, total: Int, percent: Double)

final class ExtendedHabitsChartViewController: BaseViewController, AnyExtendedChart {
    
    var sprint: Sprint?
    
    @IBOutlet private var chartPlaceholderLabel: UILabel!
    @IBOutlet private var chart: HabitsChartView!
    @IBOutlet private var detailedHabitsTableView: UITableView!
    
    private let habitsService = ServicesAssembly.shared.habitsService
    
    private var habitsProgress: [Habit: Progress] = [:]
    
    override func prepare() {
        super.prepare()
        title = "habits".localized
        chartPlaceholderLabel.text = "habits_chart_placeholder_text".localized
        detailedHabitsTableView.contentInset.bottom = 15
        detailedHabitsTableView.register(UINib(nibName: "HabitProgressHeaderView", bundle: nil),
                                         forHeaderFooterViewReuseIdentifier: "HabitProgressHeaderView")
    }
    
    override func refresh() {
        super.refresh()
        guard let sprint = sprint else { return }
        refreshHabitsProgress(sprint: sprint)
        refreshHabitsDetailsTableView(sprint: sprint)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        chartPlaceholderLabel.font = AppTheme.current.fonts.regular(14)
        chartPlaceholderLabel.textColor = AppTheme.current.colors.inactiveElementColor
        chart.backgroundColor = AppTheme.current.colors.middlegroundColor
        chart.underlyingBarColor = AppTheme.current.colors.decorationElementColor
        detailedHabitsTableView.backgroundColor = .clear
        detailedHabitsTableView.separatorColor = AppTheme.current.colors.decorationElementColor
    }
    
}

extension ExtendedHabitsChartViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitsProgress.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitProgressCell", for: indexPath) as! HabitProgressCell
        let habit = Array(habitsProgress.keys)[indexPath.row]
        if let progress = habitsProgress[habit] {
            cell.configure(habit: habit, progress: progress)
        }
        cell.setupAppearance()
        return cell
    }
    
}

extension ExtendedHabitsChartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HabitProgressHeaderView") as! HabitProgressHeaderView
        view.configure(title: "Progress_till_today".localized)
        view.setupAppearance()
        return view
    }
    
}

private extension ExtendedHabitsChartViewController {
    
    func refreshHabitsProgress(sprint: Sprint) {
        let habits = habitsService.fetchHabits(sprintID: sprint.id)

        let daysFromSprintStart = sprint.startDate.days(before: Date.now)
        var entries: [HabitsChartEntry] = []
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
            let repeatDay = DayUnit(weekday: date.weekday)
            let allHabits = habits.filter { $0.creationDate.startOfDay <= date && $0.dueDays.contains(repeatDay) }
            let completedHabits = allHabits.filter { $0.doneDates.contains(where: { $0.isWithinSameDay(of: date) }) }.count

            let color: UIColor
            if completedHabits >= allHabits.count {
                color = AppTheme.current.colors.selectedElementColor
            } else {
                color = AppTheme.current.colors.incompleteElementColor
            }
            
            entries.append(HabitsChartEntry(index: daysFromSprintStart - i, doneHabitsCount: completedHabits, totalHabitsCount: allHabits.count, title: date.asShortWeekday, color: color))
        }
        
        chart.entries = entries
        
        chartPlaceholderLabel.isHidden = !entries.isEmpty
    }
    
    func refreshHabitsDetailsTableView(sprint: Sprint) {
        let habits = habitsService.fetchHabits(sprintID: sprint.id)
        
        var progressForHabit: [Habit: Progress] = [:]
        
        habits.forEach {
            progressForHabit[$0] = (0, 0, 0)
        }
        
        let daysFromSprintStart = sprint.startDate.days(before: Date.now)
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
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
        
        habitsProgress = progressForHabit
        detailedHabitsTableView.reloadData()
    }
    
}

final class HabitProgressHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet private var titleLabel: UILabel!
    
    fileprivate func configure(title: String) {
        titleLabel.text = title
    }
    
    func setupAppearance() {
        backgroundColor = AppTheme.current.colors.foregroundColor
        titleLabel.font = AppTheme.current.fonts.regular(15)
        titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
}

final class HabitProgressCell: UITableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var absoluteProgressLabel: UILabel!
    @IBOutlet private var relativeProgressLabel: UILabel!
    
    fileprivate func configure(habit: Habit, progress: Progress) {
        titleLabel.text = habit.title
        absoluteProgressLabel.text = "\(progress.done) \("of".localized) \(progress.total)"
        relativeProgressLabel.text = "\(Int(progress.percent * 100))%"
    }
    
    func setupAppearance() {
        backgroundColor = AppTheme.current.colors.foregroundColor
        titleLabel.font = AppTheme.current.fonts.regular(18)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        absoluteProgressLabel.font = AppTheme.current.fonts.medium(16)
        absoluteProgressLabel.textColor = AppTheme.current.colors.mainElementColor
        relativeProgressLabel.font = AppTheme.current.fonts.regular(16)
        relativeProgressLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
}
