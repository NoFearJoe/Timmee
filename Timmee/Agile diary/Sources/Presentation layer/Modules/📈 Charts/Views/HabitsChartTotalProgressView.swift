//
//  HabitsChartTotalProgressView.swift
//  Agile diary
//
//  Created by Илья Харабет on 26.04.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

final class HabitsChartTotalProgressView: UIView {
    
    private let titleLabel = UILabel()
    private let percentLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        titleLabel.text = "habits_chart_total_progress_title".localized
        titleLabel.font = AppTheme.current.fonts.regular(16)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        [titleLabel.leading(15), titleLabel.centerY()].toSuperview()
        
        percentLabel.font = AppTheme.current.fonts.bold(36)
        percentLabel.textColor = AppTheme.current.colors.activeElementColor
        percentLabel.textAlignment = .right
        addSubview(percentLabel)
        percentLabel.leadingToTrailing(8).to(titleLabel, addTo: self)
        [percentLabel.trailing(15), percentLabel.top(15), percentLabel.bottom(15)].toSuperview()
        percentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(percent: Double) {
        percentLabel.text = "\(percent)%"
        percentLabel.textColor = {
            switch percent {
            case ..<33.3:
                return AppTheme.current.colors.wrongElementColor
            case 33.3..<66.6:
                return AppTheme.current.colors.incompleteElementColor
            default:
                return AppTheme.current.colors.selectedElementColor
            }
        }()
    }
    
}
