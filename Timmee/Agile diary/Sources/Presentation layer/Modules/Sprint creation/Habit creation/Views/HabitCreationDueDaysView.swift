//
//  HabitCreationDueDaysView.swift
//  Agile diary
//
//  Created by Илья Харабет on 12/01/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class HabitCreationDueDaysView: UIView {
    
    var onSelectDay: ((DayUnit) -> Void)?
    
    var selectedDays: [DayUnit] {
        dayButtons
            .filter { $0.isSelected }
            .map { DayUnit(number: $0.tag) }
    }
    
    private let stackView = UIStackView()
    
    private var dayButtons: [SelectableButton] {
        (stackView.arrangedSubviews as! [SelectableButton])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stackView.arrangedSubviews.forEach {
            $0.layer.cornerRadius = stackView.bounds.height / 2
        }
    }
    
    func updateDayButtons(days: [DayUnit]) {
        dayButtons.forEach {
            $0.isSelected = days.map { $0.number }.contains($0.tag)
        }
    }
    
}

private extension HabitCreationDueDaysView {
    
    @objc func onTapDayButton(_ button: UIButton) {
        guard !button.isSelected || dayButtons.filter({ $0.isSelected }).count > 1 else { return }
        button.isSelected = !button.isSelected
        
        let dayNumber = button.tag
        let dayUnit = DayUnit(number: dayNumber)
        
        onSelectDay?(dayUnit)
    }
    
}

private extension HabitCreationDueDaysView {
    
    func setupViews() {
        addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        for day in 0...6 {
            let dayButton = SelectableButton(type: .custom)
            dayButton.tag = day
            dayButton.widthAnchor.constraint(equalTo: dayButton.heightAnchor, multiplier: 1).isActive = true
            dayButton.clipsToBounds = true
            dayButton.addTarget(self, action: #selector(onTapDayButton), for: .touchUpInside)
            dayButton.setTitle(DayUnit(number: day).localizedShort, for: .normal)
            dayButton.selectedBackgroundColor = day < 5 ? AppTheme.current.colors.mainElementColor : AppTheme.current.colors.wrongElementColor
            dayButton.defaultBackgroundColor = AppTheme.current.colors.decorationElementColor
            dayButton.tintColor = .clear
            dayButton.setTitleColor(AppTheme.current.colors.activeElementColor, for: .normal)
            dayButton.setTitleColor(UIColor.white, for: .selected)
            dayButton.setTitleColor(UIColor.white, for: .highlighted)
            dayButton.titleLabel?.font = AppTheme.current.fonts.regular(15)
            dayButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            stackView.addArrangedSubview(dayButton)
        }
    }
    
    func setupLayout() {
        [stackView.leading(), stackView.top(), stackView.bottom()].toSuperview()
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
    }
    
}
