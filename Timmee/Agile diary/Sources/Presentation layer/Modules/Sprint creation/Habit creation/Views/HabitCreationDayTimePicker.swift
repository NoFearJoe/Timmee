//
//  HabitCreationDayTimePicker.swift
//  Agile diary
//
//  Created by Илья Харабет on 11/01/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class HabitCreationDayTimePicker: UIView {
    
    var onSelectDayTime: ((Habit.DayTime) -> Void)?
    
    private let dayTimeSwitcher = Switcher()
    
    @objc private func onDayTimeSwitcherValueChanged() {
        guard let dayTime = Habit.DayTime.allCases.item(at: dayTimeSwitcher.selectedItemIndex) else { return }
        onSelectDayTime?(dayTime)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dayTimeSwitcher)
        
        dayTimeSwitcher.height(28)
        dayTimeSwitcher.allEdges().toSuperview()
                
        dayTimeSwitcher.items = Self.makeSwitcherItems()
        
        dayTimeSwitcher.addTarget(self, action: #selector(onDayTimeSwitcherValueChanged), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
