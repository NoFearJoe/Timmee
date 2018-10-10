//
//  ExtendedChartViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 07/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Charts

class ExtendedChartViewController: BaseViewController, SprintInteractorTrait, TargetsAndHabitsInteractorTrait {
    
    @IBOutlet private(set) var chartView: BarChartView!
    
    let sprintsService = ServicesAssembly.shared.listsService
    let tasksService = ServicesAssembly.shared.tasksService
    private let waterControlService = ServicesAssembly.shared.waterControlService
    
    override func prepare() {
        super.prepare()
        setupChart()
    }
    
}

// MARK: - Chart update

private extension ExtendedChartViewController {
    
    func refreshWaterControlProgress() {
        guard let currentSprint = getCurrentSprint() else { return }
        guard let waterControl = waterControlService.fetchWaterControl() else { return }
        
        var chartEntries: [BarChartDataEntry] = []
        var xAxisTitles: [String] = []
        let daysFromSprintStart = currentSprint.creationDate.days(before: Date.now)
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
            let drunkVolume = Double((waterControl.drunkVolume[date] ?? 0)) / 1000
            chartEntries.append(BarChartDataEntry(x: Double(daysFromSprintStart - i), y: drunkVolume))
            xAxisTitles.append(date.asShortWeekday)
        }
        let dataSet = BarChartDataSet(values: chartEntries, label: nil)
        dataSet.label = nil
        dataSet.colors = [AppTheme.current.colors.mainElementColor]
        dataSet.valueColors = [AppTheme.current.colors.mainElementColor]
        dataSet.drawValuesEnabled = false
        
        let limitLine = ChartLimitLine(limit: Double(waterControl.neededVolume / 1000))
        limitLine.lineColor = AppTheme.current.colors.inactiveElementColor
        limitLine.lineDashLengths = [4, 4]
        limitLine.lineWidth = 1
        chartView.leftAxis.addLimitLine(limitLine)
        
        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (i, _) -> String in
            xAxisTitles.item(at: Int(i)) ?? ""
        })
        
        chartView.leftAxis.axisMaximum = Double((waterControl.neededVolume / 1000) + 1)
        
        chartView.data = BarChartData(dataSet: dataSet)
        chartView.notifyDataSetChanged()
    }
    
}

private extension ExtendedChartViewController {
    
    func setupChart() {
        chartView.dragXEnabled = true
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawMarkers = false
        chartView.noDataFont = AppTheme.current.fonts.medium(14)
        chartView.noDataText = "no_data".localized // TODO: Localize
        chartView.noDataTextColor = AppTheme.current.colors.inactiveElementColor
        chartView.noDataTextAlignment = .center
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
