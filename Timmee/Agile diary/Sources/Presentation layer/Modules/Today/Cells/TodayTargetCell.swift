//
//  TodayTargetCell.swift
//  Agile diary
//
//  Created by i.kharabet on 11.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class TodayTargetCell: SwipeTableViewCell {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var stagesContainer: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = UIColor(rgba: "f5f5f5")
        containerView.layer.cornerRadius = 8
    }
    
    func configure(target: Target) {
        containerView.alpha = target.isDone ? 0.75 : 1
        titleLabel.text = target.title
        
        
    }
    
    private func addStageViews(target: Target) {
        let subtasks = target.subtasks.sorted(by: { $0.sortPosition < $1.sortPosition })
        for (index, subtask) in subtasks.enumerated() {
            
        }
    }
    
}
