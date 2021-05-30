//
//  HabitProgressCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 26.04.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

typealias Progress = (done: Int, total: Int, percent: Double)

final class HabitProgressCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let progressViewsContainer = UIStackView()
    private let absoluteProgressLabel = UILabel()
    private let relativeProgressLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(habit: Habit, progress: Progress) {
        titleLabel.text = habit.title
        absoluteProgressLabel.text = "\(progress.done) \("of".localized) \(progress.total)"
        relativeProgressLabel.text = "\(Int(progress.percent * 100))%"
    }
    
    func setupAppearance() {
        backgroundColor = AppTheme.current.colors.foregroundColor
        titleLabel.font = AppTheme.current.fonts.regular(18)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        absoluteProgressLabel.font = AppTheme.current.fonts.medium(16)
        absoluteProgressLabel.textColor = AppTheme.current.colors.mainElementColor
        relativeProgressLabel.font = AppTheme.current.fonts.regular(16)
        relativeProgressLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        [titleLabel.leading(15), titleLabel.centerY()].toSuperview()
        
        progressViewsContainer.axis = .vertical
        progressViewsContainer.alignment = .trailing
        contentView.addSubview(progressViewsContainer)
        progressViewsContainer.leadingToTrailing(8).to(titleLabel, addTo: contentView)
        [progressViewsContainer.top(4), progressViewsContainer.bottom(4), progressViewsContainer.trailing(15)].toSuperview()
        
        progressViewsContainer.addArrangedSubview(absoluteProgressLabel)
        progressViewsContainer.addArrangedSubview(relativeProgressLabel)
    }
    
}
