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
    
    @IBOutlet fileprivate var titleTextField: UITextField!
    @IBOutlet fileprivate var dueDateView: TaskParameterView!
    @IBOutlet fileprivate var notificationView: TaskParameterView!
    
    fileprivate let timeTemplateService = TimeTemplatesService()
    
    fileprivate var timeTemplate: TimeTemplate!
    
    weak var output: TaskTimeTemplateEditorOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleObserver()
        
        setupTitleTextField()
        setupDueDateView()
        setupNotificationView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension TaskTimeTemplateEditor: TaskTimeTemplateEditorInput {
    
    func setTimeTemplate(_ timeTemplate: TimeTemplate?) {
        self.timeTemplate = timeTemplate ?? timeTemplateService.createTimeTemplate()
        
        titleTextField.text = self.timeTemplate.title
        updateDueDate()
        updateNotification()
    }
    
}

extension TaskTimeTemplateEditor: TaskParameterEditorInput {
    var requiredHeight: CGFloat {
        return 156 + 200
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

fileprivate extension TaskTimeTemplateEditor {
    
    func setupTitleTextField() {
        titleTextField.attributedPlaceholder = "new_time_template".localized.asForegroundPlaceholder
        titleTextField.textColor = AppTheme.current.tintColor
    }
    
    func setupDueDateView() {
        dueDateView.didClear = { [unowned self] in
            self.timeTemplate.dueDate = nil
            self.updateDueDate()
        }
        dueDateView.didTouchedUp = { [unowned self] in
            //            self.showTaskParameterEditor(with: .dueDate)
        }
    }
    
    func setupNotificationView() {
        notificationView.didClear = { [unowned self] in
            self.timeTemplate.notification = .doNotNotify
            self.updateNotification()
        }
        notificationView.didTouchedUp = { [unowned self] in
            //            self.showTaskParameterEditor(with: .reminder)
        }
    }
    
    
    func updateDueDate() {
        dueDateView.text = makeFormattedString(from: timeTemplate.dueDate)
        dueDateView.isFilled = timeTemplate.dueDate != nil
    }
    
    func updateNotification() {
        notificationView.text = timeTemplate.notification.title
        notificationView.isFilled = timeTemplate.notification != .doNotNotify
    }
    
    
    func makeFormattedString(from date: Date?) -> String? {
        if let date = date {
            let nearestDate = NearestDate(date: date)
            
            if case .custom = nearestDate {
                return date.asDayMonthTime
            } else {
                return nearestDate.title + ", " + date.asTimeString
            }
        } else {
            return nil
        }
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
    }
    
}

fileprivate extension TaskTimeTemplateEditor {
    
    func isTimeTemplateValid(_ timeTemplate: TimeTemplate) -> Bool {
        return timeTemplate.dueDate != nil
            && timeTemplate.notification != .doNotNotify
            && !timeTemplate.title.trimmed.isEmpty
    }
    
}
