//
//  AllHabitsViewController+Cell.swift
//  Agile diary
//
//  Created by Илья Харабет on 28.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

extension AllHabitsViewController {
    
    final class Cell: UITableViewCell {
        
        static let reuseIdentifier = "Cell"
        
        private let containerView = UIView()
        private let contentContainerView = UIStackView()
        private let titleLabel = UILabel()
        private let subtitleLabel = UILabel()
        private let deleteButton = UIButton()
        
        private var onDelete: (() -> Void)?
        
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
        
        required init?(coder aDecoder: NSCoder) { fatalError() }
        
        func configure(habit: Habit, onDelete: @escaping () -> Void) {
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
            
            self.onDelete = onDelete
        }
        
        private func setupViews() {
            contentView.addSubview(containerView)
            
            containerView.addSubview(contentContainerView)
            containerView.addSubview(deleteButton)
            
            contentContainerView.distribution = .fill
            contentContainerView.alignment = .fill
            contentContainerView.spacing = 0
            contentContainerView.axis = .vertical
            
            contentContainerView.addArrangedSubview(titleLabel)
            contentContainerView.addArrangedSubview(subtitleLabel)
            
            titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            subtitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)

            deleteButton.setImage(UIImage(named: "trash"), for: .normal)
            deleteButton.tintColor = AppTheme.current.colors.wrongElementColor
            deleteButton.backgroundColor = .clear
            deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        }
        
        private func setupLayout() {
            [containerView.leading(15), containerView.trailing(15), containerView.top(6), containerView.bottom(6)].toSuperview()
            
            [contentContainerView.leading(8), contentContainerView.centerY()].toSuperview()
            contentContainerView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 4).isActive = true
            
            deleteButton.height(24)
            deleteButton.width(24)
            [deleteButton.centerY(), deleteButton.trailing(8)].toSuperview()
            deleteButton.leadingToTrailing(4).to(contentContainerView, addTo: containerView)
        }
        
        @objc private func didTapDeleteButton() {
            onDelete?()
        }
        
    }
    
}
