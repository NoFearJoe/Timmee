//
//  SprintCreationHabitCell.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

class SprintCreationHabitCell: SwipeTableViewCell {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        containerView.backgroundColor = AppTheme.current.colors.foregroundColor
        containerView.layer.cornerRadius = 8
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.medium(20)
        subtitleLabel.font = AppTheme.current.fonts.regular(14)
    }
    
    func configure(habit: Habit) {
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
        
        if let notificationDate = habit.notificationDate {
            attributedSubtitle.append(NSAttributedString(string: "at".localized + " ",
                                                         attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
            attributedSubtitle.append(NSAttributedString(string: notificationDate.asTimeString,
                                                         attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        }
        subtitleLabel.attributedText = attributedSubtitle
    }
    
}
