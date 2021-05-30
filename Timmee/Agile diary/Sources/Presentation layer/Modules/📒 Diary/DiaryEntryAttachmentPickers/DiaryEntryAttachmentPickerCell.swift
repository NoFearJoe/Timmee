//
//  DiaryEntryAttachmentPickerCell.swift
//  Agile diary
//
//  Created by i.kharabet on 29/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset
import UIComponents

final class DiaryEntryAttachmentPickerCell: UITableViewCell {
    
    static let identifier = String(describing: DiaryEntryAttachmentPickerCell.self)
    
    private lazy var containerView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    private let titleLabel = UILabel(frame: .zero)
    private let subtitleLabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    private func setupSubviews() {
        containerView.axis = .vertical
        containerView.spacing = 2
        containerView.distribution = .equalSpacing
        contentView.addSubview(containerView)
        
        titleLabel.font = AppTheme.current.fonts.regular(17)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        
        subtitleLabel.font = AppTheme.current.fonts.regular(13)
        subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
    private func setupConstraints() {
        [containerView.leading(), containerView.trailing(), containerView.centerY()].toSuperview()
        containerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8).isActive = true
    }
    
}
