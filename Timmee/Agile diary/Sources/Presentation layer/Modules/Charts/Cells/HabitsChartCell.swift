//
//  HabitsChartCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 23.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Charts

final class HabitsChartCell: BaseChartCell {
    
    let habitsService = ServicesAssembly.shared.habitsService
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "habits".localized
            titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
            titleLabel.font = AppTheme.current.fonts.medium(15)
        }
    }
    @IBOutlet private var chartView: LineChartView! {
        didSet { setupChartView() }
    }
    
    @IBOutlet private var fullProgressButton: UIButton! {
        didSet {
            fullProgressButton.setTitle("show_full_progress".localized, for: .normal)
            fullProgressButton.tintColor = AppTheme.current.colors.mainElementColor
            fullProgressButton.isHidden = true
        }
    }
    
    @IBAction private func showFullProgress() {
        onShowFullProgress?()
    }
    
    override func update(sprint: Sprint) {
        fullProgressButton.isHidden = !(ProVersionPurchase.shared.isPurchased() || Environment.isDebug)
        
        let habits = habitsService.fetchHabits(sprintID: sprint.id)
        
        var chartEntries: [ChartDataEntry] = []
        var xAxisTitles: [String] = []
        let startDate: Date = sprint.endDate.isGreater(than: Date.now) ? Date.now : sprint.endDate
        for i in stride(from: 6, through: 0, by: -1) {
            let date = (startDate - i.asDays).startOfDay
            let repeatDay = DayUnit(weekday: date.weekday)
            let allHabits = habits.filter { $0.creationDate.startOfDay <= date && $0.dueDays.contains(repeatDay) }
            let completedHabits = allHabits.filter { $0.doneDates.contains(where: { $0.isWithinSameDay(of: date) }) }.count
            chartEntries.append(ChartDataEntry(x: Double(6 - i), y: Double(completedHabits)))
            xAxisTitles.append(date.asShortDayMonth)
        }
        let dataSet = LineChartDataSet(entries: chartEntries, label: nil)
        dataSet.label = nil
        dataSet.colors = [AppTheme.current.colors.mainElementColor]
        dataSet.valueColors = [AppTheme.current.colors.mainElementColor]
        dataSet.circleRadius = 4
        dataSet.circleColors = [AppTheme.current.colors.mainElementColor]
        dataSet.circleHoleRadius = 0
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true
        if let fillGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                         colors: [AppTheme.current.colors.mainElementColor.cgColor,
                                                  AppTheme.current.colors.mainElementColor.withAlphaComponent(0).cgColor] as CFArray,
                                         locations: [1, 0]) {
            dataSet.fill = Fill.init(linearGradient: fillGradient, angle: 90)
        }
        
        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (i, _) -> String in
            xAxisTitles[Int(i)]
        })
        
        chartView.leftAxis.axisMaximum = Double(habits.count)
        
        chartView.data = LineChartData(dataSet: dataSet)
        chartView.notifyDataSetChanged()
    }
    
    override static func size(for collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width - 30, height: 256)
    }
    
    private func setupChartView() {
        chartView.drawGridBackgroundEnabled = false
        chartView.drawMarkers = false
        chartView.noDataFont = AppTheme.current.fonts.medium(14)
        chartView.noDataText = "habits_chart_no_data".localized
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
