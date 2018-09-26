//
//  WaterChartCell.swift
//  Agile diary
//
//  Created by i.kharabet on 24.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Charts

final class WaterChartCell: BaseChartCell {
    
    let waterControlService = ServicesAssembly.shared.waterControlService
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "water".localized
            titleLabel.textColor = AppTheme.current.colors.activeElementColor
        }
    }
    
    @IBOutlet private var chartView: BarChartView! {
        didSet { setupChartView() }
    }
    
    override func update() {
        guard let waterControl = waterControlService.fetchWaterControl() else { return }
        
        var chartEntries: [BarChartDataEntry] = []
        var xAxisTitles: [String] = []
        for i in stride(from: 6, through: 0, by: -1) {
            let date = (Date.now - i.asDays).startOfDay
            let drunkVolume = Double((waterControl.drunkVolume[date] ?? 0)) / 1000
            chartEntries.append(BarChartDataEntry(x: Double(6 - i), y: drunkVolume))
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
            xAxisTitles[Int(i)]
        })
        
        chartView.leftAxis.axisMaximum = Double((waterControl.neededVolume / 1000) + 1)
        
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
        chartView.noDataText = "water_chart_no_data".localized
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
