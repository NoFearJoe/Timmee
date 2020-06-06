//
//  TodayHabitCell.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit
import UIComponents

final class TodayHabitCell: SwipeTableViewCell {
    
    static let identifier = "TodayHabitCell"
    
    private let checkbox = Checkbox()
    
    private let containerView = UIView()
    private let contentStackView = UIStackView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private var leadingInsetConstraint: NSLayoutConstraint!
    private var trailingInsetConstraint: NSLayoutConstraint!
    
    private var topInsetConstraint: NSLayoutConstraint!
    private var bottomInsetConstraint: NSLayoutConstraint!
    
    private var spacingBetweenCheckboxAndContentConstraint: NSLayoutConstraint!
    
    var onChangeCheckedState: ((Bool) -> Void)? {
        didSet {
            checkbox.didChangeCkeckedState = onChangeCheckedState
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(habit: Habit, currentDate: Date) {
        setupAppearance()
        
        checkbox.isChecked = habit.isDone(at: currentDate)
        containerView.alpha = habit.isDone(at: currentDate) ?
            AppTheme.current.style.alpha.inactive :
            AppTheme.current.style.alpha.enabled
        titleLabel.text = habit.title
        
        let attributedSubtitle = NSMutableAttributedString()
        // 1 раз
        if let value = habit.value {
            attributedSubtitle.append(NSAttributedString(string: value.localized + " ",
                                                         attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        }
        
        // в 5:00
        if !habit.notificationsTime.isEmpty {
            attributedSubtitle.append(NSAttributedString(string: habit.notificationsTime.readableString,
                                                         attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        }
        if !habit.link.trimmed.isEmpty {
            if !habit.notificationsTime.isEmpty {
                attributedSubtitle.append(NSAttributedString(string: ", ",
                                                             attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
            }
            attributedSubtitle.append(NSAttributedString(string: habit.link.trimmed,
                                                         attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        }
        subtitleLabel.attributedText = attributedSubtitle
        subtitleLabel.isHidden = attributedSubtitle.string.isEmpty
    }
    
    func setHoriznotalInsets(_ inset: CGFloat) {
        leadingInsetConstraint.constant = inset
        trailingInsetConstraint.constant = -inset
    }
    
    func setFlat(_ isFlat: Bool) {
        topInsetConstraint.constant = isFlat ? 0 : 6
        bottomInsetConstraint.constant = isFlat ? 0 : -6
        spacingBetweenCheckboxAndContentConstraint.constant = isFlat ? 0 : 8
        
        containerView.configureShadow(radius: isFlat ? 0 : 4, opacity: 0.05)
        
        titleLabel.font = isFlat ? AppTheme.current.fonts.regular(16) : AppTheme.current.fonts.medium(18)
    }
    
    private func setupAppearance() {
        containerView.backgroundColor = AppTheme.current.colors.foregroundColor
        
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.medium(18)
        subtitleLabel.font = AppTheme.current.fonts.regular(14)
        
        checkbox.setNeedsDisplay()
    }
    
}

private extension TodayHabitCell {
    
    func setupViews() {
        contentView.addSubview(checkbox)
        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        checkbox.backgroundColor = .clear
        
        containerView.layer.cornerRadius = 8
        containerView.configureShadow(radius: 4, opacity: 0.05)
        
        contentStackView.axis = .vertical
    }
    
    func setupLayout() {
        checkbox.width(24)
        checkbox.height(24)
        leadingInsetConstraint = checkbox.leading(15).toSuperview()
        [checkbox.centerY()].toSuperview()
        
        spacingBetweenCheckboxAndContentConstraint = containerView
            .leadingToTrailing(8)
            .to(checkbox, addTo: contentView)
        
        trailingInsetConstraint = containerView.trailing(15).toSuperview()
        topInsetConstraint = containerView.top(6).toSuperview()
        bottomInsetConstraint = containerView.bottom(6).toSuperview()
        
        [contentStackView.leading(8), contentStackView.trailing(8), contentStackView.top(12), contentStackView.bottom(12)].toSuperview()
    }
    
}
