//
//  TaskDueDateEditor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskDueDateEditorInput: class {
    func setDueDate(_ dueDate: Date?)
    func setMinimumDate(_ date: Date?)
}

protocol TaskDueDateEditorOutput: class {
    func didSelectDueDate(_ dueDate: Date)
}

final class TaskDueDateEditor: UIViewController {

    @IBOutlet fileprivate weak var calendarView: CalendarView!
    @IBOutlet fileprivate weak var hourPicker: NumberPicker!
    @IBOutlet fileprivate weak var minutePicker: NumberPicker!
    @IBOutlet fileprivate weak var hourHintLabel: UILabel!
    @IBOutlet fileprivate weak var minuteHintLabel: UILabel!

    @IBOutlet fileprivate var timeSeparators: [UIView]!
    
    weak var output: TaskDueDateEditorOutput?
    
    var selectedDueDate: Date! {
        didSet {
            if selectedDueDate != oldValue {
                calendarView.selectedDateIndex = calendar.index(of: selectedDueDate)
                calendarView.calendarView.reloadData()
                
                output?.didSelectDueDate(selectedDueDate)
            }
        }
    }
    
    var minimumAvailableDate: Date = Date() {
        didSet {
            calendar.changeStartDate(to: minimumAvailableDate)
            calendarView.calendar = (calendar.dataSource(), calendar.monthDataSource())
            calendarView.calendarView.reloadData()
        }
    }
    
    fileprivate var hours: Int = 0
    fileprivate var minutes: Int = 0
    
    fileprivate let calendar = Calendar(start: Date(), shift: -1, daysCount: 357)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.calendar = (calendar.dataSource(), calendar.monthDataSource())
        calendarView.didSelectItemAtIndex = { [unowned self] index in
            let date = self.calendar.date(by: index)
            self.selectedDueDate = self.date(date, withHours: self.hours, minutes: self.minutes)
        }
        
        hourPicker.shouldAddZero = false
        hourPicker.numbers = (0...23).map { $0 }
        hourPicker.didChangeNumber = { [unowned self] hour in
            self.hours = hour
            self.selectedDueDate = self.date(self.selectedDueDate, withHours: self.hours, minutes: self.minutes)
        }
        
        minutePicker.numbers = (0...55).map { $0 }.filter { $0 % 5 == 0 }
        minutePicker.didChangeNumber = { [unowned self] minute in
            self.minutes = self.roundMinute(minute)
            self.selectedDueDate = self.date(self.selectedDueDate, withHours: self.hours, minutes: self.minutes)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hourHintLabel.text = "hours".localized
        minuteHintLabel.text = "minutes".localized
        
        hourHintLabel.textColor = AppTheme.current.secondaryTintColor
        minuteHintLabel.textColor = AppTheme.current.secondaryTintColor
        
        timeSeparators.forEach { view in
            view.backgroundColor = AppTheme.current.tintColor
        }
    }

}

extension TaskDueDateEditor: TaskDueDateEditorInput {

    func setDueDate(_ dueDate: Date?) {
        let date = dueDate ?? Date()
        
        hours = date.hours
        minutes = roundMinute(date.minutes)
        
        selectedDueDate = self.date(date, withHours: hours, minutes: minutes)
        
        hourPicker.scrollToNumber(hours)
        minutePicker.scrollToNumber(minutes)
    }
    
    func setMinimumDate(_ date: Date?) {
        minimumAvailableDate = date ?? Date()
    }

}

extension TaskDueDateEditor: TaskParameterEditorInput {

    var requiredHeight: CGFloat {
        return 196
    }

}

fileprivate extension TaskDueDateEditor {

    func roundMinute(_ minute: Int) -> Int {
        let reminder = Double(minute).truncatingRemainder(dividingBy: 5)
        
        var roundedMinute: Int
        if reminder < 3 {
            roundedMinute = minute - Int(reminder)
        } else {
            roundedMinute = minute - Int(reminder) + 5
        }
        
        // Rounded minute should be greather than minute
        if roundedMinute < minute {
            roundedMinute += 5
        }
        
        return min(60, max(0, roundedMinute))
    }
    
    func date(_ date: Date, withHours hours: Int, minutes: Int) -> Date {
        return date.startOfDay + hours.asHours + minutes.asMinutes
    }

}
