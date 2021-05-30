//
//  HabitsPickerCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 14/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class HabitsPickerCell: SwipeTableViewCell {
    
    static let reuseIdentifier = "HabitsPickerCell"
    
    private let containerView = UIView()
    private let contentContainerView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkbox = Checkbox()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupLayout()
        
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.backgroundColor = AppTheme.current.colors.foregroundColor
        containerView.layer.cornerRadius = 8
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.medium(18)
        subtitleLabel.font = AppTheme.current.fonts.regular(13)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(habit: Habit, isPicked: Bool) {
        titleLabel.text = habit.title
        subtitleLabel.attributedText = habit.makePropertiesString()
        
        checkbox.isChecked = isPicked
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(contentContainerView)
        containerView.addSubview(checkbox)
        
        contentContainerView.distribution = .fill
        contentContainerView.alignment = .fill
        contentContainerView.spacing = 0
        contentContainerView.axis = .vertical
        
        contentContainerView.addArrangedSubview(titleLabel)
        contentContainerView.addArrangedSubview(subtitleLabel)
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        checkbox.backgroundColor = .clear
        checkbox.isUserInteractionEnabled = false
    }
    
    private func setupLayout() {
        [containerView.leading(15), containerView.trailing(15), containerView.top(6), containerView.bottom(6)].toSuperview()
        
        [contentContainerView.leading(8), contentContainerView.centerY()].toSuperview()
        contentContainerView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 4).isActive = true
        
        checkbox.height(24)
        checkbox.width(24)
        [checkbox.centerY(), checkbox.trailing(8)].toSuperview()
        checkbox.leadingToTrailing(4).to(contentContainerView, addTo: containerView)
    }
    
}
