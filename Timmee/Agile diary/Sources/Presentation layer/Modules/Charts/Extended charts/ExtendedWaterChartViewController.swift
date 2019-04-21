//
//  ExtendedWaterChartViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 07/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Charts

class ExtendedWaterChartViewController: BaseViewController, AnyExtendedChart {
    
    var sprint: Sprint?
    
    @IBOutlet private var chartView: BarChartView!
    @IBOutlet private var averageWaterView: AverageMoodView!
    
    private let waterControlService = ServicesAssembly.shared.waterControlService
    
    override func prepare() {
        super.prepare()
        title = "water".localized
        setupChart()
        averageWaterView.isHidden = true
    }
    
    override func refresh() {
        super.refresh()
        guard let waterControl = waterControlService.fetchWaterControl() else { return }
        refreshWaterControlProgress(waterControl: waterControl)
        refreshAverageWaterVolume(waterControl: waterControl)
    }
    
}

// MARK: - Chart update

private extension ExtendedWaterChartViewController {
    
    func refreshWaterControlProgress(waterControl: WaterControl) {
        guard let sprint = sprint else { return }
        var chartEntries: [BarChartDataEntry] = []
        var xAxisTitles: [String] = []
        let daysFromSprintStart = max(sprint.startDate.days(before: Date.now), 5)
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
            let drunkVolume = Double((waterControl.drunkVolume[date] ?? 0)) / 1000
            chartEntries.append(BarChartDataEntry(x: Double(daysFromSprintStart - i), y: drunkVolume))
            xAxisTitles.append(date.asShortWeekday)
        }
        let dataSet = BarChartDataSet(values: chartEntries, label: nil)
        dataSet.label = nil
        dataSet.colors = [AppTheme.current.colors.mainElementColor]
        dataSet.drawValuesEnabled = true
        dataSet.valueFont = AppTheme.current.fonts.medium(10)
        dataSet.valueColors = [.white]
        dataSet.valueFormatter = DefaultValueFormatter(block: { value, _, _, _ -> String in
            return value == 0 ? "" : "\(value)"
        })
        
        let limitLine = ChartLimitLine(limit: Double(waterControl.neededVolume / 1000))
        limitLine.lineColor = AppTheme.current.colors.inactiveElementColor
        limitLine.lineDashLengths = [4, 4]
        limitLine.lineWidth = 1
        chartView.leftAxis.addLimitLine(limitLine)
        
        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { i, _ -> String in
            return xAxisTitles.item(at: Int(i)) ?? ""
        })
        
        chartView.leftAxis.axisMaximum = Double((waterControl.neededVolume / 1000) + 1)
        
        chartView.data = BarChartData(dataSet: dataSet)
        chartView.notifyDataSetChanged()
    }
    
    func refreshAverageWaterVolume(waterControl: WaterControl) {
        guard let sprint = sprint else { return }
        var totalDrunkVolume: Double = 0
        var notZeroDrunkVolumeDaysCount: Int = 0
        let daysFromSprintStart = sprint.startDate.days(before: Date.now)
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
            let drunkVolume = Double((waterControl.drunkVolume[date] ?? 0)) / 1000
            guard drunkVolume != 0 else { continue }
            totalDrunkVolume += drunkVolume
            notZeroDrunkVolumeDaysCount += 1
        }
        let averageWaterVolume = totalDrunkVolume / Double(notZeroDrunkVolumeDaysCount)
        averageWaterView.configure(waterVolume: averageWaterVolume.rounded(precision: 2), title: "average_water_volume".localized)
        averageWaterView.isHidden = averageWaterVolume == 0
    }
    
}

private extension ExtendedWaterChartViewController {
    
    func setupChart() {
        chartView.dragXEnabled = true
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawMarkers = false
        chartView.noDataFont = AppTheme.current.fonts.medium(14)
        chartView.noDataText = "no_data".localized
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
