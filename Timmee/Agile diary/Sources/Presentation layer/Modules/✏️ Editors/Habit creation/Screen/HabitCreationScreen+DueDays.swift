//
//  HabitCreationScreen+DueDays.swift
//  Agile diary
//
//  Created by Илья Харабет on 29.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

extension HabitCreationViewController {
    
    func updateDayButtons() {
        let days = habit.dueDays
        
        weekdaysView.updateDayButtons(days: days)
    }
    
    func updateHabitRepeatingDays() {
        habit.dueDays = weekdaysView.selectedDays
    }
    
    func setupDueDaysSection(index: Int) {
        dueDaysContainer.configure(title: "due_days".localized, content: weekdaysView)
        dueDaysContainer.contentContainer.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        dueDaysContainer.setupAppearance()

        weekdaysView.height(32)
        weekdaysView.onSelectDay = { [unowned self] _ in
            self.updateHabitRepeatingDays()
        }
        
        stackViewController.setChild(dueDaysContainer, at: index)
        
        if editingMode == .short {
            dueDaysContainer.isHidden = true
        }
    }
    
}
