//
//  HabitsHistoryCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 14/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class HabitsHistoryCell: SwipeTableViewCell {
    
    static let reuseIdentifier = "HabitsHistoryCell"
    
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
        
        let attributedSubtitle = NSMutableAttributedString()
        if let value = habit.value {
            attributedSubtitle.append(NSAttributedString(string: value.localized + " ",
                                                         attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        }
        
        let repeatMask = RepeatMask(type: .on(.custom(Set(habit.dueDays)))).localized
        let repeatMaskString = attributedSubtitle.string.isEmpty ? repeatMask.capitalizedFirst : repeatMask.lowercased()
        attributedSubtitle.append(NSAttributedString(string: repeatMaskString + " ",
                                                     attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        
        attributedSubtitle.append(NSAttributedString(string: habit.calculatedDayTime.localizedAt.lowercased() + " ",
                                                     attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        
        if !habit.notificationsTime.isEmpty {
            attributedSubtitle.append(NSAttributedString(string: "at".localized + " ",
                                                         attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
            attributedSubtitle.append(NSAttributedString(string: habit.notificationsTime.readableString,
                                                         attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        }
        subtitleLabel.attributedText = attributedSubtitle
        
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
