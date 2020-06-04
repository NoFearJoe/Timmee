//
//  AchievementCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 01/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class AchievementCell: UICollectionViewCell {
    
    static let identifier = "AchievementCell"
    
    private let titlesContainer = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconView = UIImageView()
    private let counterBadge = BadgeView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(model: AchievementViewModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        subtitleLabel.isHidden = model.subtitle == nil
        iconView.image = model.icon
        counterBadge.title = "\(model.count)"
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        let targetSize = CGSize(width: layoutAttributes.bounds.width, height: 0)
        
        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        
        attributes.frame = CGRect(origin: attributes.frame.origin, size: size)
        
        return attributes
    }
    
    private func setupViews() {
        configureShadow(radius: 8, opacity: 0.05)
        
        contentView.backgroundColor = AppTheme.current.colors.foregroundColor
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        contentView.addSubview(iconView)
        iconView.contentMode = .scaleAspectFit
        iconView.width(48)
        iconView.height(48)
        [iconView.leading(8), iconView.top(12)].toSuperview()
        iconView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        iconView.addSubview(counterBadge)
        counterBadge.font = AppTheme.current.fonts.medium(14)
        counterBadge.height(20)
        counterBadge.width(greatherOrEqual: 20)
        [counterBadge.bottom(-4), counterBadge.trailing(-4)].toSuperview()
        
        contentView.addSubview(titlesContainer)
        titlesContainer.axis = .vertical
        titlesContainer.leadingToTrailing(16).to(iconView, addTo: contentView)
        [titlesContainer.top(12), titlesContainer.trailing(8)].toSuperview()
        let titlesBottomConstraint = titlesContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        titlesBottomConstraint.priority = .defaultHigh
        titlesBottomConstraint.isActive = true
        
        titlesContainer.addArrangedSubview(titleLabel)
        titleLabel.font = AppTheme.current.fonts.medium(18)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        titlesContainer.addArrangedSubview(subtitleLabel)
        subtitleLabel.font = AppTheme.current.fonts.regular(14)
        subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        subtitleLabel.numberOfLines = 0
    }
    
}
