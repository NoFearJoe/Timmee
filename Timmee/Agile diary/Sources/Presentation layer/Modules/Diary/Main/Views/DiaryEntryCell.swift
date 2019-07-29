//
//  DiaryEntryCell.swift
//  Agile diary
//
//  Created by i.kharabet on 26/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class DiaryEntryCell: UITableViewCell {
    
    static let identifier: String = String(describing: DiaryEntryCell.self)
    
    private let dateLabel = UILabel(frame: .zero)
    private let bubbleView = BarView(frame: .zero)
    private lazy var bubbleContentView = UIStackView(arrangedSubviews: [bubbleTextLabel, attachmentView])
    private let bubbleTextLabel = UILabel(frame: .zero)
    private let attachmentView = AttachmentView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
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
        
        switch model.attachment {
        case .none:
            attachmentView.isHidden = true
        case let .habit(id):
            guard let habit = ServicesAssembly.shared.habitsService.fetchHabit(id: id) else { return }
            attachmentView.isHidden = false
            attachmentView.configure(title: habit.title)
        case let .goal(id):
            attachmentView.isHidden = false
            attachmentView.configure(title: id)
        case let .sprint(id):
            attachmentView.isHidden = false
            attachmentView.configure(title: id)
        }
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
        bubbleView.layer.shadowOpacity = 0.05
        
        bubbleContentView.axis = .vertical
        bubbleContentView.distribution = .equalSpacing
        bubbleContentView.spacing = 4
        bubbleView.addSubview(bubbleContentView)
        
        bubbleTextLabel.font = AppTheme.current.fonts.regular(16)
        bubbleTextLabel.textColor = AppTheme.current.colors.activeElementColor
        bubbleTextLabel.numberOfLines = 0
    }
    
    private func setupConstraints() {
        [dateLabel.leading(16), dateLabel.top(8), dateLabel.trailing(16)].toSuperview()
        [bubbleView.leading(16), bubbleView.bottom(4)].toSuperview()
        bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16).isActive = true
        bubbleContentView.allEdges(6).toSuperview()
        dateLabel.bottomToTop(-4).to(bubbleView, addTo: contentView)
    }
    
}

extension DiaryEntryCell {
    
    class AttachmentView: UIView {
        
        private let titleLabel = UILabel(frame: .zero)
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            backgroundColor = AppTheme.current.colors.decorationElementColor
            clipsToBounds = true
            layer.cornerRadius = 6
            
            setupSubviews()
            setupConstraints()
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError() }
        
        func configure(title: String) {
            titleLabel.text = title
        }
        
        private func setupSubviews() {
            addSubview(titleLabel)
            titleLabel.font = AppTheme.current.fonts.regular(16)
            titleLabel.textColor = AppTheme.current.colors.activeElementColor
        }
        
        private func setupConstraints() {
            [titleLabel.leading(8), titleLabel.trailing(8), titleLabel.top(8), titleLabel.bottom(8)].toSuperview()
        }
        
    }
    
}
