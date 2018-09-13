//
//  TodayHabitCell.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

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
        containerView.backgroundColor = UIColor(rgba: "f5f5f5")
        containerView.layer.cornerRadius = 8
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.medium(20)
        subtitleLabel.font = AppTheme.current.fonts.regular(14)
    }
    
    func configure(habit: Habit) {
        checkbox.isChecked = habit.isDone(at: Date())
        containerView.alpha = habit.isDone(at: Date()) ? AppTheme.current.style.alpha.disabled : AppTheme.current.style.alpha.enabled
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
    
}
