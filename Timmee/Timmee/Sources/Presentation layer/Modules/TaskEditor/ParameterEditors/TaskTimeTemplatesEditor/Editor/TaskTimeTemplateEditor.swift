//
//  TaskTimeTemplateEditor.swift
//  Timmee
//
//  Created by i.kharabet on 16.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskTimeTemplateEditorInput: class {
    func setTimeTemplate(_ timeTemplate: TimeTemplate?)
}

protocol TaskTimeTemplateEditorOutput: class {
    func timeTemplateCreated()
}

final class TaskTimeTemplateEditor: UIViewController {
    
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var dueTimeView: TaskParameterView!
    @IBOutlet private var notificationView: TaskParameterView!
    
    private let timeTemplateService = ServicesAssembly.shared.timeTemplatesService
    
    private var timeTemplate: TimeTemplate!
    
    weak var output: TaskTimeTemplateEditorOutput?
    weak var container: TaskParameterEditorOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleObserver()
        
        setupTitleTextField()
        setupDueTimeView()
        setupNotificationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        container?.doneButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if titleTextField.text == nil || titleTextField.text!.isEmpty {
            titleTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        container?.doneButton.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension TaskTimeTemplateEditor: TaskTimeTemplateEditorInput {
    
    func setTimeTemplate(_ timeTemplate: TimeTemplate?) {
        self.timeTemplate = timeTemplate ?? timeTemplateService.createTimeTemplate()
        
        titleTextField.text = self.timeTemplate.title
        updateDueTime()
        updateNotification()
    }
    
}

extension TaskTimeTemplateEditor: TaskParameterEditorInput {
    var requiredHeight: CGFloat {
        return 156 + 200 + 96
    }
    
    func completeEditing(completion: @escaping (Bool) -> Void) {
        if isTimeTemplateValid(timeTemplate) {
            timeTemplateService.createOrUpdateTimeTemplate(timeTemplate) { [weak self] in
                self?.output?.timeTemplateCreated()
                completion(false)
            }
        } else {
            completion(false)
        }
    }
}

extension TaskTimeTemplateEditor: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

fileprivate extension TaskTimeTemplateEditor {
    
    func setupTitleTextField() {
        titleTextField.delegate = self
        titleTextField.attributedPlaceholder = "new_time_template".localized.asForegroundPlaceholder
        titleTextField.textColor = AppTheme.current.tintColor
    }
    
    func setupDueTimeView() {
        dueTimeView.didClear = { [unowned self] in
            self.timeTemplate.time = nil
            self.updateDueTime()
        }
        dueTimeView.didTouchedUp = { [unowned self] in
            self.showTaskParameterEditor(with: .dueTime)
        }
    }
    
    func setupNotificationView() {
        notificationView.didClear = { [unowned self] in
            self.timeTemplate.notification = .doNotNotify
            self.updateNotification()
        }
        notificationView.didTouchedUp = { [unowned self] in
            self.showTaskParameterEditor(with: .reminder)
        }
    }
    
    
    func updateDueTime() {
        if let time = timeTemplate.time {
            let minutes: String
            if time.minutes < 10 {
                minutes = "\(time.minutes)0"
            } else {
                minutes = "\(time.minutes)"
            }
            dueTimeView.text = "\(time.hours):\(minutes)"
        } else {
            dueTimeView.text = "due_time".localized
        }
        dueTimeView.isFilled = timeTemplate.time != nil
        updateDoneButton()
    }
    
    func updateNotification() {
        notificationView.text = timeTemplate.notification.title
        notificationView.isFilled = timeTemplate.notification != .doNotNotify
        updateDoneButton()
    }
    
}

extension TaskTimeTemplateEditor: TaskParameterEditorContainerOutput {
    
    func taskParameterEditingCancelled(type: TaskParameterEditorType) {
        switch type {
        case .dueTime:
            timeTemplate.time = nil
            updateDueTime()
        case .reminder:
            timeTemplate.notification = .doNotNotify
            updateNotification()
        default: return
        }
    }
    
    func taskParameterEditingFinished(type: TaskParameterEditorType) {}
    
    func editorViewController(forType type: TaskParameterEditorType) -> UIViewController {
        switch type {
        case .dueTime:
            let viewController = ViewControllersFactory.taskDueTimePicker
            viewController.loadViewIfNeeded()
            viewController.output = self
            
            if timeTemplate.time == nil { timeTemplate.time = makeDueTime() }
            viewController.setHours(timeTemplate.time?.hours ?? 0)
            viewController.setMinutes(timeTemplate.time?.minutes ?? 0)
            
            return viewController
        case .reminder:
            let viewController = ViewControllersFactory.taskReminderEditor
            viewController.output = self
            viewController.setNotification(.mask(timeTemplate.notification))
            viewController.setNotificationDatePickerVisible(false)
            return viewController
        default: return UIViewController()
        }
    }
    
    func repeatingPickerViewController(forType type: TaskRepeatingPickerType) -> UIViewController {
        return UIViewController()
    }
    
}

extension TaskTimeTemplateEditor: TaskDueTimePickerOutput {
    
    func didChangeHours(to hours: Int) {
        timeTemplate.time?.hours = hours
        updateDueTime()
    }
    
    func didChangeMinutes(to minutes: Int) {
        timeTemplate.time?.minutes = minutes
        updateDueTime()
    }
    
}

extension TaskTimeTemplateEditor: TaskReminderEditorOutput {
    
    func didSelectNotification(_ notification: TaskReminderSelectedNotification) {
        switch notification {
        case let .mask(notificationMask):
            timeTemplate.notification = notificationMask
            updateNotification()
        case .date: break
        }
    }
    
}

fileprivate extension TaskTimeTemplateEditor {
    
    func showTaskParameterEditor(with type: TaskParameterEditorType) {
        let taskParameterEditorContainer = ViewControllersFactory.taskParameterEditorContainer
        taskParameterEditorContainer.loadViewIfNeeded()
        
        taskParameterEditorContainer.output = self
        taskParameterEditorContainer.setType(type)
        
        present(taskParameterEditorContainer,
                animated: true,
                completion: nil)
    }
    
}

fileprivate extension TaskTimeTemplateEditor {
    
    func addTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(titleChanged),
                                               name: NSNotification.Name.UITextFieldTextDidChange,
                                               object: titleTextField)
    }
    
    @objc func titleChanged() {
        timeTemplate.title = titleTextField.text ?? ""
        updateDoneButton()
    }
    
}

fileprivate extension TaskTimeTemplateEditor {
    
    func updateDoneButton() {
        container?.doneButton.isHidden = !isTimeTemplateValid(timeTemplate)
    }
    
    func isTimeTemplateValid(_ timeTemplate: TimeTemplate) -> Bool {
        return timeTemplate.time != nil
            && timeTemplate.notification != .doNotNotify
            && !timeTemplate.title.trimmed.isEmpty
    }
    
    func makeDueTime() -> (hours: Int, minutes: Int) {
        var date = Date()
        date => TimeRounder.roundMinutes(date.minutes).asMinutes
        return (hours: date.hours, minutes: date.minutes)
    }
    
}
