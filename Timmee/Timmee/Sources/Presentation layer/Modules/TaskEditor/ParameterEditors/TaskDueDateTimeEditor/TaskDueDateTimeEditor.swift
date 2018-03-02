//
//  TaskDueDateTimeEditor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskDueDateTimeEditorInput: class {
    func setDueDate(_ dueDate: Date?)
    func setMinimumDate(_ date: Date?)
}

protocol TaskDueDateTimeEditorOutput: class {
    func didSelectDueDate(_ dueDate: Date)
}

final class TaskDueDateTimeEditor: UIViewController {
    
    weak var output: TaskDueDateTimeEditorOutput?
    weak var container: TaskParameterEditorOutput?
    
    fileprivate var dueTimePicker: TaskDueTimePickerInput!
    fileprivate var dueDatePicker: TaskDueDatePickerInput!
    
    var selectedDueDate: Date = Date() {
        didSet {
            guard selectedDueDate != oldValue else { return }
            output?.didSelectDueDate(selectedDueDate)
        }
    }
    
    fileprivate var hours: Int = 0
    fileprivate var minutes: Int = 0
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DueTimePicker" {
            guard let dueTimePicker = segue.destination as? TaskDueTimePicker else { return }
            dueTimePicker.output = self
            self.dueTimePicker = dueTimePicker
        } else if segue.identifier == "DueDatePicker" {
            guard let dueDatePicker = segue.destination as? TaskDueDatePicker else { return }
            dueDatePicker.output = self
            self.dueDatePicker = dueDatePicker
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

}

extension TaskDueDateTimeEditor: TaskDueDateTimeEditorInput {

    func setDueDate(_ dueDate: Date?) {
        let date = dueDate ?? Date()
        
        dueTimePicker.setHours(date.hours)
        dueTimePicker.setMinutes(date.minutes)
        
        updateSelectedDueDate(with: date)
        
        dueDatePicker.setDueDate(date)
    }
    
    func setMinimumDate(_ date: Date?) {
        dueDatePicker.minimumAvailableDate = date ?? Date()
    }

}

extension TaskDueDateTimeEditor: TaskDueDatePickerOutput {
    
    func didChangeDueDate(to date: Date) {
        updateSelectedDueDate(with: date)
    }
    
}

extension TaskDueDateTimeEditor: TaskDueTimePickerOutput {
    
    func didChangeHours(to hours: Int) {
        self.hours = hours
        selectedDueDate => hours.asHours
    }
    
    func didChangeMinutes(to minutes: Int) {
        self.minutes = minutes
        selectedDueDate => minutes.asMinutes
    }
    
}

extension TaskDueDateTimeEditor: TaskParameterEditorInput {

    var requiredHeight: CGFloat {
        return 112 + 305
    }

}

fileprivate extension TaskDueDateTimeEditor {
    
    func updateSelectedDueDate(with date: Date) {
        selectedDueDate = date
        selectedDueDate => hours.asHours
        selectedDueDate => minutes.asMinutes
    }

}
