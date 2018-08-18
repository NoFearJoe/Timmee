//
//  SprintCreationHabitCell.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class SprintCreationHabitCell: SwipeTableViewCell {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = UIColor(rgba: "f5f5f5")
        containerView.layer.cornerRadius = 8
//        containerView.layer.shadowColor = UIColor.black.cgColor
//        containerView.layer.shadowOffset = .zero
//        containerView.layer.shadowRadius = 4
//        containerView.layer.shadowOpacity = 0.2
    }
    
    func configure(habit: Habit) {
        titleLabel.text = habit.title
        
        let attributedSubtitle = NSMutableAttributedString()
        attributedSubtitle.append(NSAttributedString(string: habit.repeating.localized, attributes: [.foregroundColor: UIColor(rgba: "888888")]))
        if let notificationDate = habit.notificationDate {
            attributedSubtitle.append(NSAttributedString(string: " " + "at".localized + " ", attributes: [.foregroundColor: UIColor(rgba: "888888")]))
            attributedSubtitle.append(NSAttributedString(string: notificationDate.asTimeString, attributes: [.foregroundColor: UIColor(rgba: "3ECAFF")]))
        }
        subtitleLabel.attributedText = attributedSubtitle
    }
    
}
