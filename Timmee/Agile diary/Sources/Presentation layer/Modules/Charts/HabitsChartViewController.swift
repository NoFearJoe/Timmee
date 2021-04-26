//
//  HabitsChartViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 09/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Charts

final class HabitsChartViewController: BaseViewController {
    
    var sprint: Sprint?
    
    private let stack = StackViewController()
    private let totalProgressView = HabitsChartTotalProgressView()
    
    private let chartTitleContainer = UIView()
    private let chartTitleLabel = UILabel()
    private let chartPlaceholderLabel = UILabel()
    private let chartContainer = UIScrollView()
    private let chartView = ExtendedBarChartView()
    
    private let detailedHabitsTableView = AutoSizingTableView(frame: .zero, style: .plain)
    
    private let habitsService = ServicesAssembly.shared.habitsService
    
    private var habitsProgress: [(Habit, Progress)] = []
    
    override func prepare() {
        super.prepare()
        
        title = "my_progress".localized
        
        setupViews()
        
        chartTitleLabel.text = "habits_chart_chart_title".localized
        chartPlaceholderLabel.text = "habits_chart_placeholder_text".localized
    }
    
    override func refresh() {
        super.refresh()
        
        guard let sprint = sprint else { return }
        
        refreshHabitsProgress(sprint: sprint)
        refreshHabitsDetailsTableView(sprint: sprint)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        chartTitleLabel.font = AppTheme.current.fonts.regular(15)
        chartTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        chartTitleLabel.numberOfLines = 0
        chartPlaceholderLabel.font = AppTheme.current.fonts.regular(14)
        chartPlaceholderLabel.textColor = AppTheme.current.colors.inactiveElementColor
        chartView.backgroundColor = AppTheme.current.colors.middlegroundColor
        chartView.underlyingBarColor = AppTheme.current.colors.decorationElementColor
        detailedHabitsTableView.backgroundColor = .clear
        detailedHabitsTableView.separatorColor = AppTheme.current.colors.decorationElementColor
    }
    
    @objc private func onCloseScreen() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension HabitsChartViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitsProgress.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitProgressCell", for: indexPath) as! HabitProgressCell
        let habitAndProgress = habitsProgress[indexPath.row]
        cell.configure(habit: habitAndProgress.0, progress: habitAndProgress.1)
        cell.setupAppearance()
        return cell
    }
    
}

extension HabitsChartViewController: UITableViewDelegate {}

private extension HabitsChartViewController {
    
    func refreshHabitsProgress(sprint: Sprint) {
        let habits = habitsService.fetchHabits(sprintID: sprint.id)

        let startDate: Date = sprint.endDate.isGreater(than: Date.now) ? Date.now : sprint.endDate
        let daysFromSprintStart = sprint.startDate.days(before: startDate)
        var entries: [ExtendedBarChartEntry] = []
        var totalHabitsCount = 0
        var totalCompletedHabitsCount = 0
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (startDate - i.asDays).startOfDay
            let repeatDay = DayUnit(weekday: date.weekday)
            let allHabits = habits.filter { $0.creationDate.startOfDay <= date && $0.dueDays.contains(repeatDay) }
            let completedHabits = allHabits.filter { $0.isDone(at: date) }.count

            let color: UIColor
            if completedHabits >= allHabits.count {
                color = AppTheme.current.colors.selectedElementColor
            } else {
                color = AppTheme.current.colors.incompleteElementColor
            }
            
            totalHabitsCount += allHabits.count
            totalCompletedHabitsCount += completedHabits
            
            entries.append(
                ExtendedBarChartEntry(
                    index: daysFromSprintStart - i,
                    value: Double(completedHabits),
                    targetValue: Double(allHabits.count),
                    title: date.asShortDayMonth,
                    color: color
                )
            )
        }
        
        chartView.entries = entries
        
        chartPlaceholderLabel.isHidden = !entries.isEmpty
        
        let totalProgress = (Double(totalCompletedHabitsCount) / Double(totalHabitsCount)) * 100
        totalProgressView.configure(percent: totalProgress.rounded(precision: 2))
    }
    
    func refreshHabitsDetailsTableView(sprint: Sprint) {
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
        
        habitsProgress = progressForHabit
            .map { ($0, $1) }
            .sorted {
                $0.1.percent == $1.1.percent ?
                    $0.0 > $1.0 :
                    $0.1.percent > $1.1.percent
            }
        
        detailedHabitsTableView.reloadData()
    }
    
}

private extension HabitsChartViewController {
    
    func setupViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cross"), style: .plain, target: self, action: #selector(onCloseScreen))
        
        addChild(stack)
        view.addSubview(stack.view)
        stack.view.allEdges().toSuperview()
        stack.didMove(toParent: self)
        
        let spacer = UIView()
        spacer.height(15)
        
        stack.setChild(totalProgressView, at: 0)
        stack.setChild(chartTitleContainer, at: 1)
        stack.setChild(chartContainer, at: 2)
        stack.setChild(spacer, at: 3)
        stack.setChild(detailedHabitsTableView, at: 4)
        
        totalProgressView.height(80)
        chartContainer.height(256)
        
        chartTitleContainer.addSubview(chartTitleLabel)
        [chartTitleLabel.leading(15), chartTitleLabel.trailing(15), chartTitleLabel.top(), chartTitleLabel.bottom()].toSuperview()
        
        chartContainer.addSubview(chartView)
        chartContainer.showsVerticalScrollIndicator = false
        chartContainer.showsHorizontalScrollIndicator = false
        chartView.allEdges().toSuperview()
        chartView.centerY().toSuperview()
        
        chartContainer.addSubview(chartPlaceholderLabel)
        chartPlaceholderLabel.allEdges(20).toSuperview()
        chartPlaceholderLabel.textAlignment = .center
        
        detailedHabitsTableView.delegate = self
        detailedHabitsTableView.dataSource = self
        detailedHabitsTableView.showsVerticalScrollIndicator = false
        detailedHabitsTableView.showsHorizontalScrollIndicator = false
        detailedHabitsTableView.allowsSelection = false
        detailedHabitsTableView.contentInset.bottom = 15
        detailedHabitsTableView.backgroundColor = .clear
        detailedHabitsTableView.register(HabitProgressCell.self, forCellReuseIdentifier: "HabitProgressCell")
        
        detailedHabitsTableView.tableHeaderView = HabitProgressHeaderView()
    }
    
}
