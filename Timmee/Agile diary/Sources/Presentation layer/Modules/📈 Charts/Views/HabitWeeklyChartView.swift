//
//  HabitWeeklyChartView.swift
//  Agile diary
//
//  Created by i.kharabet on 22/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

final class HabitWeeklyChartView: UIView {
    
    static var requiredHeight: CGFloat {
        let entryView = HabitWeeklyChartEntryView()
        entryView.configure(model: .init(weekday: "Mon", status: .done, date: "29.02"))
        let size = entryView.systemLayoutSizeFitting(CGSize(width: HabitWeeklyChartEntryView.requiredWidth,
                                                            height: .greatestFiniteMagnitude))
        return size.height
    }
    
    struct Model {
        let weekday: String
        let status: HabitStatus
        let date: String
    }
    
    enum HabitStatus {
        case done
        case skipped
        case notDone
    }
    
    private let stackView = UIStackView(frame: .zero)
    private let messageLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func configure(models: [Model]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        messageLabel.isHidden = !models.isEmpty
        stackView.isHidden = models.isEmpty
        
        for model in models {
            let entryView = HabitWeeklyChartEntryView()
            entryView.configure(model: model)
            entryView.width(HabitWeeklyChartEntryView.requiredWidth)
            stackView.addArrangedSubview(entryView)
        }
    }
    
    private func setupSubviews() {
        addSubview(stackView)
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        addSubview(messageLabel)
        messageLabel.font = AppTheme.current.fonts.regular(17)
        messageLabel.textColor = AppTheme.current.colors.activeElementColor
        messageLabel.text = "habits_chart_no_data".localized
        messageLabel.numberOfLines = 2
    }
    
    private func setupConstraints() {
        [stackView.leading(), stackView.top(), stackView.bottom()].toSuperview()
        stackView.trailingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        
        [messageLabel.leading(), messageLabel.trailing(), messageLabel.centerY()].toSuperview()
    }
    
}

private final class HabitWeeklyChartEntryView: UIView {
    
    static var requiredWidth: CGFloat {
        return 36
    }
    
    private let weekdayLabel = UILabel(frame: .zero)
    private let statusView = ChartStatusView(frame: .zero)
    private let dateLabel: UILabel = UILabel(frame: .zero)
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func configure(model: HabitWeeklyChartView.Model) {
        weekdayLabel.text = model.weekday
        statusView.status = model.status
        dateLabel.text = model.date
    }
    
    private func setupSubviews() {
        addSubview(weekdayLabel)
        addSubview(statusView)
        addSubview(dateLabel)
        
        weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        statusView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        weekdayLabel.font = AppTheme.current.fonts.regular(10)
        dateLabel.font = AppTheme.current.fonts.medium(10)
        
        weekdayLabel.textColor = AppTheme.current.colors.inactiveElementColor
        dateLabel.textColor = AppTheme.current.colors.activeElementColor
        
        weekdayLabel.textAlignment = .center
        dateLabel.textAlignment = .center
    }
    
    private func setupConstraints() {
        [weekdayLabel.leading(), weekdayLabel.trailing(), weekdayLabel.top()].toSuperview()
        [dateLabel.leading(), dateLabel.trailing(), dateLabel.bottom()].toSuperview()
        [statusView.leading(), statusView.trailing()].toSuperview()
        statusView.topToBottom().to(weekdayLabel, addTo: self)
        statusView.bottomToTop().to(dateLabel, addTo: self)
        statusView.width(HabitWeeklyChartEntryView.requiredWidth)
        statusView.height(HabitWeeklyChartEntryView.requiredWidth)
        
        weekdayLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        weekdayLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        dateLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
}

private final class ChartStatusView: UIView {
    
    var status: HabitWeeklyChartView.HabitStatus = .notDone {
        didSet {
            switch status {
            case .done:
                statusIconView.image = UIImage(named: "checkmark")
                statusIconView.tintColor = AppTheme.current.colors.selectedElementColor
            case .skipped:
                statusIconView.image = UIImage(named: "status_skipped")
                statusIconView.tintColor = AppTheme.current.colors.incompleteElementColor
            case .notDone:
                statusIconView.image = UIImage(named: "cross")
                statusIconView.tintColor = AppTheme.current.colors.wrongElementColor
            }
        }
    }
    
    private let statusIconView = UIImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = AppTheme.current.colors.decorationElementColor
        
        clipsToBounds = true
        
        addSubview(statusIconView)
        
        [statusIconView.centerX(), statusIconView.centerY()].toSuperview()
        statusIconView.height(20)
        statusIconView.width(20)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
    }
    
}
