//
//  TaskEditorViewProtocols.swift
//  Timmee
//
//  Created by i.kharabet on 14.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class CoreLocation.CLLocation
import class Foto.Photo

enum AudioNoteState {
    case notRecorded
    case recording
    case recorded
    case playing
}

protocol TaskEditorViewInput: class {
    func getTaskTitle() -> String
    func getTaskNote() -> String
    
    func setTaskTitle(_ title: String)
    func setTaskNote(_ note: String)
    func setAudioNoteState(_ state: AudioNoteState)
    func setTimeTemplate(_ timeTemplate: TimeTemplate?)
    func setDueDateTime(_ dueDate: String?, isOverdue: Bool)
    func setReminder(_ reminder: NotificationMask)
    func setRepeatEndingDate(_ repeatEndingDate: String?)
    func setRepeat(_ repeat: RepeatMask)
    func setLocation(_ location: String?)
    func setLocationReminderIsSelected(_ isSelected: Bool)
    func setTaskImportant(_ isImportant: Bool)
    func setAttachments(_ attachments: [String])
    
    func setTags(_ tags: [Tag])
    
    func setTopButtonsVisible(_ isVisible: Bool)
    func setCloseButtonVisible(_ isVisible: Bool)
}

// MARK: - TaskEditorView outputs

protocol TaskEditorViewOutput: TaskEditorViewTimeTemplateOutput, TaskEditorViewDueDateTimeOutput, TaskEditorViewReminderOutput, TaskEditorViewRepeatingOutput, TaskEditorViewRepeatEndingOutput, TaskEditorViewLocationOutput, TaskEditorViewTagsOutput, TaskEditorViewAttachmentsOutput, TaskEditorViewAudioNoteOutput {
    func viewDidAppear()
    func doneButtonPressed()
    func closeButtonPressed()
    
    func taskTitleChanged(to taskTitle: String)
    func taskNoteChanged(to taskNote: String)
    func taskImportantChanged(to isImportant: Bool)
    
    func willPresentTimeTemplatePicker(_ input: TaskTimeTemplatePickerInput)
    func willPresentDueDatePicker(_ input: TaskDueDatePickerInput)
    func willPresentDueDateTimeEditor(_ input: TaskDueDateTimeEditorInput)
    func willPresentReminderEditor(_ input: TaskReminderEditorInput)
    func willPresentRepeatingEditor(_ input: TaskRepeatingEditorInput)
    func willPresentRepeatEndingDateEditor(_ input: TaskDueDateTimeEditorInput)
    func willPresentLocationEditor(_ input: TaskLocationEditorInput)
    func willPresentIntervalRepeatingPicker(_ input: TaskIntervalRepeatingPickerInput)
    func willPresentWeeklyRepeatingPicker(_ input: TaskWeeklyRepeatingPickerInput)
    func willPresentTagsPicker(_ input: TaskTagsPickerInput)
    func willPresentAttachmentsPicker(_ input: TaskPhotoAttachmentsPickerInput)
}

protocol TaskEditorViewAudioNoteOutput: class {
    func audioNoteTouched()
    func audioNoteCleared()
}

protocol TaskEditorViewTimeTemplateOutput: class {
    func timeTemplateChanged(to timeTemplate: TimeTemplate?)
    func timeTemplateCleared()
}

protocol TaskEditorViewDueDateTimeOutput: class {
    func dueDateTimeChanged(to dueDate: Date?)
    func dueDateTimeCleared()
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

protocol TaskEditorViewTagsOutput: TaskTagsPickerOutput {
    func tagsCleared()
}

protocol TaskEditorViewAttachmentsOutput: class {
    func attachmentsChanged(to attachments: [Photo])
    func attachmentsCleared()
    func attachmentSelected(_ attachment: String)
    func attachmentRemoved(_ attachment: String)
}
