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

    @IBOutlet fileprivate var calendarView: CalendarView!
    
    weak var output: TaskDueDateEditorOutput?
    
    fileprivate var dueTimePicker: TaskDueTimePickerInput!
    
    var selectedDueDate: Date = Date() {
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
            self.updateSelectedDueDate(with: date)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DueTimePicker" {
            guard let dueTimePicker = segue.destination as? TaskDueTimePicker else { return }
            dueTimePicker.output = self
            self.dueTimePicker = dueTimePicker
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

}

extension TaskDueDateEditor: TaskDueDateEditorInput {

    func setDueDate(_ dueDate: Date?) {
        let date = dueDate ?? Date()
        
        dueTimePicker.setHours(date.hours)
        dueTimePicker.setMinutes(date.minutes)
        
        updateSelectedDueDate(with: date)
    }
    
    func setMinimumDate(_ date: Date?) {
        minimumAvailableDate = date ?? Date()
    }

}

extension TaskDueDateEditor: TaskDueTimePickerOutput {
    
    func didChangeHours(to hours: Int) {
        self.hours = hours
        selectedDueDate => hours.asHours
    }
    
    func didChangeMinutes(to minutes: Int) {
        self.minutes = minutes
        selectedDueDate => minutes.asMinutes
    }
    
}

extension TaskDueDateEditor: TaskParameterEditorInput {

    var requiredHeight: CGFloat {
        return 196
    }

}

fileprivate extension TaskDueDateEditor {
    
    func updateSelectedDueDate(with date: Date) {
        selectedDueDate = date
        selectedDueDate => hours.asHours
        selectedDueDate => minutes.asMinutes
    }

}
