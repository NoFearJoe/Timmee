//
//  SprintCreationTargetCell.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class SprintCreationTargetCell: SwipeTableViewCell {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var stagesTitleLabel: UILabel!
    @IBOutlet private var stagesLabel: UILabel!
    
    @IBOutlet private var stagesTitleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var stagesTitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private var stagesTitleLabelBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = UIColor(rgba: "f5f5f5")
        containerView.layer.cornerRadius = 8
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.medium(20)
        stagesTitleLabel.text = "stages".localized
        stagesTitleLabel.font = AppTheme.current.fonts.regular(14)
    }
    
    func configure(target: Target) {
        titleLabel.text = target.title
        stagesLabel.attributedText = makeStagesText(target.subtasks.sorted(by: { $0.sortPosition < $1.sortPosition }))
        stagesTitleLabelHeightConstraint.constant = target.subtasks.isEmpty ? 0 : 20
        stagesTitleLabelTopConstraint.constant = target.subtasks.isEmpty ? 0 : 4
        stagesTitleLabelBottomConstraint.constant = target.subtasks.isEmpty ? 0 : 4
    }
    
    private func makeStagesText(_ stages: [Subtask]) -> NSAttributedString {
        let resultString = NSMutableAttributedString()
        for (index, stage) in stages.enumerated() {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 4
            let stageNumberString = NSAttributedString(string: "#\(stage.sortPosition) ", attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor, .font: AppTheme.current.fonts.regular(14), .paragraphStyle: paragraphStyle])
            let stageTitleString = NSAttributedString(string: stage.title, attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor, .paragraphStyle: paragraphStyle])
            resultString.append(stageNumberString)
            resultString.append(stageTitleString)
            if index < stages.count - 1 {
                resultString.append(NSAttributedString(string: "\n"))
            }
        }
        return resultString
    }
    
}
