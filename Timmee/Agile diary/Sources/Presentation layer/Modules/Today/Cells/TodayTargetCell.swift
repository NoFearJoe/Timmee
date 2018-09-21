//
//  TodayTargetCell.swift
//  Agile diary
//
//  Created by i.kharabet on 11.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit
import UIComponents

final class TodayTargetCell: SwipeTableViewCell {
    
    var onChangeCheckedState: ((Bool, Subtask) -> Void)?
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var stagesTitleLabel: UILabel!
    @IBOutlet private var stagesContainer: UIView!
    
    @IBOutlet private var stagesTitleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var stagesTitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private var stagesTitleLabelBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 8
        containerView.configureShadow(radius: 4, opacity: 0.1)
        stagesTitleLabel.text = "stages".localized
        stagesTitleLabel.font = AppTheme.current.fonts.regular(14)
    }
    
    func configure(target: Target) {
        setupAppearance()
        containerView.alpha = target.isDone ? AppTheme.current.style.alpha.disabled : AppTheme.current.style.alpha.enabled
        titleLabel.text = target.title
        addStageViews(target: target)
        stagesTitleLabelHeightConstraint.constant = target.subtasks.isEmpty ? 0 : 20
        stagesTitleLabelTopConstraint.constant = target.subtasks.isEmpty ? 0 : 4
        stagesTitleLabelBottomConstraint.constant = target.subtasks.isEmpty ? 0 : 4
    }
    
    private func addStageViews(target: Target) {
        stagesContainer.subviews.forEach { $0.removeFromSuperview() }
        
        let subtasks = target.subtasks.sorted(by: { $0.sortPosition < $1.sortPosition })
        for (index, subtask) in subtasks.enumerated() {
            let stageView = StageView.loadedFromNib()
            stageView.title = subtask.title
            stageView.isChecked = subtask.isDone
            stageView.setupAppearance()
            stageView.onChangeCheckedState = { [unowned self] isChecked in
                self.onChangeCheckedState?(isChecked, subtask)
            }
            stagesContainer.addSubview(stageView)
            if index == 0 {
                [stageView.top(), stageView.leading(), stageView.trailing()].toSuperview()
            } else if index >= subtasks.count - 1 {
                [stageView.leading(), stageView.trailing(), stageView.bottom()].toSuperview()
                let previousView = stagesContainer.subviews[index - 1]
                stageView.topToBottom().to(previousView, addTo: stagesContainer)
            } else {
                [stageView.leading(), stageView.trailing()].toSuperview()
                let previousView = stagesContainer.subviews[index - 1]
                stageView.topToBottom().to(previousView, addTo: stagesContainer)
            }
        }
    }
    
    private func setupAppearance() {
        containerView.backgroundColor = AppTheme.current.colors.foregroundColor
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        stagesTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
}
