//
//  TaskWeeklyRepeatingPicker.swift
//  Timmee
//
//  Created by Ilya Kharabet on 27.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskWeeklyRepeatingPickerInput: class {
    func setRepeatingMask(_ mask: RepeatMask)
}

protocol TaskWeeklyRepeatingPickerOutput: class {
    func didSelectDays(_ days: [Int])
    func didSelectWeekdays()
    func didSelectWeekends()
}

final class TaskWeeklyRepeatingPicker: UIViewController {
    
    weak var output: TaskWeeklyRepeatingPickerOutput?

    @IBOutlet fileprivate weak var weekDaysPicker: WeekDaysPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weekDaysPicker.output = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        weekDaysPicker.weekdaysButton.setTitleColor(AppTheme.current.blueColor.withAlphaComponent(0.5),
                                                    for: .normal)
        weekDaysPicker.weekendsButton.setTitleColor(AppTheme.current.redColor.withAlphaComponent(0.5),
                                                    for: .normal)
        weekDaysPicker.weekdaysButton.setTitleColor(AppTheme.current.blueColor,
                                                    for: .selected)
        weekDaysPicker.weekendsButton.setTitleColor(AppTheme.current.redColor,
                                                    for: .selected)
        weekDaysPicker.weekdaysButton.setTitleColor(AppTheme.current.blueColor,
                                                    for: .highlighted)
        weekDaysPicker.weekendsButton.setTitleColor(AppTheme.current.redColor,
                                                    for: .highlighted)
        weekDaysPicker.dayButtons.prefix(upTo: 5).forEach {
            $0.titleNormalColor = AppTheme.current.tintColor
            $0.titleSelectedColor = AppTheme.current.backgroundColor
            $0.backgroundNormalColor = AppTheme.current.panelColor
            $0.backgroundSelectedColor = AppTheme.current.blueColor
        }
        weekDaysPicker.dayButtons.suffix(2).forEach {
            $0.titleNormalColor = AppTheme.current.tintColor
            $0.titleSelectedColor = AppTheme.current.backgroundColor
            $0.backgroundNormalColor = AppTheme.current.panelColor
            $0.backgroundSelectedColor = AppTheme.current.redColor
        }
    }

}

extension TaskWeeklyRepeatingPicker: TaskWeeklyRepeatingPickerInput {

    func setRepeatingMask(_ mask: RepeatMask) {
        if case .on(let unit) = mask.type {
            switch unit {
            case .weekdays: weekDaysPicker.selectWeekdays()
            case .weekends: weekDaysPicker.selectWeekends()
            case .custom(let days):
                weekDaysPicker.selectDays(days.map { $0.number })
            }
        }
    }

}

extension TaskWeeklyRepeatingPicker: WeekDaysPickerOutput {

    func didSelectDays(_ days: [Int]) {
        output?.didSelectDays(days)
    }
    
    func didSelectWeekdays() {
        output?.didSelectWeekdays()
    }
    
    func didSelectWeekends() {
        output?.didSelectWeekends()
    }

}

extension TaskWeeklyRepeatingPicker: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return 96
    }
    
}
