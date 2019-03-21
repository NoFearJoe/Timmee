//
//  ExtendedMoodChartViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 20/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Charts

final class ExtendedMoodChartViewController: ExtendedChartViewController {
    
    @IBOutlet private var lineChartPlaceholderLabel: UILabel!
    @IBOutlet private var lineChart: MoodChartView!
    
    @IBOutlet private var pieChart: PieChartView!
    
    @IBOutlet private var averageMoodView: AverageMoodView!
    
    private let moodService = ServicesAssembly.shared.moodServce
    
    override func prepare() {
        super.prepare()
        title = "mood".localized
        lineChartPlaceholderLabel.text = "mood_chart_placeholder_text".localized
    }
    
    override func refresh() {
        super.refresh()
        
        guard let sprint = self.sprint else { return }
        let moods = moodService.fetchMoods(sprint: sprint)
        refreshMoodLineChart(moods: moods)
        refreshMoodPieChart(moods: moods)
        refreshAverageMood(moods: moods)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        lineChartPlaceholderLabel.font = AppTheme.current.fonts.regular(14)
        lineChartPlaceholderLabel.textColor = AppTheme.current.colors.inactiveElementColor
        lineChart.backgroundColor = AppTheme.current.colors.middlegroundColor
        lineChart.axisColor = AppTheme.current.colors.decorationElementColor
        lineChart.lineColor = AppTheme.current.colors.inactiveElementColor
        pieChart.legend.enabled = false
        pieChart.drawEntryLabelsEnabled = false
    }
    
}

private extension ExtendedMoodChartViewController {
    
    func refreshMoodLineChart(moods: [Mood]) {
        let entries: [MoodChartEntry] = moods
            .lazy
            .sorted(by: { $0.date.isLower(than: $1.date) })
            .enumerated()
            .map { MoodChartEntry(index: $0.0, mood: $0.1) }
        
        lineChart.entries = entries
        
        lineChartPlaceholderLabel.isHidden = !entries.isEmpty
    }
    
    func refreshMoodPieChart(moods: [Mood]) {
        let groupedMoods = Dictionary(grouping: moods, by: { $0.kind }).map { ($0, $1) }.sorted(by: { $0.0.value < $1.0.value })
        
        let entries = groupedMoods.map { kind, groupMoods -> PieChartDataEntry in
            PieChartDataEntry(value: Double(groupMoods.count), icon: UIImage(named: kind.icon)?.resize(to: CGSize(width: 28, height: 28)))
        }
        let dataSet = PieChartDataSet(values: entries, label: nil)
        dataSet.colors = groupedMoods.map { $0.0.color.withAlphaComponent(0.75) }
        dataSet.drawValuesEnabled = false
        pieChart.data = PieChartData(dataSet: dataSet)
        pieChart.data?.notifyDataChanged()
    }
    
    func refreshAverageMood(moods: [Mood]) {
        let averageMoodValue = moods.reduce(0, { $0 + $1.kind.value })
        let averageMood = Mood.Kind(value: averageMoodValue)
        averageMoodView.configure(mood: averageMood)
        averageMoodView.isHidden = moods.isEmpty
    }
    
}

final class AverageMoodView: UIView {
    @IBOutlet private var moodIconView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var moodLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = AppTheme.current.fonts.regular(14)
        titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        moodLabel.font = AppTheme.current.fonts.medium(24)
        moodLabel.textColor = AppTheme.current.colors.activeElementColor
    }
    
    func configure(mood: Mood.Kind) {
        titleLabel.text = "average_mood".localized
        moodIconView.image = UIImage(named: mood.icon)
        moodLabel.text = mood.localized
    }
}
