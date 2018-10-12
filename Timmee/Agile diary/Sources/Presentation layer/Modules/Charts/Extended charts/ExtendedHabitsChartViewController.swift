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

final class ExtendedHabitsChartViewController: ExtendedChartViewController {
    
    @IBOutlet private var detailedHabitsTableView: UITableView!
    
    private var habitsProgress: [Habit: Progress] = [:]
    
    override func prepare() {
        super.prepare()
        detailedHabitsTableView.contentInset.bottom = 15
    }
    
    override func refresh() {
        super.refresh()
        refreshHabitsProgress()
        refreshHabitsDetailsTableView()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
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
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

private extension ExtendedHabitsChartViewController {
    
    func refreshHabitsProgress() {
        guard let currentSprint = getCurrentSprint() else { return }
        let habits = getTasks(listID: currentSprint.id).filter { $0.kind == "habit" }
        
        var chartEntries: [BarChartDataEntry] = []
        var xAxisTitles: [String] = []
        var valueColors: [NSUIColor] = []
        let daysFromSprintStart = currentSprint.creationDate.days(before: Date.now)
        var yValuesByWeek: [Double] = []
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
            let repeatDay = DayUnit(number: date.weekday - 1).string
            let allHabits = habits.filter { $0.repeating.string.contains(repeatDay) }
            let completedHabits = allHabits.filter { $0.doneDates.contains(where: { $0.isWithinSameDay(of: date) }) }.count + Int.random(in: 0...2) // FIXME:
//            chartEntries.append(BarChartDataEntry(x: Double(daysFromSprintStart - i), y: Double(completedHabits)))
            if yValuesByWeek.isEmpty {
                yValuesByWeek = Array.init(repeating: 0, count: date.weekday)
            } else if date.weekday == 1 {
                if yValuesByWeek.count < 7 {
                    yValuesByWeek += Array.init(repeating: 0, count: 7 - yValuesByWeek.count)
                }
                chartEntries.append(BarChartDataEntry(x: Double(daysFromSprintStart - i), yValues: yValuesByWeek))
                yValuesByWeek = []
            } else {
                yValuesByWeek.append(Double(completedHabits))
            }
            xAxisTitles.append(date.asShortWeekday)
            
            if completedHabits >= allHabits.count {
                valueColors.append(AppTheme.current.colors.selectedElementColor)
            } else {
                valueColors.append(AppTheme.current.colors.inactiveElementColor)
            }
        }
        let dataSet = BarChartDataSet(values: chartEntries, label: nil)
        dataSet.label = nil
        dataSet.colors = valueColors
        dataSet.valueColors = [AppTheme.current.colors.mainElementColor]
        dataSet.drawValuesEnabled = false
//        dataSet.stackSize = 7
        dataSet.stackLabels = ["1", "2", "3", "4", "5", "6", "7"]
        
//        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (i, _) -> String in
//            ""//xAxisTitles.item(at: Int(i)) ?? ""
//        })
//        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["1", "", "", "", "", "6", ""])
        
        chartView.leftAxis.axisMaximum = Double(habits.count + 1)
        
        chartView.data = BarChartData(dataSet: dataSet)
//        chartView.groupBars(fromX: 0, groupSpace: 7, barSpace: 7)
        chartView.notifyDataSetChanged()
    }
    
    func refreshHabitsDetailsTableView() {
        guard let currentSprint = getCurrentSprint() else { return }
        let habits = getTasks(listID: currentSprint.id).filter { $0.kind == "habit" }
        
        var progressForHabit: [Habit: Progress] = [:]
        
        let daysFromSprintStart = currentSprint.creationDate.days(before: Date.now)
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
            let repeatDay = DayUnit(number: date.weekday - 1).string
            let allHabits = habits.filter { $0.repeating.string.contains(repeatDay) }
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
