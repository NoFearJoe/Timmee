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

    @IBOutlet fileprivate weak var contentContainerView: BarView!
    @IBOutlet fileprivate weak var contentScrollView: UIScrollView!
    @IBOutlet fileprivate weak var contentView: UIView!
    
    @IBOutlet fileprivate weak var taskTitleField: GrowingTextView!
    @IBOutlet fileprivate weak var taskNoteField: GrowingTextView!
    
    @IBOutlet fileprivate weak var closeButton: UIButton!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    
    @IBOutlet fileprivate weak var dueDateView: TaskParameterView!
    @IBOutlet fileprivate weak var reminderView: TaskParameterView!
    @IBOutlet fileprivate weak var repeatView: TaskParameterView!
    @IBOutlet fileprivate weak var repeatEndingDateView: TaskParameterView!
    
    @IBOutlet fileprivate weak var locationView: TaskParameterView!
    @IBOutlet fileprivate weak var locationReminderView: TaskCheckableParameterView!
    
    @IBOutlet fileprivate weak var taskTagsView: TaskTagsView!
    
    @IBOutlet fileprivate weak var taskImportancyPicker: TaskImportancyPicker!
    
    @IBOutlet fileprivate weak var addSubtaskView: AddSubtaskView!
    @IBOutlet fileprivate weak var subtasksView: UITableView!
    @IBOutlet fileprivate weak var subtasksViewHeightConstraint: NSLayoutConstraint!
    
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
        
//        taskTagsView.didChangeFilledState = { [weak self] isFilled in
//
//        }
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
            if !title.isEmpty {
                self?.output.addSubtask(with: title)
            }
        }
        subtasksView.estimatedRowHeight = 36
        subtasksView.rowHeight = UITableViewAutomaticDimension
        
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
        
        contentContainerView.barColor = AppTheme.current.scheme.backgroundColor
        closeButton.tintColor = AppTheme.current.scheme.backgroundColor
        doneButton.tintColor = AppTheme.current.scheme.greenColor
        
        taskTitleField.textColor = AppTheme.current.scheme.specialColor
        taskTitleField.tintColor = AppTheme.current.scheme.tintColor
        taskNoteField.textColor = AppTheme.current.scheme.tintColor
        taskNoteField.tintColor = AppTheme.current.scheme.tintColor
        
        if taskTitleField.text.isEmpty {
            taskTitleField.becomeFirstResponder()
        }
        
        output.viewDidAppear()
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
        return taskTitleField.text.trimmed
    }
    
    func getTaskNote() -> String {
        return taskNoteField.text.trimmed
    }
    

    func setTaskTitle(_ title: String) {
        taskTitleField.text = title
        setInterfaceEnabled(!title.isEmpty)
    }
    
    func setTaskNote(_ note: String) {
        taskNoteField.text = note
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
            self.subtasksView.beginUpdates()
            
            deletions.forEach { index in
                self.subtasksView.deleteRows(at: [IndexPath(row: index, section: 0)],
                                             with: .automatic)
            }
            
            insertions.forEach { index in
                self.subtasksView.insertRows(at: [IndexPath(row: index, section: 0)],
                                             with: .automatic)
            }
            
            updates.forEach { index in
                self.subtasksView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                             with: .automatic)
            }
            
            self.subtasksView.endUpdates()
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
    }
    
}

extension TaskEditorView: GrowingTextViewDelegate {

    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
//        UIView.animate(withDuration: 0.2) {
//            self.view.layoutIfNeeded()
//        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.layoutIfNeeded()
        return true
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
            cell.onBeginEditing = { [weak self] in
                let frame = cell.frame
                let normalFrame = self?.contentScrollView.convert(frame, from: cell) ?? .zero
                UIView.animate(withDuration: 0.2, animations: {
                    self?.contentScrollView.contentOffset = CGPoint(x: 0, y: normalFrame.minY)
                })
            }
            cell.onDone = { [weak self] in
                self?.output?.doneSubtask(at: indexPath.row)
            }
            cell.onChangeTitle = { [weak self] title in
                self?.output?.updateSubtask(at: indexPath.row, newTitle: title)
                UIView.performWithoutAnimation {
                    self?.subtasksView.reloadRows(at: [indexPath], with: .none)
                }
            }
            cell.onChangeHeight = { [weak self] height in
                guard let `self` = self else { return }
                let currentOffset = self.contentScrollView.contentOffset
                UIView.performWithoutAnimation {
                    self.subtasksView.reloadRows(at: [indexPath], with: .none)
                }
                self.contentScrollView.contentOffset = currentOffset
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        output.exchangeSubtasks(at: (sourceIndexPath.row, destinationIndexPath.row))
    }

}

fileprivate extension TaskEditorView {
    
    func setupTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(taskTitleDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: taskTitleField)
    }
    
    func setupNoteObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(taskNoteDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: taskNoteField)
    }
    
    func setupSubtasksContentSizeObserver() {
        subtasksView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    @objc func taskTitleDidChange(notification: Notification) {
        let text = getTaskTitle()
        
        output.taskTitleChanged(to: text)
        
        setInterfaceEnabled(!text.isEmpty)
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
            decorationView.tintColor = AppTheme.current.scheme.secondaryTintColor
        }
    }
    @IBOutlet fileprivate weak var titleField: UITextField! {
        didSet {
            titleField.delegate = self
            titleField.textColor = AppTheme.current.scheme.tintColor
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
