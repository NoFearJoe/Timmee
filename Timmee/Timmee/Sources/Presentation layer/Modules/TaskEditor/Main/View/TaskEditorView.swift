//
//  TaskEditorView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 03.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import class CoreLocation.CLLocation
import SwipeCellKit
import class Foto.Photo

final class TaskEditorView: UIViewController {

    @IBOutlet fileprivate var contentContainerView: BarView!
    @IBOutlet fileprivate var contentScrollView: UIScrollView!
    @IBOutlet fileprivate var contentView: UIView!
    
    @IBOutlet fileprivate var taskTitleField: GrowingTextView!
    @IBOutlet fileprivate var taskNoteField: GrowingTextView!
    
    @IBOutlet private var taskAudioNoteView: TaskComplexParameterView!
    
    @IBOutlet fileprivate var closeButton: UIButton!
    @IBOutlet fileprivate var doneButton: UIButton!
    
    @IBOutlet fileprivate var timeTemplateView: TaskComplexParameterView!
    @IBOutlet fileprivate var dueDateTimeView: TaskParameterView!
    @IBOutlet fileprivate var reminderView: TaskParameterView!
    @IBOutlet fileprivate var repeatView: TaskParameterView!
    @IBOutlet fileprivate var repeatEndingDateView: TaskParameterView!
    
//    @IBOutlet fileprivate var locationView: TaskParameterView!
//    @IBOutlet fileprivate var locationReminderView: TaskCheckableParameterView!
    
    @IBOutlet fileprivate var taskTagsView: TaskTagsView!
    
    @IBOutlet fileprivate var taskAttachmentsView: TaskAttachmentsParameterView!
    
    @IBOutlet fileprivate var taskImportancyPicker: TaskImportancyPicker!
    
    @IBOutlet fileprivate var subtasksContainer: UIView!
    @IBOutlet fileprivate var subtasksViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate var separators: [UIView]!
    
    var output: (TaskEditorViewOutput & SubtasksEditorTaskProvider)!
    var audioNoteOutput: TaskEditorViewAudioNoteOutput!
    
    private var shouldForceResignFirstResponder = false
    
    private var dueDateEditorHandler = TaskDueDateTimeEditorHandler()
    private var repeatEndingDateEditorHandler = TaskDueDateTimeEditorHandler()
    
    private weak var taskParameterEditorContainer: TaskParameterEditorContainer?
    
    private let transitionHandler = ModalPresentationTransitionHandler()
    
    @IBAction private func closeButtonPressed() {
        output.closeButtonPressed()
    }
    
    @IBAction private func doneButtonPressed() {
        output.doneButtonPressed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = transitionHandler
        
        setupTitleObserver()
        setupNoteObserver()
        
        taskTitleField.textView.delegate = self
        taskTitleField.textView.textContainerInset = UIEdgeInsets(top: 3.5, left: 0, bottom: 3.5, right: 0)
        taskTitleField.textView.font = UIFont.systemFont(ofSize: 24)
        taskTitleField.maxNumberOfLines = 3
        taskTitleField.showsVerticalScrollIndicator = false
        taskTitleField.placeholderAttributedText
            = NSAttributedString(string: "input_task_title".localized,
                                 attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24),
                                              NSAttributedStringKey.foregroundColor: AppTheme.current.secondaryTintColor])
        
        taskNoteField.textView.delegate = self
        taskNoteField.textView.textContainerInset = .zero
        taskNoteField.textView.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)
        taskNoteField.maxNumberOfLines = 5
        taskNoteField.showsVerticalScrollIndicator = false
        taskNoteField.placeholderAttributedText
            = NSAttributedString(string: "task_note".localized,
                                 attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16,
                                                                                     weight: UIFont.Weight.light),
                                              NSAttributedStringKey.foregroundColor: AppTheme.current.secondaryTintColor])
        
        taskAudioNoteView.didClear = { [unowned self] in
            self.audioNoteOutput.audioNoteCleared()
        }
        taskAudioNoteView.didTouchedUp = { [unowned self] in
            self.audioNoteOutput.audioNoteTouched()
        }
        
        timeTemplateView.didChangeFilledState = { [unowned self] isFilled in
            if isFilled {
                self.reminderView.isHidden = true
                self.repeatView.isHidden = false
                self.dueDateTimeView.canClear = false
            } else {
                self.reminderView.isHidden = !self.dueDateTimeView.isFilled
                self.repeatView.isHidden = !self.dueDateTimeView.isFilled
                self.dueDateTimeView.canClear = true
            }
        }
        timeTemplateView.didClear = { [unowned self] in
            self.output.timeTemplateCleared()
        }
        timeTemplateView.didTouchedUp = { [unowned self] in
            self.showTaskParameterEditor(with: .timeTemplates)
        }
        
        dueDateTimeView.didChangeFilledState = { [unowned self] isFilled in
            self.reminderView.isHidden = !isFilled || self.timeTemplateView.isFilled
            self.repeatView.isHidden = !isFilled && !self.timeTemplateView.isFilled
            self.repeatEndingDateView.isHidden = !isFilled || !self.repeatView.isFilled
        }
        dueDateTimeView.didClear = { [unowned self] in
            self.output.dueDateTimeCleared()
        }
        dueDateTimeView.didTouchedUp = { [unowned self] in
            if self.timeTemplateView.isFilled {
                self.showTaskParameterEditor(with: .dueDate)
            } else {
                self.showTaskParameterEditor(with: .dueDateTime)
            }
        }
        
        reminderView.didClear = { [unowned self] in
            self.output.notificationCleared()
        }
        reminderView.didTouchedUp = { [unowned self] in
            self.showTaskParameterEditor(with: .reminder)
        }
        
        repeatView.didChangeFilledState = { [unowned self] isFilled in
            self.repeatEndingDateView.isHidden = !isFilled
        }
        repeatView.didClear = { [unowned self] in
            self.output.repeatCleared()
        }
        repeatView.didTouchedUp = { [unowned self] in
            self.showTaskParameterEditor(with: .repeating)
        }
        
        repeatEndingDateView.didClear = { [unowned self] in
            self.output.repeatEndingDateCleared()
        }
        repeatEndingDateView.didTouchedUp = { [unowned self] in
            self.showTaskParameterEditor(with: .repeatEndingDate)
        }
        
//        locationView.didChangeFilledState = { [unowned self] isFilled in
//            self.locationReminderView.isHidden = !isFilled
//        }
//        locationView.didClear = { [unowned self] in
//            self.output.locationCleared()
//        }
//        locationView.didTouchedUp = { [unowned self] in
//            self.showLocationEditor()
//        }
        
//        locationReminderView.didChangeCkeckedState = { [unowned self] isChecked in
//            self.output.locationReminderSelectionChanged(to: isChecked)
//        }

        taskTagsView.didTouchedUp = { [unowned self] in
            self.showTaskParameterEditor(with: .tags)
        }
        
        taskImportancyPicker.onPick = { [unowned self] isImportant in
            self.output.taskImportantChanged(to: isImportant)
        }
        
        
        taskAttachmentsView.didTouchedUp = { [unowned self] in
            self.showTaskParameterEditor(with: .attachments)
        }
        taskAttachmentsView.didClear = { [unowned self] in
            self.output.attachmentsCleared()
        }
        taskAttachmentsView.didRemoveAttachment = { [unowned self] attachment in
            self.output.attachmentRemoved(attachment)
        }
        taskAttachmentsView.didSelectAttachment = { [unowned self] attachment in
            self.output.attachmentSelected(attachment)
        }
        
        
        dueDateEditorHandler.onDateChange = { [unowned self] date in
            self.output.dueDateTimeChanged(to: date)
        }
        
        repeatEndingDateEditorHandler.onDateChange = { [unowned self] date in
            self.output.repeatEndingDateChanged(to: date)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.backgroundColor
        
        contentContainerView.backgroundColor = AppTheme.current.foregroundColor
        closeButton.tintColor = AppTheme.current.backgroundTintColor
        doneButton.tintColor = AppTheme.current.greenColor
        
        taskTitleField.textView.textColor = AppTheme.current.specialColor
        taskTitleField.tintColor = AppTheme.current.tintColor
        taskNoteField.textView.textColor = AppTheme.current.tintColor
        taskNoteField.tintColor = AppTheme.current.tintColor
        
        if taskTitleField.textView.text.isEmpty {
            taskTitleField.becomeFirstResponder()
        }
        
        taskTitleField.disableAutomaticScrollToBottom = true
        taskNoteField.disableAutomaticScrollToBottom = true
        
        output.viewDidAppear()
        
        taskTitleField.updateMinimumAndMaximumHeight()
        taskNoteField.updateMinimumAndMaximumHeight()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        shouldForceResignFirstResponder = true
        view.endEditing(true)
        shouldForceResignFirstResponder = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SubtasksEditor", let subtasksEditor = segue.destination as? SubtasksEditor {
            subtasksEditor.taskProvider = output
            subtasksEditor.contentScrollView = contentScrollView
            subtasksEditor.containerViewHeightConstraint = subtasksViewHeightConstraint
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

}

extension TaskEditorView: TaskEditorViewInput {
    
    func getTaskTitle() -> String {
        return taskTitleField.textView.text.trimmed
    }
    
    func getTaskNote() -> String {
        return taskNoteField.textView.text.trimmed
    }

    func setTaskTitle(_ title: String) {
        taskTitleField.textView.text = title
        setInterfaceEnabled(!title.trimmed.isEmpty)
    }
    
    func setTaskNote(_ note: String) {
        taskNoteField.textView.text = note
    }
    
    func setTimeTemplate(_ timeTemplate: TimeTemplate?) {
        timeTemplateView.text = timeTemplate?.title ?? "time_template_placeholder".localized
        
        if let timeTemplate = timeTemplate, let time = timeTemplate.time {
            let minutes: String
            if time.minutes < 10 {
                minutes = "\(time.minutes)0"
            } else {
                minutes = "\(time.minutes)"
            }
            timeTemplateView.subtitle = "\(time.hours):\(minutes), " + timeTemplate.notification.title
        } else {
            timeTemplateView.subtitle = nil
        }
        
        timeTemplateView.isFilled = timeTemplate != nil
    }
    
    func setDueDateTime(_ dueDate: String?, isOverdue: Bool) {
        dueDateTimeView.text = dueDate ?? "due_date".localized
        dueDateTimeView.filledTitleColor = isOverdue ? AppTheme.current.redColor : AppTheme.current.tintColor
        dueDateTimeView.updateTitleColor()
        dueDateTimeView.isFilled = dueDate != nil
    }
    
    func setNotification(_ notification: TaskReminderSelectedNotification) {
        switch notification {
        case let .mask(notificationMask):
            reminderView.text = notificationMask.title
            reminderView.isFilled = notificationMask != .doNotNotify
        case let .date(notificationDate):
            reminderView.text = notificationDate.asNearestDateString
            reminderView.isFilled = true
        }
    }
    
    func setRepeat(_ repeat: RepeatMask) {
        if `repeat`.type.isNever {
            repeatView.text = `repeat`.localized.capitalizedFirst
        } else if case .on(let unit) = `repeat`.type, !unit.isEveryday {
            repeatView.text = "repeat".localized.capitalizedFirst + " " + "at".localized + " " + `repeat`.localized.lowercased()
        } else {
            repeatView.text = "repeat".localized.capitalizedFirst + " " + `repeat`.localized.lowercased()
        }
        
        repeatView.isFilled = !`repeat`.type.isNever
    }
    
    func setRepeatEndingDate(_ repeatEndingDate: String?) {
        repeatEndingDateView.text = repeatEndingDate ?? "repeat_ending_date".localized
        
        repeatEndingDateView.isFilled = repeatEndingDate != nil
    }
    
    func setLocation(_ location: String?) {
//        locationView.text = location ?? "location".localized
        
//        locationView.isFilled = location != nil
    }
    
    func setLocationReminderIsSelected(_ isSelected: Bool) {
//        locationReminderView.isChecked = isSelected
    }
    
    func setTaskImportant(_ isImportant: Bool) {
        taskImportancyPicker.isPicked = isImportant
    }

    func setTags(_ tags: [Tag]) {
        taskTagsView.tags = tags
        
        taskTagsView.isFilled = !tags.isEmpty
    }
    
    func setAttachments(_ attachments: [String]) {
        taskAttachmentsView.setAttachments(attachments)
        
        taskAttachmentsView.isFilled = !attachments.isEmpty
    }
    
    
    func setTopButtonsVisible(_ isVisible: Bool) {
        UIView.animate(withDuration: 0.35) {
            self.closeButton.isHidden = !isVisible
            self.doneButton.isHidden = !isVisible
        }
    }
    
    func setCloseButtonVisible(_ isVisible: Bool) {
        self.closeButton.isHidden = !isVisible
        self.closeButton.alpha = isVisible ? 1 : 0
        self.closeButton.isEnabled = isVisible
    }
    
}

extension TaskEditorView: TaskEditorAudioNoteViewInput {
    
    func setAudioNoteState(_ state: AudioNoteState) {
        switch state {
        case .notRecorded:
            taskAudioNoteView.isFilled = false
            taskAudioNoteView.text = "record_audio_note_placeholder".localized
            taskAudioNoteView.subtitle = nil
        case .recording:
            taskAudioNoteView.isFilled = true
            taskAudioNoteView.text = "recording_audio_note_placeholder".localized
            taskAudioNoteView.subtitle = "touch_to_stop".localized
        case .recorded:
            taskAudioNoteView.isFilled = true
            taskAudioNoteView.text = "play_audio_note_placeholder".localized
            taskAudioNoteView.subtitle = nil
        case .playing:
            taskAudioNoteView.isFilled = true
            taskAudioNoteView.text = "playing_audio_note_placeholder".localized
            taskAudioNoteView.subtitle = "touch_to_stop".localized
        }
    }
    
}

extension TaskEditorView: TaskParameterEditorContainerOutput {
    
    func taskParameterEditingCancelled(type: TaskParameterEditorType) {
        switch type {
        case .dueDateTime: output?.dueDateTimeCleared()
        case .reminder: output?.notificationCleared()
        case .repeating: output?.repeatCleared()
        case .repeatEndingDate: output?.repeatEndingDateCleared()
        case .location:
            setTopButtonsVisible(true)
            output?.locationCleared()
        case .tags: output?.tagsCleared()
        case .timeTemplates: output?.timeTemplateCleared()
        case .audioNote: audioNoteOutput?.audioNoteCleared()
        case .dueDate: return
        case .dueTime: return
        case .attachments: return//output?.attachmentsCleared()
        }
    }

    func taskParameterEditingFinished(type: TaskParameterEditorType) {
        if case .location = type {
            setTopButtonsVisible(true)
        }
    }

    func editorViewController(forType type: TaskParameterEditorType) -> UIViewController {
        switch type {
        case .dueDateTime:
            let viewController = ViewControllersFactory.taskDueDateTimeEditor
            viewController.loadViewIfNeeded()
            viewController.output = dueDateEditorHandler
            output.willPresentDueDateTimeEditor(viewController)
            return viewController
        case .dueDate:
            let viewController = ViewControllersFactory.taskDueDatePicker
            viewController.loadViewIfNeeded()
            viewController.output = self
            viewController.canClear = false
            output.willPresentDueDatePicker(viewController)
            return viewController
        case .reminder:
            let viewController = ViewControllersFactory.taskReminderEditor
            viewController.output = self
            viewController.transitionOutput = taskParameterEditorContainer
            output.willPresentReminderEditor(viewController)
            return viewController
        case .repeating:
            let viewController = ViewControllersFactory.taskRepeatingEditor
            viewController.output = self
            viewController.transitionOutput = taskParameterEditorContainer
            output.willPresentRepeatingEditor(viewController)
            return viewController
        case .repeatEndingDate:
            let viewController = ViewControllersFactory.taskDueDateTimeEditor
            viewController.loadViewIfNeeded()
            viewController.output = repeatEndingDateEditorHandler
            output.willPresentRepeatEndingDateEditor(viewController)
            return viewController
        case .location:
            let viewController = ViewControllersFactory.taskLocationEditor
            viewController.loadViewIfNeeded()
            viewController.output = self
            output.willPresentLocationEditor(viewController)
            return viewController
        case .tags:
            let viewController = ViewControllersFactory.taskTagsPicker
            viewController.loadViewIfNeeded()
            viewController.output = output
            output.willPresentTagsPicker(viewController)
            return viewController
        case .timeTemplates:
            let viewController = ViewControllersFactory.taskTimeTemplatePicker
            viewController.loadViewIfNeeded()
            viewController.output = self
            viewController.transitionOutput = taskParameterEditorContainer
            output.willPresentTimeTemplatePicker(viewController)
            return viewController
        case .attachments:
            let viewController = ViewControllersFactory.taskPhotoAttachmentsPicker
            viewController.loadViewIfNeeded()
            viewController.output = self
            output.willPresentAttachmentsPicker(viewController)
            return viewController
        case .audioNote, .dueTime:
            return UIViewController()
        }
    }
    
    func repeatingPickerViewController(forType type: TaskRepeatingPickerType) -> UIViewController {
        switch type {
        case .interval:
            let viewController = ViewControllersFactory.taskIntervalRepeatingPicker
            viewController.loadViewIfNeeded()
            output.willPresentIntervalRepeatingPicker(viewController)
            return viewController
        case .weekly:
            let viewController = ViewControllersFactory.taskWeeklyRepeatingPicker
            viewController.loadViewIfNeeded()
            output.willPresentWeeklyRepeatingPicker(viewController)
            return viewController
        }
    }

}

final class TaskDueDateTimeEditorHandler: TaskDueDateTimeEditorOutput {

    var onDateChange: ((Date) -> Void)?
    
    func didSelectDueDate(_ dueDate: Date) {
        onDateChange?(dueDate)
    }

}

extension TaskEditorView: TaskTimeTemplatePickerOutput {
    
    func timeTemplateChanged(to timeTemplate: TimeTemplate?) {
        output.timeTemplateChanged(to: timeTemplate)
    }
    
}

extension TaskEditorView: TaskDueDatePickerOutput {
    
    func didChangeDueDate(to date: Date) {
        output.dueDateTimeChanged(to: date)
    }
    
}

extension TaskEditorView: TaskReminderEditorOutput {
    
    func didSelectNotification(_ notification: TaskReminderSelectedNotification) {
        output.notificationChanged(to: notification)
    }

}

extension TaskEditorView: TaskRepeatingEditorOutput {

    func didSelectRepeatMask(_ repeatMask: RepeatMask) {
        output.repeatChanged(to: repeatMask)
    }

}

extension TaskEditorView: TaskLocationEditorOutput {

    func didSelectLocation(_ location: CLLocation) {
        output.locationChanged(to: location)
    }

}

extension TaskEditorView: TaskPhotoAttachmentsPickerOutput {
    
    func didSelectPhotos(_ photos: [Photo]) {
        output.attachmentsChanged(to: photos)
    }
    
    func maxSelectedPhotosCountReached() {
        // TODO: Show alert panel
    }
    
}

extension TaskEditorView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === taskTitleField.textView {
            taskTitleField.setContentOffset(.zero, animated: true)
        } else if textView === taskNoteField.textView {
            taskNoteField.setContentOffset(.zero, animated: true)
        }
    }
    
}

fileprivate extension TaskEditorView {
    
    func setupTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(taskTitleDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: taskTitleField.textView)
    }
    
    func setupNoteObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(taskNoteDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: taskNoteField.textView)
    }
    
    @objc func taskTitleDidChange(notification: Notification) {
        let text = getTaskTitle()
        
        output.taskTitleChanged(to: text)
        
        setInterfaceEnabled(!text.trimmed.isEmpty)
    }
    
    @objc func taskNoteDidChange(notification: Notification) {
        output.taskNoteChanged(to: getTaskNote())
    }
    
    func setInterfaceEnabled(_ isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
        
        separators.forEach { separator in
            UIView.animate(withDuration: 0.2, animations: {
                separator.isHidden = !isEnabled
            })
        }
        let viewsToHide: [UIView] = [taskNoteField, dueDateTimeView,
                                     reminderView, repeatView,
                                     /*locationView, locationReminderView,*/
                                     taskImportancyPicker, timeTemplateView,
                                     subtasksContainer, taskTagsView,
                                     taskAttachmentsView, taskAudioNoteView]
        viewsToHide.forEach { view in
            UIView.animate(withDuration: 0.2, animations: { 
                view.isUserInteractionEnabled = isEnabled
                view.alpha = isEnabled ? 1 : 0
            })
        }
    }
    
}

fileprivate extension TaskEditorView {
    
    func showLocationEditor() {
        showTaskParameterEditor(with: .location)
        setTopButtonsVisible(false)
    }
    
    func showTaskParameterEditor(with type: TaskParameterEditorType) {
        let taskParameterEditorContainer = ViewControllersFactory.taskParameterEditorContainer
        taskParameterEditorContainer.loadViewIfNeeded()
        
        self.taskParameterEditorContainer = taskParameterEditorContainer
        
        taskParameterEditorContainer.output = self
        taskParameterEditorContainer.setType(type)
        
        present(taskParameterEditorContainer,
                animated: true,
                completion: nil)
    }

}
