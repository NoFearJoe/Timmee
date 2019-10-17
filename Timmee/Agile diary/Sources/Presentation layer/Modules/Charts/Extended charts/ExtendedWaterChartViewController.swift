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
    
    @IBOutlet private var chartView: ExtendedBarChartView!
    @IBOutlet private var chartPlaceholderLabel: UILabel!
    @IBOutlet private var averageWaterView: AverageMoodView!
    
    private let waterControlService = ServicesAssembly.shared.waterControlService
    
    override func prepare() {
        super.prepare()
        
        title = "water".localized
        
        chartPlaceholderLabel.text = "water_chart_no_data".localized
        
        averageWaterView.isHidden = true
        chartView.drawValues = true
        chartView.isHidden = true
    }
    
    override func refresh() {
        super.refresh()
        
        guard let sprintID = sprint?.id else { return }
        guard let waterControl = waterControlService.fetchWaterControl(sprintID: sprintID) else { return }
        
        refreshWaterControlProgress(waterControl: waterControl)
        refreshAverageWaterVolume(waterControl: waterControl)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        chartPlaceholderLabel.textColor = AppTheme.current.colors.inactiveElementColor
        chartPlaceholderLabel.font = AppTheme.current.fonts.regular(16)
        
        chartView.backgroundColor = AppTheme.current.colors.middlegroundColor
        chartView.underlyingBarColor = AppTheme.current.colors.decorationElementColor
    }
    
}

// MARK: - Chart update

private extension ExtendedWaterChartViewController {
    
    func refreshWaterControlProgress(waterControl: WaterControl) {
        guard let sprint = sprint else { return }
        var entries: [ExtendedBarChartEntry] = []
        let startDate: Date = sprint.endDate.isGreater(than: Date.now) ? Date.now : sprint.endDate
        let daysFromSprintStart = max(sprint.startDate.days(before: startDate), 5)
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (startDate - i.asDays).startOfDay
            let drunkVolume = Double((waterControl.drunkVolume[date] ?? 0)) / 1000
            entries.append(ExtendedBarChartEntry(index: daysFromSprintStart - i,
                                                 value: drunkVolume,
                                                 targetValue: Double(waterControl.neededVolume) / 1000,
                                                 title: date.asShortDayMonth,
                                                 color: AppTheme.current.colors.mainElementColor))
        }
        
        chartView.entries = entries
        chartPlaceholderLabel.isHidden = !entries.isEmpty
        chartView.isHidden = entries.isEmpty
    }
    
    func refreshAverageWaterVolume(waterControl: WaterControl) {
        guard let sprint = sprint else { return }
        var totalDrunkVolume: Double = 0
        var notZeroDrunkVolumeDaysCount: Int = 0
        let startDate: Date = sprint.endDate.isGreater(than: Date.now) ? Date.now : sprint.endDate
        let daysFromSprintStart = sprint.startDate.days(before: startDate)
        for i in stride(from: daysFromSprintStart, through: 0, by: -1) {
            let date = (startDate - i.asDays).startOfDay
            let drunkVolume = Double((waterControl.drunkVolume[date] ?? 0)) / 1000
            guard drunkVolume != 0 else { continue }
            totalDrunkVolume += drunkVolume
            notZeroDrunkVolumeDaysCount += 1
        }
        let averageWaterVolume = totalDrunkVolume.safeDivide(by: Double(notZeroDrunkVolumeDaysCount))
        averageWaterView.configure(waterVolume: averageWaterVolume.rounded(precision: 2), title: "average_water_volume".localized)
        averageWaterView.isHidden = averageWaterVolume == 0
    }
    
}
