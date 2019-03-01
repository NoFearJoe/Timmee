//
//  DayTimePickerSubmodule.swift
//  Agile diary
//
//  Created by i.kharabet on 01.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

protocol DayTimePickerSubmoduleDelegate: AnyObject {
    func dayTimePicker(_ picker: DayTimePickerSubmodule, didSelectDayTime dayTime: Habit.DayTime)
}

final class DayTimePickerSubmodule: UIViewController {
    
    weak var delegate: DayTimePickerSubmoduleDelegate?
    
    @IBOutlet private var dayTimeSwitcher: Switcher!
    
    @IBAction private func onDayTimeSwitcherValueChanged() {
        guard let dayTime = Habit.DayTime.allCases.item(at: dayTimeSwitcher.selectedItemIndex) else { return }
        delegate?.dayTimePicker(self, didSelectDayTime: dayTime)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayTimeSwitcher.items = Habit.DayTime.allCases.map { $0.localized }
        dayTimeSwitcher.selectedItemIndex = 3
    }
    
    func setDayTime(_ dayTime: Habit.DayTime) {
        dayTimeSwitcher.selectedItemIndex = Habit.DayTime.allCases.index(of: dayTime) ?? 0
    }
    
}
