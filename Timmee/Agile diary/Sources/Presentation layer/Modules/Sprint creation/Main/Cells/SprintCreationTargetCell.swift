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
    
    static let reuseIdentifier = "SprintCreationTargetCell"
    
    private let containerView = UIView()
    private let contentContainerView = UIStackView()
    private let titleLabel = UILabel()
    private let habitsCountLabel = UILabel()
    private let stagesSeparator = UIView()
    private let stagesTitleLabel = UILabel()
    private let stagesLabel = UILabel()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupLayout()
        
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.backgroundColor = AppTheme.current.colors.foregroundColor
        containerView.layer.cornerRadius = 8
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.medium(18)
        habitsCountLabel.font = AppTheme.current.fonts.regular(13)
        habitsCountLabel.textColor = AppTheme.current.colors.inactiveElementColor
        stagesSeparator.backgroundColor = AppTheme.current.colors.decorationElementColor
        stagesTitleLabel.text = "stages".localized
        stagesTitleLabel.font = AppTheme.current.fonts.regular(13)
        stagesTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(goal: Goal) {
        titleLabel.text = goal.title
        
        habitsCountLabel.isHidden = goal.habits.isEmpty
        habitsCountLabel.attributedText = makeHabitsCountText(count: goal.habits.count)
        
        stagesSeparator.isHidden = goal.stages.isEmpty
        stagesTitleLabel.isHidden = goal.stages.isEmpty
        stagesLabel.isHidden = goal.stages.isEmpty
        stagesLabel.attributedText = makeStagesText(goal.stages.sorted(by: { $0.sortPosition < $1.sortPosition }))
    }
    
    private func makeHabitsCountText(count: Int) -> NSAttributedString {
        let resultString = NSMutableAttributedString(
            string: "n_habits".localized(with: count),
            attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]
        )
        
        if let range = resultString.string.range(of: "\(count)") {
            let location = resultString.string.distance(from: resultString.string.startIndex, to: range.lowerBound)
            let length = resultString.string.distance(from: range.lowerBound, to: range.upperBound)
            resultString.setAttributes(
                [.foregroundColor: AppTheme.current.colors.mainElementColor],
                range: NSRange(location: location, length: length)
            )
        }
        
        return resultString
    }
    
    private func makeStagesText(_ stages: [Subtask]) -> NSAttributedString {
        let resultString = NSMutableAttributedString()
        for (index, stage) in stages.enumerated() {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 4
            
            let stageNumberString = NSAttributedString(
                string: "#\(index + 1) ",
                attributes: [
                    .foregroundColor: AppTheme.current.colors.mainElementColor,
                    .font: AppTheme.current.fonts.regular(14),
                    .paragraphStyle: paragraphStyle
                ]
            )
            resultString.append(stageNumberString)
            
            let stageTitleString = NSAttributedString(
                string: stage.title,
                attributes: [
                    .foregroundColor: AppTheme.current.colors.activeElementColor,
                    .font: AppTheme.current.fonts.regular(14),
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            resultString.append(stageTitleString)
            
            if index < stages.count - 1 {
                resultString.append(NSAttributedString(string: "\n"))
            }
        }
        return resultString
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(contentContainerView)
        
        contentContainerView.distribution = .fill
        contentContainerView.alignment = .fill
        contentContainerView.spacing = 4
        contentContainerView.axis = .vertical
        
        contentContainerView.addArrangedSubview(titleLabel)
        contentContainerView.addArrangedSubview(habitsCountLabel)
        contentContainerView.addArrangedSubview(stagesSeparator)
        contentContainerView.addArrangedSubview(stagesTitleLabel)
        contentContainerView.addArrangedSubview(stagesLabel)
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        stagesTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        habitsCountLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        stagesLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    private func setupLayout() {
        [containerView.leading(15), containerView.trailing(15), containerView.top(6), containerView.bottom(6)].toSuperview()
        
        [contentContainerView.leading(8), contentContainerView.trailing(8), contentContainerView.centerY()].toSuperview()
        contentContainerView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 8).isActive = true
        
        stagesSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
}
