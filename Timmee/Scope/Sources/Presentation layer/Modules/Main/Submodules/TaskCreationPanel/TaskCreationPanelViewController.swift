//
//  TaskCreationPanelViewController.swift
//  Timmee
//
//  Created by i.kharabet on 13.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol TaskCreationPanelInput: class {
    var dimmedBackgroundView: UIView? { get set }
    
    var enteredTaskTitle: String? { get }
    var isImportancySelected: Bool { get }
    
    func clearTaskTitleInput()
    func setImportancy(_ isImportant: Bool)
    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool)
}

protocol TaskCreationPanelOutput: class {
    func didPressAddTaskButton()
    func didPressCreateTaskButton(taskKind: Task.Kind)
}

final class TaskCreationPanelViewController: UIViewController {
    
    weak var output: TaskCreationPanelOutput!
    
    @IBOutlet private var importancyPicker: TaskImportancyPicker!
    @IBOutlet private var taskTitleTextField: UITextField!
    @IBOutlet private var rightBarButton: FloatingButton!
    
    weak var containerView: UIView!
    weak var taskCreationMenuAnchorView: UIView!
    weak var dimmedBackgroundView: UIView? {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapToDimmedBackgroundView))
            dimmedBackgroundView?.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    private lazy var taskKindMenu = {
        FloatingMenu(items: [
            FloatingMenu.Item(title: "create_single_task".localized,
                              action: { [unowned self] in self.handleTaskCreationMenuSelection(taskKind: .single) }),
            FloatingMenu.Item(title: "create_regular_task".localized,
                              action: { [unowned self] in self.handleTaskCreationMenuSelection(taskKind: .regular) })
        ])
    }()
    
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
        
        taskKindMenu.add(to: containerView)
        taskKindMenu.pin(to: taskCreationMenuAnchorView, offset: 12)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        taskTitleTextField.textColor = AppTheme.current.backgroundTintColor
        taskTitleTextField.tintColor = AppTheme.current.backgroundTintColor.withAlphaComponent(0.75)
        taskTitleTextField.attributedPlaceholder = "new_task".localized.asPlaceholder
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
                                               name: UITextField.textDidChangeNotification,
                                               object: taskTitleTextField)
    }
    
    func handleTaskCreationMenuSelection(taskKind: Task.Kind) {
        setTaskKindMenuVisible(false)
        output.didPressCreateTaskButton(taskKind: taskKind)
    }
    
    func updateRightBarButton() {
        if taskTitleTextField.isFirstResponder, enteredTaskTitle != nil {
            rightBarButton.setImage(UIImage(named: "checkmark"), for: .normal)
        } else {
            rightBarButton.setImage(UIImage(named: "plus"), for: .normal)
        }
    }
    
    func setTaskKindMenuVisible(_ isVisible: Bool) {
        if isVisible {
            taskTitleTextField.isUserInteractionEnabled = false
            importancyPicker.isUserInteractionEnabled = false
            dimmedBackgroundView?.alpha = 0
            dimmedBackgroundView?.isHidden = false
            taskKindMenu.show(animated: true,
                              animations: {
                                  self.rightBarButton.setState(.active)
                                  self.taskTitleTextField.alpha = 0.65
                                  self.importancyPicker.alpha = 0.65
                                  self.dimmedBackgroundView?.alpha = 1
                              })
        } else {
            taskKindMenu.hide(animated: true,
                              animations: {
                                  self.rightBarButton.setState(.default)
                                  self.taskTitleTextField.alpha = 1
                                  self.importancyPicker.alpha = 1
                                  self.dimmedBackgroundView?.alpha = 0
                              },
                              completion: {
                                  self.taskTitleTextField.isUserInteractionEnabled = true
                                  self.importancyPicker.isUserInteractionEnabled = true
                                  self.dimmedBackgroundView?.isHidden = true
                              })
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
            setTaskKindMenuVisible(!taskKindMenu.isShown)
        }
    }
    
    @objc private func onTapToDimmedBackgroundView() {
        setTaskKindMenuVisible(false)
    }
    
}
