//
//  TodayExtensionTaskCell.swift
//  ScopeTodayExtension
//
//  Created by i.kharabet on 21/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset
import TasksKit

final class TodayExtensionTaskCell: UITableViewCell {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var checkbox: CheckBox!
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
    
    func configure(task: Task) {
        checkbox.isChecked = task.isDone(at: Date())
        containerView.alpha = task.isDone(at: Date()) ? 0.5 : 1
        titleLabel.text = task.title
        subtitleLabel.attributedText = makeSubtitleString(task: task)
    }
    
    private func makeSubtitleString(task: Task) -> NSAttributedString? {
        switch task.kind {
        case .single:
            guard let subtitle = task.dueDate?.asNearestDateString else { return nil }
            let subtitleСolor = AppTheme.current.secondaryTintColor
            return NSAttributedString(string: subtitle, attributes: [.foregroundColor: subtitleСolor])
        case .regular:
            if let endDate = task.repeatEndingDate, endDate.startOfDay.isLower(than: Date().startOfDay) {
                return NSAttributedString(string: "regular_task_finished".localized, attributes: [.foregroundColor: AppTheme.current.redColor])
            }
            
            let repeatingString = task.repeating.fullLocalizedString
            var startDateString = ""
            if let startDate = task.dueDate, startDate.startOfDay.isGreater(than: Date().startOfDay) {
                startDateString = "from_date".localized.lowercased() + " " + startDate.asNearestShortDateString.lowercased()
            }
            var endDateString = ""
            if let endDate = task.repeatEndingDate, endDate.startOfDay.isGreater(than: Date().startOfDay) {
                endDateString = "to_date".localized.lowercased() + " " + endDate.asNearestShortDateString.lowercased()
            }
            let subtitle = [repeatingString, startDateString, endDateString].filter({ !$0.isEmpty }).joined(separator: " ")
            return NSAttributedString(string: subtitle, attributes: [.foregroundColor: AppTheme.current.secondaryTintColor])
        }
    }
    
}
