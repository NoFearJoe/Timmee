//
//  ShortHabitCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 31/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

import SwipeCellKit

class ShortHabitCell: SwipeTableViewCell {
    
    static let reuseIdentifier = "ShortHabitCell"
    
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupLayout()
        
        selectionStyle = .none
        backgroundColor = .clear
        
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.medium(18)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(habit: Habit) {
        titleLabel.text = habit.title
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
    }
    
    private func setupLayout() {
        titleLabel.allEdges(8).toSuperview()
    }
    
}

