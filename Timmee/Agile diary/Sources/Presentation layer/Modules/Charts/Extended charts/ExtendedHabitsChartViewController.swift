//
//  ExtendedHabitsChartViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 09/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Charts

final class ExtendedHabitsChartViewController: ExtendedChartViewController {
    
    @IBOutlet private var detailedHabitsTableView: UITableView!
    
    override func refresh() {
        super.refresh()
        refreshHabitsProgress()
        refreshHabitsDetailsTableView()
    }
    
}

private extension ExtendedHabitsChartViewController {
    
    func refreshHabitsProgress() {
        guard let currentSprint = getCurrentSprint() else { return } // TODO: Handle
        let habits = getTasks(listID: currentSprint.id).filter { $0.kind == "habit" }
        
        var chartEntries: [BarChartDataEntry] = []
        var xAxisTitles: [String] = []
        var valueColors: [NSUIColor] = []
        let daysFromSprintStart = currentSprint.creationDate.days(before: Date.now)
        for i in stride(from: daysFromSprintStart + 50, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
            let completedHabits = habits.filter { $0.doneDates.contains(where: { $0.isWithinSameDay(of: date) }) }.count + Int.random(in: 0...3)
            chartEntries.append(BarChartDataEntry(x: Double(daysFromSprintStart - i), y: Double(completedHabits)))
            xAxisTitles.append(date.asShortWeekday)
            let color: NSUIColor
            if completedHabits <= Int(round(Double(habits.count) / 3)) {
                color = AppTheme.current.colors.wrongElementColor
            } else if completedHabits >= Int(ceil(Double(habits.count) * 3 / 2)) {
                color = AppTheme.current.colors.selectedElementColor
            } else {
                color = AppTheme.current.colors.inactiveElementColor
            }
            valueColors.append(color)
        }
        let dataSet = BarChartDataSet(values: chartEntries, label: nil)
        dataSet.label = nil
        dataSet.colors = valueColors
        dataSet.valueColors = [AppTheme.current.colors.mainElementColor]
        dataSet.drawValuesEnabled = false
        
        let limitLine = ChartLimitLine(limit: Double(habits.count))
        limitLine.lineColor = AppTheme.current.colors.inactiveElementColor
        limitLine.lineDashLengths = [4, 4]
        limitLine.lineWidth = 1
        chartView.leftAxis.addLimitLine(limitLine)
        
        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (i, _) -> String in
            xAxisTitles.item(at: Int(i)) ?? ""
        })
        
        chartView.leftAxis.axisMaximum = Double(habits.count + 1)
        
        chartView.data = BarChartData(dataSet: dataSet)
        chartView.notifyDataSetChanged()
    }
    
    func refreshHabitsDetailsTableView() {
        
    }
    
}
