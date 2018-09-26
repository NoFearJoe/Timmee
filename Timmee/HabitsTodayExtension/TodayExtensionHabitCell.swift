//
//  TodayExtensionHabitCell.swift
//  HabitsTodayExtension
//
//  Created by i.kharabet on 18.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Workset

final class TodayExtensionHabitCell: UITableViewCell {
    
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
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        titleLabel.textColor = UIColor(rgba: "444444")
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    func configure(habit: Habit) {
        checkbox.isChecked = habit.isDone(at: Date.now)
        containerView.alpha = habit.isDone(at: Date.now) ? 0.5 : 1
        titleLabel.text = habit.title
        
        let attributedSubtitle = NSMutableAttributedString()
        if let notificationDate = habit.notificationDate {
            attributedSubtitle.append(NSAttributedString(string: notificationDate.asTimeString,
                                                         attributes: [.foregroundColor: UIColor(rgba: "AAAAAA")]))
        }
        if !habit.link.trimmed.isEmpty {
            if habit.notificationDate != nil {
                attributedSubtitle.append(NSAttributedString(string: ", ",
                                                             attributes: [.foregroundColor: UIColor(rgba: "AAAAAA")]))
            }
            attributedSubtitle.append(NSAttributedString(string: habit.link.trimmed,
                                                         attributes: [.foregroundColor: UIColor(rgba: "29C3FE")]))
        }
        subtitleLabel.attributedText = attributedSubtitle
    }
    
}
