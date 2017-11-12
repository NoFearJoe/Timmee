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
    
    func reloadSubtasks()
    func batchReloadSubtask(insertions: [Int], deletions: [Int], updates: [Int])
    
    func setTags(_ tags: [Tag])
    
    func setTopButtonsVisible(_ isVisible: Bool)
    func setCloseButtonVisible(_ isVisible: Bool)
}

protocol TaskEditorViewOutput: class {
    func viewDidAppear()
    func doneButtonPressed()
    func closeButtonPressed()

    func taskTitleChanged(to taskTitle: String)
    func taskNoteChanged(to taskNote: String)
    func dueDateChanged(to dueDate: Date?)
    func reminderChanged(to reminder: NotificationMask)
    func repeatChanged(to repeat: RepeatMask)
    func repeatEndingDateChanged(to repeatEndingDate: Date?)
    func locationChanged(to location: CLLocation?)
    func locationReminderSelectionChanged(to isSelected: Bool)
    func taskImportantChanged(to isImportant: Bool)
    
    func addSubtask(with title: String)
    func updateSubtask(at index: Int, newTitle: String)
    func removeSubtask(at index: Int)
    func exchangeSubtasks(at indexes: (Int, Int))
    func doneSubtask(at index: Int)
    
    func tagSelected(_ tag: Tag)
    func tagDeselected(_ tag: Tag)
    func tagRemoved(_ tag: Tag)
    func tagUpdated(_ tag: Tag)
    
    func dueDateCleared()
    func reminderCleared()
    func repeatCleared()
    func repeatEndingDateCleared()
    func locationCleared()
    func tagsCleared()
    
    func willPresentDueDateEditor(_ input: TaskDueDateEditorInput)
    func willPresentReminderEditor(_ input: TaskReminderEditorInput)
    func willPresentRepeatingEditor(_ input: TaskRepeatingEditorInput)
    func willPresentRepeatEndingDateEditor(_ input: TaskDueDateEditorInput)
    func willPresentLocationEditor(_ input: TaskLocationEditorInput)
    func willPresentIntervalRepeatingPicker(_ input: TaskIntervalRepeatingPickerInput)
    func willPresentWeeklyRepeatingPicker(_ input: TaskWeeklyRepeatingPickerInput)
    func willPresentTagsPicker(_ input: TaskTagsPickerInput)
}

protocol TaskEditorSubtasksDataSource: class {
    func subtasksCount() -> Int
    func subtask(at index: Int) -> Subtask?
}

final class TaskEditorView: UIViewController {

    @IBOutlet fileprivate var contentContainerView: BarView!
    @IBOutlet fileprivate var contentScrollView: UIScrollView!
    @IBOutlet fileprivate var contentView: UIView!
    
    @IBOutlet fileprivate var taskTitleField: GrowingTextView!
    @IBOutlet fileprivate var taskNoteField: GrowingTextView!
    
    @IBOutlet fileprivate var closeButton: UIButton!
    @IBOutlet fileprivate var doneButton: UIButton!
    
    @IBOutlet fileprivate var dueDateView: TaskParameterView!
    @IBOutlet fileprivate var reminderView: TaskParameterView!
    @IBOutlet fileprivate var repeatView: TaskParameterView!
    @IBOutlet fileprivate var repeatEndingDateView: TaskParameterView!
    
    @IBOutlet fileprivate var locationView: TaskParameterView!
    @IBOutlet fileprivate var locationReminderView: TaskCheckableParameterView!
    
    @IBOutlet fileprivate var taskTagsView: TaskTagsView!
    
    @IBOutlet fileprivate var taskImportancyPicker: TaskImportancyPicker!
    
    @IBOutlet fileprivate var addSubtaskView: AddSubtaskView!
    @IBOutlet fileprivate var subtasksView: ReorderableTableView!
    @IBOutlet fileprivate var subtasksViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate var separators: [UIView]!
    
    var output: TaskEditorViewOutput!
    weak var dataSource: TaskEditorSubtasksDataSource?
    
    fileprivate var shouldForceResignFirstResponder = false
    
    fileprivate var dueDateEditorHandler = TaskDueDateEditorHandler()
    fileprivate var repeatEndingDateEditorHandler = TaskDueDateEditorHandler()
    
    fileprivate weak var taskParameterEditorContainer: TaskParameterEditorContainer?
    
    fileprivate let keyboardManager = KeyboardManager()
    
    fileprivate let subtaskCellActionsProvider = SubtaskCellActionsProvider()
    
    @IBAction fileprivate func closeButtonPressed() {
        output.closeButtonPressed()
    }
    
    @IBAction fileprivate func doneButtonPressed() {
        output.doneButtonPressed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        
        setupTitleObserver()
        setupNoteObserver()
        setupSubtasksContentSizeObserver()
        
        taskTitleField.textView.delegate = self
        taskTitleField.textView.textContainerInset = UIEdgeInsets(top: 3.5, left: 0, bottom: 3.5, right: 0)
        taskTitleField.textView.font = UIFont.systemFont(ofSize: 24)
        taskTitleField.maxNumberOfLines = 3
        taskTitleField.showsVerticalScrollIndicator = false
        taskTitleField.placeholderAttributedText
            = NSAttributedString(string: "input_task_title".localized,
                                 attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 24),
                                              NSForegroundColorAttributeName: AppTheme.current.secondaryTintColor])
        
        taskNoteField.textView.delegate = self
        taskNoteField.textView.textContainerInset = .zero
        taskNoteField.textView.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
        taskNoteField.maxNumberOfLines = 5
        taskNoteField.showsVerticalScrollIndicator = false
        taskNoteField.placeholderAttributedText
            = NSAttributedString(string: "input_task_note".localized,
                                 attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16,
                                                                                     weight: UIFontWeightLight),
                                              NSForegroundColorAttributeName: AppTheme.current.secondaryTintColor])
        
        dueDateView.didChangeFilledState = { [weak self] isFilled in
            self?.reminderView.isHidden = !isFilled
            self?.repeatView.isHidden = !isFilled
        }
        dueDateView.didClear = { [weak self] in
            self?.output.dueDateCleared()
        }
        dueDateView.didTouchedUp = { [weak self] in
            self?.showDueDatePicker()
        }
        
        reminderView.didClear = { [weak self] in
            self?.output.reminderCleared()
        }
        reminderView.didTouchedUp = { [weak self] in
            self?.showReminderPicker()
        }
        
        repeatView.didChangeFilledState = { [weak self] isFilled in
            self?.repeatEndingDateView.isHidden = !isFilled
        }
        repeatView.didClear = { [weak self] in
            self?.output.repeatCleared()
        }
        repeatView.didTouchedUp = { [weak self] in
            self?.showRepeatingPicker()
        }
        
        repeatEndingDateView.didClear = { [weak self] in
            self?.output.repeatEndingDateCleared()
        }
        repeatEndingDateView.didTouchedUp = { [weak self] in
            self?.showRepeatEndingDatePicker()
        }
        
        locationView.didChangeFilledState = { [weak self] isFilled in
            self?.locationReminderView.isHidden = !isFilled
        }
        locationView.didClear = { [weak self] in
            self?.output.locationCleared()
        }
        locationView.didTouchedUp = { [weak self] in
            self?.showLocationEditor()
        }
        
        locationReminderView.didChangeCkeckedState = { [weak self] isChecked in
            self?.output.locationReminderSelectionChanged(to: isChecked)
        }
        

        taskTagsView.didTouchedUp = { [weak self] in
            self?.showTagsPicker()
        }
        
        taskImportancyPicker.onPick = { [weak self] isImportant in
            self?.output.taskImportantChanged(to: isImportant)
        }
        
        
        dueDateEditorHandler.onDateChange = { [weak self] date in
            self?.output.dueDateChanged(to: date)
        }
        
        repeatEndingDateEditorHandler.onDateChange = { [weak self] date in
            self?.output.repeatEndingDateChanged(to: date)
        }
        
        addSubtaskView.didEndEditing = { [weak self] title in
            if !title.trimmed.isEmpty {
                self?.output.addSubtask(with: title)
            }
        }
        subtasksView.estimatedRowHeight = 36
        subtasksView.rowHeight = UITableViewAutomaticDimension
        subtasksView.longPressReorderDelegate = self
        
        keyboardManager.keyboardWillAppear = { [weak self] frame, duration in
            guard let `self` = self else { return }
            guard self.addSubtaskView.titleField.isFirstResponder else { return }
            
            let offsetY = self.addSubtaskView.frame.minY
            UIView.animate(withDuration: duration, animations: { 
                self.contentScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
            })
        }
        
        subtaskCellActionsProvider.onDelete = { [weak self] indexPath in
            self?.output.removeSubtask(at: indexPath.row)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.backgroundColor
        
        contentContainerView.barColor = AppTheme.current.foregroundColor
        closeButton.tintColor = AppTheme.current.redColor
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "contentSize" {
            if let contentSizeValue = change?[.newKey] as? NSValue {
                let contentHeight = max(0, contentSizeValue.cgSizeValue.height)
                subtasksViewHeightConstraint.constant = contentHeight
                let offsetY = addSubtaskView.frame.minY
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                    
                    guard self.addSubtaskView.titleField.isFirstResponder else { return }
                    self.contentScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
                }
            }
        }
    }
    
    deinit {
        subtasksView.removeObserver(self, forKeyPath: "contentSize")
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
    
    func setDueDate(_ dueDate: String?) {
        dueDateView.text = dueDate ?? "due_date".localized
        
        dueDateView.isFilled = dueDate != nil
    }
    
    func setReminder(_ reminder: NotificationMask) {
        reminderView.text = reminder.title
        
        reminderView.isFilled = reminder != .doNotNotify
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
        locationView.text = location ?? "location".localized
        
        locationView.isFilled = location != nil
    }
    
    func setLocationReminderIsSelected(_ isSelected: Bool) {
        locationReminderView.isChecked = isSelected
    }
    
    func setTaskImportant(_ isImportant: Bool) {
        taskImportancyPicker.isPicked = isImportant
    }
    
    
    func reloadSubtasks() {
        subtasksView.reloadData()
    }
    
    func batchReloadSubtask(insertions: [Int], deletions: [Int], updates: [Int]) {
        UIView.performWithoutAnimation {
            let contentOffset = self.contentScrollView.contentOffset
            
            self.subtasksView.beginUpdates()
            
            deletions.forEach { index in
                self.subtasksView.deleteRows(at: [IndexPath(row: index, section: 0)],
                                             with: .none)
            }
            
            insertions.forEach { index in
                self.subtasksView.insertRows(at: [IndexPath(row: index, section: 0)],
                                             with: .none)
            }
            
            updates.forEach { index in
                self.subtasksView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                             with: .none)
            }
            
            self.subtasksView.endUpdates()
            
            self.contentScrollView.contentOffset = contentOffset
        }
    }

    func setTags(_ tags: [Tag]) {
        taskTagsView.tags = tags
        
        taskTagsView.isFilled = !tags.isEmpty
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

extension TaskEditorView: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalDismissalTransition()
    }
    
}


extension TaskEditorView: TaskParameterEditorContainerOutput {
    
    func taskParameterEditingCancelled(type: TaskParameterEditorType) {
        switch type {
        case .dueDate: output?.dueDateCleared()
        case .reminder: output?.reminderCleared()
        case .repeating: output?.repeatCleared()
        case .repeatEndingDate: output?.repeatEndingDateCleared()
        case .location:
            setTopButtonsVisible(true)
            output?.locationCleared()
        case .tags: output?.tagsCleared()
        }
    }

    func taskParameterEditingFinished(type: TaskParameterEditorType) {
        if case .location = type {
            setTopButtonsVisible(true)
        }
    }

    func editorViewController(forType type: TaskParameterEditorType) -> UIViewController {
        switch type {
        case .dueDate:
            let viewController = ViewControllersFactory.taskDueDateEditor
            viewController.loadViewIfNeeded()
            viewController.output = dueDateEditorHandler
            output.willPresentDueDateEditor(viewController)
            return viewController
        case .reminder:
            let viewController = ViewControllersFactory.taskReminderEditor
            viewController.output = self
            output.willPresentReminderEditor(viewController)
            return viewController
        case .repeating:
            let viewController = ViewControllersFactory.taskRepeatingEditor
            viewController.output = self
            viewController.transitionOutput = taskParameterEditorContainer
            output.willPresentRepeatingEditor(viewController)
            return viewController
        case .repeatEndingDate:
            let viewController = ViewControllersFactory.taskDueDateEditor
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
            viewController.output = self
            output.willPresentTagsPicker(viewController)
            return viewController
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

final class TaskDueDateEditorHandler: TaskDueDateEditorOutput {

    var onDateChange: ((Date) -> Void)?
    
    func didSelectDueDate(_ dueDate: Date) {
        onDateChange?(dueDate)
    }

}

extension TaskEditorView: TaskReminderEditorOutput {

    func didSelectNotificationMask(_ notificationMask: NotificationMask) {
        output.reminderChanged(to: notificationMask)
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

extension TaskEditorView: TaskTagsPickerOutput {
    
    func tagSelected(_ tag: Tag) {
        output.tagSelected(tag)
    }
    
    func tagDeselected(_ tag: Tag) {
        output.tagDeselected(tag)
    }
    
    func tagRemoved(_ tag: Tag) {
        output.tagRemoved(tag)
    }
    
    func tagUpdated(_ tag: Tag) {
        output.tagUpdated(tag)
    }
    
}

extension TaskEditorView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.subtasksCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtaskCell",
                                                     for: indexPath) as! SubtaskCell
            
        if let subtask = dataSource?.subtask(at: indexPath.row) {
            cell.title = subtask.title
            cell.isDone = subtask.isDone
            
            cell.onBeginEditing = { [unowned self] in
                let frame = cell.frame
                let normalFrame = self.contentScrollView.convert(frame, from: tableView)
                UIView.animate(withDuration: 0.2, animations: {
                    self.contentScrollView.contentOffset = CGPoint(x: 0, y: normalFrame.minY)
                })
            }
            cell.onDone = { [unowned self] in
                self.output?.doneSubtask(at: indexPath.row)
            }
            cell.onChangeTitle = { [unowned self] title in
                self.output?.updateSubtask(at: indexPath.row, newTitle: title)
            }
            cell.onChangeHeight = { [unowned self] height in
                let currentOffset = self.contentScrollView.contentOffset
                UIView.performWithoutAnimation {
                    self.subtasksView.beginUpdates()
                    self.subtasksView.endUpdates()

                    if currentOffset != .zero {
                        self.contentScrollView.contentOffset = currentOffset
                    }
                }
            }
            
            cell.delegate = subtaskCellActionsProvider
        }
        
        return cell
    }

}

extension TaskEditorView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SubtaskCell
        cell.beginEditing()
    }

}

extension TaskEditorView: ReorderableTableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   reorderRowsFrom fromIndexPath: IndexPath,
                   to toIndexPath: IndexPath) {
        output.exchangeSubtasks(at: (fromIndexPath.row, toIndexPath.row))
    }
    
    func tableView(_ tableView: UITableView, showDraggingView view: UIView, at indexPath: IndexPath) {
        view.backgroundColor = AppTheme.current.foregroundColor
    }
    
    func tableView(_ tableView: UITableView, hideDraggingView view: UIView, at indexPath: IndexPath) {
        view.backgroundColor = .clear
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
    
    func setupSubtasksContentSizeObserver() {
        subtasksView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
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
        let viewsToHide: [UIView] = [taskNoteField, dueDateView,
                                     reminderView, repeatView,
                                     locationView, locationReminderView,
                                     taskImportancyPicker, addSubtaskView,
                                     subtasksView, taskTagsView]
        viewsToHide.forEach { view in
            UIView.animate(withDuration: 0.2, animations: { 
                view.isUserInteractionEnabled = isEnabled
                view.alpha = isEnabled ? 1 : 0
            })
        }
    }
    
}

fileprivate extension TaskEditorView {

    func showDueDatePicker() {
        showTaskParameterEditor(with: .dueDate)
    }
    
    func showReminderPicker() {
        showTaskParameterEditor(with: .reminder)
    }
    
    func showRepeatingPicker() {
        showTaskParameterEditor(with: .repeating)
    }
    
    func showRepeatEndingDatePicker() {
        showTaskParameterEditor(with: .repeatEndingDate)
    }
    
    func showLocationEditor() {
        showTaskParameterEditor(with: .location)
        setTopButtonsVisible(false)
    }
    
    func showTagsPicker() {
        showTaskParameterEditor(with: .tags)
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

final class AddSubtaskView: UIView {

    @IBOutlet fileprivate weak var decorationView: UIImageView! {
        didSet {
            decorationView.tintColor = AppTheme.current.secondaryTintColor
        }
    }
    @IBOutlet fileprivate weak var titleField: UITextField! {
        didSet {
            titleField.delegate = self
            titleField.textColor = AppTheme.current.tintColor
        }
    }
    
    var title: String {
        get { return titleField.text ?? "" }
        set { titleField.text = newValue }
    }
    
    var didEndEditing: ((String) -> Void)?

}

extension AddSubtaskView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didEndEditing?(title)
        textField.text = nil
        return true
    }

}
