//
//  ExtendedMoodChartViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 20/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class ExtendedMoodChartViewController: ExtendedChartViewController {
    
    @IBOutlet private var chart: MoodChartView!
    
    private let moodService = ServicesAssembly.shared.moodServce
    
    override func prepare() {
        super.prepare()
        title = "mood".localized
    }
    
    override func refresh() {
        super.refresh()
        refreshMoodChart()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        chart.backgroundColor = AppTheme.current.colors.middlegroundColor
        chart.axisColor = AppTheme.current.colors.decorationElementColor
        chart.lineColor = AppTheme.current.colors.inactiveElementColor
    }
    
}

private extension ExtendedMoodChartViewController {
    
    func refreshMoodChart() {
        guard let sprint = self.sprint else { return }
        
        let moods = moodService.fetchMoods(sprint: sprint)
        
        let entries: [MoodChartEntry] = moods
            .lazy
            .sorted(by: { $0.date.isLower(than: $1.date) })
            .enumerated()
            .map { MoodChartEntry(index: $0.0, mood: $0.1) }
        
        chart.entries = entries
    }
    
}
