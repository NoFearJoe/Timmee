//
//  WeekDaysPicker.swift
//  Test
//
//  Created by i.kharabet on 21.08.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

protocol WeekDaysPickerOutput: class {
    func didSelectDays(_ days: [Int])
    func didSelectWeekdays()
    func didSelectWeekends()
}

final class WeekDaysPicker: UIView {

    weak var output: WeekDaysPickerOutput?
    
    var selectedDays: Set<Int> {
        return Set(dayButtons.filter({ $0.isSelected }).map({ $0.dayNumber }))
    }
    
    var isWeekdaysSelected: Bool {
        return selectedDays.isSuperset(of: [0, 1, 2, 3, 4])
    }
    
    var isWeekendsSelected: Bool {
        return selectedDays.isSuperset(of: [5, 6])
    }
    
    @IBOutlet weak var weekdaysButton: WeekDaysButton! {
        didSet {
            weekdaysButton.setTitle("weekdays".localized, for: .normal)
        }
    }
    @IBOutlet weak var weekendsButton: WeekDaysButton! {
        didSet {
            weekendsButton.setTitle("weekends".localized, for: .normal)
        }
    }
    @IBOutlet var dayButtons: [DayButton]! {
        didSet {
            dayButtons.forEach { button in
                let day = DayUnit(number: button.dayNumber).localizedShort
                button.setTitle(day.uppercased(), for: .normal)
            }
        }
    }
    
    @IBAction func didSelectWeekdays() {
        isWeekdaysSelected ? deselectWeekdays() : selectWeekdays()
        updateWeekdaysButton()
        handleSelectedDays()
    }
    
    @IBAction func didSelectWeeends() {
        isWeekendsSelected ? deselectWeekends() : selectWeekends()
        updateWeekendsButton()
        handleSelectedDays()
    }
    
    @IBAction func didSelectDay(_ button: DayButton) {
        button.isSelected = !button.isSelected
        
        updateWeekdaysButton()
        updateWeekendsButton()
        
        handleSelectedDays()
    }
    
    func selectWeekdays() {
        selectDays(0...4)
    }
    
    func deselectWeekdays() {
        deselectDays(0...4)
    }
    
    func selectWeekends() {
        selectDays(5...6)
    }
    
    func deselectWeekends() {
        deselectDays(5...6)
    }
    
    func selectDays(_ days: [Int]) {
        dayButtons.filter({ days.contains($0.dayNumber) }).forEach({ $0.isSelected = true })
    }
    
    func deselectDays(_ days: [Int]) {
        dayButtons.filter({ days.contains($0.dayNumber) }).forEach({ $0.isSelected = false })
    }
    
    func selectDays(_ range: CountableClosedRange<Int>) {
        dayButtons.filter({ range.contains($0.dayNumber) }).forEach({ $0.isSelected = true })
    }
    
    func deselectDays(_ range: CountableClosedRange<Int>) {
        dayButtons.filter({ range.contains($0.dayNumber) }).forEach({ $0.isSelected = false })
    }
    
    func updateWeekdaysButton() {
        weekdaysButton.isSelected = isWeekdaysSelected
    }
    
    func updateWeekendsButton() {
        weekendsButton.isSelected = isWeekendsSelected
    }
    
    fileprivate func handleSelectedDays() {
        if isWeekdaysSelected && selectedDays.count == 5 {
            output?.didSelectWeekdays()
        } else if isWeekendsSelected && selectedDays.count == 2 {
            output?.didSelectWeekends()
        } else {
            output?.didSelectDays(Array(selectedDays))
        }
    }

}

final class DayButton: UIButton {

    @IBInspectable var titleNormalColor: UIColor = .black {
        didSet {
            updateTitleColors(normalColor: titleNormalColor,
                              selectedColor: titleSelectedColor)
        }
    }
    @IBInspectable var titleSelectedColor: UIColor = .white {
        didSet {
            updateTitleColors(normalColor: titleNormalColor,
                              selectedColor: titleSelectedColor)
        }
    }
    @IBInspectable var backgroundNormalColor: UIColor = .white { didSet { updateBackgroundColor() } }
    @IBInspectable var backgroundSelectedColor: UIColor = .black { didSet { updateBackgroundColor() } }
    
    @IBInspectable var dayNumber: Int = 0
    
    override var isHighlighted: Bool {
        didSet { updateBackgroundColor() }
    }
    
    override var isSelected: Bool {
        didSet { updateBackgroundColor() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureTitleLabel()
    }
    
    func configureTitleLabel() {
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.lineBreakMode = .byClipping
        titleLabel?.baselineAdjustment = .alignCenters
    }
    
    func updateTitleColors(normalColor: UIColor, selectedColor: UIColor) {
        setTitleColor(normalColor, for: .normal)
        setTitleColor(selectedColor, for: .selected)
        setTitleColor(selectedColor, for: .highlighted)
        
        setNeedsDisplay()
    }
    
    func updateBackgroundColor() {
        backgroundColor = (isHighlighted || isSelected) ?
            backgroundSelectedColor : backgroundNormalColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width * 0.5
    }

}

final class WeekDaysButton: UIButton {
    
}
