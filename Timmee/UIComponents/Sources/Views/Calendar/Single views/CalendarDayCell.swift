//
//  CalendarDayCell.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarDayEntity {
    let number: Int
    let weekday: Int
    var isSelected: Bool
    var isCurrent: Bool
    var isDisabled: Bool
    var tasksCount: Int
    
    init(number: Int, weekday: Int, isSelected: Bool = false, isCurrent: Bool = false, isDisabled: Bool = false, tasksCount: Int = 0) {
        self.number = number
        self.weekday = weekday
        self.isSelected = isSelected
        self.isCurrent = isCurrent
        self.isDisabled = isDisabled
        self.tasksCount = tasksCount
    }
}

final class CalendarDayCell: UICollectionViewCell {
    
    static let identifier: String = "CalendarDayCell"
    
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
    
    func configure(entity: CalendarDayEntity, design: CalendarDesign) {
        titleLabel.text = "\(entity.number)"
        titleLabel.textColor = entity.isSelected ? design.selectedTintColor : design.defaultTintColor
        backgroundColor = entity.isSelected ?
            design.selectedBackgroundColor :
            entity.isDisabled ?
                design.disabledBackgroundColor :
                design.defaultBackgroundColor
        layer.borderColor = entity.isCurrent ? design.selectedBackgroundColor.cgColor : UIColor.clear.cgColor
        alpha = entity.isDisabled ? 0.75 : 1
        configureShadow(radius: entity.isSelected ? 4 : 0, opacity: 0.25)
        badgeView.title = entity.tasksCount == 0 ? nil : "\(entity.tasksCount)"
        badgeView.isHidden = entity.tasksCount == 0
        badgeView.backgroundColor = design.badgeBackgroundColor
        badgeView.titleColor = design.badgeTintColor
        isUserInteractionEnabled = !entity.isDisabled
    }
    
    private func commonSetup() {
        clipsToBounds = false
        layer.cornerRadius = 6
        layer.borderWidth = 2
    }
    
    private func setupTitleLabel() {
        titleLabel.font = CalendarDayCell.titleFont
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
        
        [titleLabel.top(), titleLabel.bottom()].toSuperview()
        [titleLabel.leading(), titleLabel.trailing()].toSuperview()
    }
    
    private func setupBadgeView() {
        addSubview(badgeView)
        
        badgeView.height(18)
        badgeView.width(greatherOrEqual: 18)
        [badgeView.top(-9), badgeView.trailing(-9)].toSuperview()
    }
    
}
