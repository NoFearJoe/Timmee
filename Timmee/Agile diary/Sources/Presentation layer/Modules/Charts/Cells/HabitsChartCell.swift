//
//  HabitsChartCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 23.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Charts

final class HabitsChartCell: BaseChartCell, SprintInteractorTrait, TargetsAndHabitsInteractorTrait {
    
    let sprintsService = ServicesAssembly.shared.listsService
    let tasksService = ServicesAssembly.shared.tasksService
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "habits".localized
            titleLabel.textColor = AppTheme.current.colors.activeElementColor
        }
    }
    @IBOutlet private var chartView: BarChartView! {
        didSet { setupChartView() }
    }
    
    override func update() {
        guard let currentSprint = getCurrentSprint() else { return } // TODO: Handle
        let habits = getTasks(listID: currentSprint.id).filter { $0.kind == "habit" }
        
        var chartEntries: [BarChartDataEntry] = []
        var xAxisTitles: [String] = []
        for i in stride(from: 6, through: 0, by: -1) {
            let date = (Date() - i.asDays).startOfDay
            let completedHabits = habits.filter { $0.doneDates.contains(where: { $0.isWithinSameDay(of: date) }) }.count
            chartEntries.append(BarChartDataEntry(x: Double(6 - i), y: Double(completedHabits)))
            xAxisTitles.append(date.asShortWeekday)
        }
        let dataSet = BarChartDataSet(values: chartEntries, label: nil)
        dataSet.label = nil
        dataSet.colors = [AppTheme.current.colors.mainElementColor]
        dataSet.valueColors = [AppTheme.current.colors.mainElementColor]
        dataSet.drawValuesEnabled = false
        
        let limitLine = ChartLimitLine(limit: Double(habits.count))
        limitLine.lineColor = AppTheme.current.colors.inactiveElementColor
        limitLine.lineDashLengths = [4, 4]
        limitLine.lineWidth = 1
        chartView.leftAxis.addLimitLine(limitLine)
        
        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (i, _) -> String in
            xAxisTitles[Int(i)]
        })
        
        chartView.leftAxis.axisMaximum = Double(habits.count + 1)
        
        chartView.data = BarChartData(dataSet: dataSet)
        chartView.notifyDataSetChanged()
    }
    
    override static func size(for collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width - 30, height: 256)
    }
    
    private func setupChartView() {
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawMarkers = false
        chartView.noDataFont = AppTheme.current.fonts.medium(14)
        chartView.noDataText = "habits_chart_no_data".localized
        chartView.noDataTextColor = AppTheme.current.colors.inactiveElementColor
        chartView.chartDescription = nil
        
        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.granularity = 1
        leftAxis.labelTextColor = AppTheme.current.colors.inactiveElementColor
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.zeroLineColor = AppTheme.current.colors.inactiveElementColor
        leftAxis.labelPosition = .outsideChart
        let xAxis = chartView.xAxis
        xAxis.labelTextColor = AppTheme.current.colors.inactiveElementColor
        xAxis.drawGridLinesEnabled = false
        xAxis.labelPosition = .bottom
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        chartView.setScaleEnabled(false)
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
    }
    
}
