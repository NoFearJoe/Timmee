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
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dayTimeSwitcher: Switcher!
    
    @IBAction private func onDayTimeSwitcherValueChanged() {
        guard let dayTime = Habit.DayTime.allCases.item(at: dayTimeSwitcher.selectedItemIndex) else { return }
        delegate?.dayTimePicker(self, didSelectDayTime: dayTime)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "day_time_picker_title".localized
        
        dayTimeSwitcher.items = DayTimePickerSubmodule.makeSwitcherItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.font = AppTheme.current.fonts.regular(16)
        titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
    func setDayTime(_ dayTime: Habit.DayTime) {
        dayTimeSwitcher.selectedItemIndex = Habit.DayTime.allCases.index(of: dayTime) ?? 0
    }
    
    private static func makeSwitcherItems() -> [SwitcherItem] {
        return Habit.DayTime.allCases.map {
            switch $0 {
            case .morning: return UIImage(imageLiteralResourceName: "day_time_morning")
            case .afternoon: return UIImage(imageLiteralResourceName: "day_time_afternoon")
            case .evening: return UIImage(imageLiteralResourceName: "day_time_evening")
            case .duringTheDay: return $0.localized
            }
        }
    }
    
}
