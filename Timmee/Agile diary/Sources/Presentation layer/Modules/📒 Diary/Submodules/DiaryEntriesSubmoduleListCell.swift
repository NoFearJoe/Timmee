//
//  DiaryEntriesSubmoduleListCell.swift
//  Agile diary
//
//  Created by i.kharabet on 31/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class DiaryEntriesSubmoduleListCell: UITableViewCell {
    
    static let identifier: String = String(describing: DiaryEntryCell.self)
    
    private let dateLabel = UILabel(frame: .zero)
    private let bubbleView = BarView(frame: .zero)
    private lazy var bubbleContentView = UIStackView(arrangedSubviews: [bubbleTextLabel])
    private let bubbleTextLabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func configure(model: DiaryEntry) {
        dateLabel.text = model.date.asDayMonthTime
        bubbleTextLabel.text = model.text
    }
    
    private func setupSubviews() {
        contentView.addSubview(dateLabel)
        dateLabel.font = AppTheme.current.fonts.regular(12)
        dateLabel.textColor = AppTheme.current.colors.inactiveElementColor
        
        contentView.addSubview(bubbleView)
        bubbleView.backgroundColor = AppTheme.current.colors.foregroundColor
        bubbleView.roundedCorners = .allCorners
        bubbleView.cornerRadius = 6
        bubbleView.showShadow = true
        bubbleView.layer.shadowOpacity = 0.15
        
        bubbleContentView.axis = .vertical
        bubbleContentView.distribution = .equalSpacing
        bubbleContentView.spacing = 4
        bubbleView.addSubview(bubbleContentView)
        
        bubbleTextLabel.font = AppTheme.current.fonts.regular(16)
        bubbleTextLabel.textColor = AppTheme.current.colors.activeElementColor
        bubbleTextLabel.numberOfLines = 0
    }
    
    private func setupConstraints() {
        [dateLabel.leading(), dateLabel.top(8), dateLabel.trailing()].toSuperview()
        [bubbleView.leading(), bubbleView.bottom(4)].toSuperview()
        bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: 0).isActive = true
        bubbleContentView.allEdges(6).toSuperview()
        dateLabel.bottomToTop(-4).to(bubbleView, addTo: contentView)
    }
    
}
