//
//  TodayGoalCell.swift
//  Agile diary
//
//  Created by i.kharabet on 11.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit
import UIComponents

final class TodayGoalCell: SwipeTableViewCell {
    
    var onChangeCheckedState: ((Bool, Subtask) -> Void)?
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var noteExistanceIconView: UIImageView!
    @IBOutlet private var stagesTitleLabel: UILabel!
    @IBOutlet private var stagesContainer: UIView!
    
    @IBOutlet private var noteExistanceIconViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var noteExistanceIconViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private var statusLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private var stagesTitleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var stagesTitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private var stagesTitleLabelBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 8
        containerView.configureShadow(radius: 4, opacity: 0.1)
        titleLabel.font = AppTheme.current.fonts.medium(18)
        stagesTitleLabel.text = "stages".localized
        stagesTitleLabel.font = AppTheme.current.fonts.regular(14)
    }
    
    func configure(goal: Goal) {
        setupAppearance()
        containerView.alpha = goal.isDone ? AppTheme.current.style.alpha.inactive : AppTheme.current.style.alpha.enabled
        statusLabel.text = goal.isDone ? "complete".localized : nil
        statusLabelBottomConstraint.constant = goal.isDone ? 0 : 6
        titleLabel.text = goal.title
        noteExistanceIconView.isHidden = goal.note.isEmpty
        noteExistanceIconViewWidthConstraint.constant = goal.note.isEmpty ? 0 : 20
        noteExistanceIconViewLeadingConstraint.constant = goal.note.isEmpty ? 0 : 8
        addStageViews(goal: goal)
        stagesTitleLabelHeightConstraint.constant = goal.stages.isEmpty ? 0 : 16
        stagesTitleLabelTopConstraint.constant = goal.stages.isEmpty ? 0 : 8
        stagesTitleLabelBottomConstraint.constant = goal.stages.isEmpty ? 0 : 4
    }
    
    private func addStageViews(goal: Goal) {
        stagesContainer.subviews.forEach { $0.removeFromSuperview() }
        
        let stages = goal.stages.sorted(by: { $0.sortPosition < $1.sortPosition }).prefix(3)
        for (index, stage) in stages.enumerated() {
            let stageView = StageView.loadedFromNib()
            stageView.title = stage.title
            stageView.isChecked = stage.isDone
            stageView.setupAppearance()
            stageView.onChangeCheckedState = { [unowned self] isChecked in
                self.onChangeCheckedState?(isChecked, stage)
            }
            stagesContainer.addSubview(stageView)
            if stages.count == 1 {
                stageView.allEdges().toSuperview()
            } else if index == 0 {
                [stageView.top(), stageView.leading(), stageView.trailing()].toSuperview()
            } else if index >= stages.count - 1 {
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
        statusLabel.textColor = AppTheme.current.colors.mainElementColor
        statusLabel.font = AppTheme.current.fonts.medium(13)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.medium(18)
        stagesTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        stagesTitleLabel.font = AppTheme.current.fonts.regular(14)
        noteExistanceIconView.tintColor = AppTheme.current.colors.inactiveElementColor
    }
    
}
