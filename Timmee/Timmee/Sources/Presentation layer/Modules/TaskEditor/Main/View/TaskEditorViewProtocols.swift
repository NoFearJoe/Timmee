//
//  TaskEditorViewProtocols.swift
//  Timmee
//
//  Created by i.kharabet on 14.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class CoreLocation.CLLocation

protocol TaskEditorViewInput: class {
    func getTaskTitle() -> String
    func getTaskNote() -> String
    
    func setTaskTitle(_ title: String)
    func setTaskNote(_ note: String)
    func setDueDate(_ dueDate: String?)
    func setReminder(_ reminder: NotificationMask)
    func setRepeatEndingDate(_ repeatEndingDate: String?)
    func setRepeat(_ repeat: RepeatMask)
    func setLocation(_ location: String?)
    func setLocationReminderIsSelected(_ isSelected: Bool)
    func setTaskImportant(_ isImportant: Bool)
    
    func setTags(_ tags: [Tag])
    
    func setTopButtonsVisible(_ isVisible: Bool)
    func setCloseButtonVisible(_ isVisible: Bool)
}

// MARK: - TaskEditorView outputs

protocol TaskEditorViewOutput: class, TaskEditorViewDueDateOutput, TaskEditorViewReminderOutput, TaskEditorViewRepeatingOutput, TaskEditorViewRepeatEndingOutput, TaskEditorViewLocationOutput, TaskEditorViewTagsOutput {
    func viewDidAppear()
    func doneButtonPressed()
    func closeButtonPressed()
    
    func taskTitleChanged(to taskTitle: String)
    func taskNoteChanged(to taskNote: String)
    func taskImportantChanged(to isImportant: Bool)
    
    func willPresentDueDateEditor(_ input: TaskDueDateEditorInput)
    func willPresentReminderEditor(_ input: TaskReminderEditorInput)
    func willPresentRepeatingEditor(_ input: TaskRepeatingEditorInput)
    func willPresentRepeatEndingDateEditor(_ input: TaskDueDateEditorInput)
    func willPresentLocationEditor(_ input: TaskLocationEditorInput)
    func willPresentIntervalRepeatingPicker(_ input: TaskIntervalRepeatingPickerInput)
    func willPresentWeeklyRepeatingPicker(_ input: TaskWeeklyRepeatingPickerInput)
    func willPresentTagsPicker(_ input: TaskTagsPickerInput)
}

protocol TaskEditorViewDueDateOutput: class {
    func dueDateChanged(to dueDate: Date?)
    func dueDateCleared()
}

protocol TaskEditorViewReminderOutput: class {
    func reminderChanged(to reminder: NotificationMask)
    func reminderCleared()
}

protocol TaskEditorViewRepeatingOutput: class {
    func repeatChanged(to repeat: RepeatMask)
    func repeatCleared()
}

protocol TaskEditorViewRepeatEndingOutput: class {
    func repeatEndingDateChanged(to repeatEndingDate: Date?)
    func repeatEndingDateCleared()
}

protocol TaskEditorViewLocationOutput: class {
    func locationChanged(to location: CLLocation?)
    func locationReminderSelectionChanged(to isSelected: Bool)
    func locationCleared()
}

protocol TaskEditorViewTagsOutput: class, TaskTagsPickerOutput {
    func tagsCleared()
}
