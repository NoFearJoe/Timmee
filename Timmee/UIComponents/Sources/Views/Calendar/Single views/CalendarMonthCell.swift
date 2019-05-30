//
//  CalendarMonthCell.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarMonthEntity {
    let title: String
    var isSelected: Bool
    var isCurrent: Bool
    var isDisabled: Bool
    var tasksCount: Int
    
    init(title: String, isSelected: Bool = false, isCurrent: Bool = false, isDisabled: Bool = false, tasksCount: Int = 0) {
        self.title = title
        self.isSelected = isSelected
        self.isCurrent = isCurrent
        self.isDisabled = isDisabled
        self.tasksCount = tasksCount
    }
}

final class CalendarMonthCell: UICollectionViewCell {
    
    static let identifier: String = "CalendarMonthCell"
    
    private let titleLabel: UILabel = UILabel(frame: .zero)
    private static let titleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    private let badgeView: BadgeView = BadgeView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
        setupTitleLabel()
        setupBadgeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
        setupTitleLabel()
        setupBadgeView()
    }
    
    func configure(entity: CalendarMonthEntity) {
        titleLabel.text = entity.title
        titleLabel.textColor = entity.isSelected ? CalendarDesign.shared.selectedTintColor : CalendarDesign.shared.defaultTintColor
        backgroundColor = entity.isSelected ? CalendarDesign.shared.selectedBackgroundColor : CalendarDesign.shared.defaultBackgroundColor
        layer.borderColor = entity.isCurrent ? CalendarDesign.shared.selectedBackgroundColor.cgColor : UIColor.clear.cgColor
        configureShadow(radius: entity.isSelected ? 4 : 0, opacity: 0.25)
        badgeView.title = entity.tasksCount == 0 ? nil : "\(entity.tasksCount)"
        badgeView.isHidden = entity.tasksCount == 0
        isUserInteractionEnabled = !entity.isDisabled
    }
    
    static func calculateWidth(title: String) -> CGFloat {
        return (title as NSString).size(withAttributes: [
            NSAttributedString.Key.font: CalendarMonthCell.titleFont
        ]).width + 16
    }
    
    private func commonSetup() {
        backgroundColor = CalendarDesign.shared.defaultBackgroundColor
        clipsToBounds = false
        layer.cornerRadius = 6
        layer.borderWidth = 2
    }
    
    private func setupTitleLabel() {
        titleLabel.textColor = CalendarDesign.shared.defaultTintColor
        titleLabel.font = CalendarMonthCell.titleFont
        
        addSubview(titleLabel)
        
        [titleLabel.top(), titleLabel.bottom()].toSuperview()
        [titleLabel.leading(8), titleLabel.trailing(8)].toSuperview()
    }
    
    private func setupBadgeView() {
        badgeView.backgroundColor = CalendarDesign.shared.badgeBackgroundColor
        badgeView.titleColor = CalendarDesign.shared.badgeTintColor
        
        addSubview(badgeView)
        
        [badgeView.top(-7), badgeView.trailing(-7)].toSuperview()
    }
    
}
