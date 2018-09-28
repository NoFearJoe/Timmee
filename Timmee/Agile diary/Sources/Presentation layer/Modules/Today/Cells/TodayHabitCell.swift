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
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var checkbox: Checkbox!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    
    var onChangeCheckedState: ((Bool) -> Void)? {
        didSet {
            checkbox.didChangeCkeckedState = onChangeCheckedState
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 8
        containerView.configureShadow(radius: 4, opacity: 0.1)
        titleLabel.font = AppTheme.current.fonts.medium(18)
        subtitleLabel.font = AppTheme.current.fonts.regular(14)
    }
    
    func configure(habit: Habit) {
        setupAppearance()
        checkbox.isChecked = habit.isDone(at: Date.now)
        containerView.alpha = habit.isDone(at: Date.now) ? AppTheme.current.style.alpha.disabled : AppTheme.current.style.alpha.enabled
        titleLabel.text = habit.title
        
        let attributedSubtitle = NSMutableAttributedString()
        if let notificationDate = habit.notificationDate {
            attributedSubtitle.append(NSAttributedString(string: notificationDate.asTimeString,
                                                         attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        }
        if !habit.link.trimmed.isEmpty {
            if habit.notificationDate != nil {
                attributedSubtitle.append(NSAttributedString(string: ", ",
                                                             attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
            }
            attributedSubtitle.append(NSAttributedString(string: habit.link.trimmed,
                                                         attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        }
        subtitleLabel.attributedText = attributedSubtitle
    }
    
    private func setupAppearance() {
        containerView.backgroundColor = AppTheme.current.colors.foregroundColor
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        checkbox.setNeedsDisplay()
    }
    
}
