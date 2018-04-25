//
//  TaskCreationPanelViewController.swift
//  Timmee
//
//  Created by i.kharabet on 13.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol TaskCreationPanelInput: class {
    var enteredTaskTitle: String? { get }
    var isImportancySelected: Bool { get }
    
    func clearTaskTitleInput()
    func setImportancy(_ isImportant: Bool)
    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool)
}

protocol TaskCreationPanelOutput: class {
    func didPressAddTaskButton()
    func didPressCreateTaskButton()
}

final class TaskCreationPanelViewController: UIViewController {
    
    weak var output: TaskCreationPanelOutput!
    
    @IBOutlet private var importancyPicker: TaskImportancyPicker!
    @IBOutlet private var taskTitleTextField: UITextField!
    @IBOutlet private var rightBarButton: UIButton!
    
    // newTaskTitleTextField.isFirstResponder
    var enteredTaskTitle: String? {
        if let title = taskTitleTextField.text, !title.trimmed.isEmpty {
            return title
        }
        return nil
    }
    
    var isImportancySelected: Bool {
        return importancyPicker.isPicked
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
        importancyPicker.isPicked = isImportant
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateRightBarButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if enteredTaskTitle != nil {
            output.didPressAddTaskButton()
            
            clearTaskTitleInput()
            
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
        setImportancy(!importancyPicker.isPicked)
    }
    
    @IBAction private func rightBarButtonPressed() {
        if taskTitleTextField.isFirstResponder, enteredTaskTitle != nil {
            output.didPressAddTaskButton()
            
            clearTaskTitleInput()
        } else {
            output.didPressCreateTaskButton()
        }
    }
    
}
