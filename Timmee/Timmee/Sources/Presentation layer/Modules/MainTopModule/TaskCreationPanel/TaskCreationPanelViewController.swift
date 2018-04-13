//
//  TaskCreationPanelViewController.swift
//  Timmee
//
//  Created by i.kharabet on 13.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol TaskCreationPanelInput: class {
    func clearTaskTitleInput()
    func setImportancy(_ isImportant: Bool)
    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool)
}

protocol TaskCreationPanelOutput: class {
    func didUpdateTaskTitle(to title: String)
    func didPressAddTaskButton()
    func didPressCreateTaskButton()
}

final class TaskCreationPanelViewController: UIViewController {
    
    weak var output: TaskCreationPanelOutput!
    
    @IBOutlet private var importancyView: UIImageView!
    @IBOutlet private var taskTitleTextField: UITextField!
    @IBOutlet private var rightBarButton: UIButton!
    
    // newTaskTitleTextField.isFirstResponder
    private var enteredTaskTitle: String? {
        if let title = taskTitleTextField.text, !title.trimmed.isEmpty {
            return title
        }
        return nil
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToTaskTitleChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        taskTitleTextField.textColor = AppTheme.current.backgroundTintColor
        taskTitleTextField.tintColor = AppTheme.current.backgroundTintColor.withAlphaComponent(0.75)
        taskTitleTextField.attributedPlaceholder = "new_task".localized.asPlaceholder
        
        rightBarButton.tintColor = AppTheme.current.blueColor
    }
    
}

extension TaskCreationPanelViewController: TaskCreationPanelInput {
    
    func clearTaskTitleInput() {
        taskTitleTextField.text = nil
        updateRightBarButton()
    }
    
    func setImportancy(_ isImportant: Bool) {
        importancyView.isHighlighted = isImportant
    }
    
    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool) {
        if isFirstResponder && !taskTitleTextField.isFirstResponder {
            taskTitleTextField.becomeFirstResponder()
        } else if taskTitleTextField.isFirstResponder {
            taskTitleTextField.resignFirstResponder()
        }
    }
    
}

extension TaskCreationPanelViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true //editingMode == .default
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateRightBarButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let title = enteredTaskTitle {
            output.didUpdateTaskTitle(to: title)
            output.didPressAddTaskButton()
            
            clearTaskTitleInput()
            
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        output.didUpdateTaskTitle(to: textField.text ?? "")
        updateRightBarButton()
    }
    
}

private extension TaskCreationPanelViewController {
    
    func subscribeToTaskTitleChange() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(taskTitleDidChanged),
                                               name: .UITextFieldTextDidChange,
                                               object: taskTitleTextField)
    }
    
    func updateRightBarButton() {
        if taskTitleTextField.isFirstResponder, enteredTaskTitle != nil {
            rightBarButton.setImage(UIImage(named: "checkmark"), for: .normal)
        } else {
            rightBarButton.setImage(UIImage(named: "plus"), for: .normal)
        }
    }
    
    @objc func taskTitleDidChanged() {
        updateRightBarButton()
    }
    
    @IBAction func toggleImportancy() {
        setImportancy(!importancyView.isHighlighted)
    }
    
    @IBAction private func rightBarButtonPressed() {
        if taskTitleTextField.isFirstResponder {
            if let title = enteredTaskTitle {
                output.didUpdateTaskTitle(to: title)
                output.didPressAddTaskButton()
                
                clearTaskTitleInput()
            }
        } else {
            output.didPressCreateTaskButton()
        }
    }
    
}
