//
//  ListRepresentationView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol ListRepresentationViewInput: class {
    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool)
    func clearTaskTitleInput()
    
    func setEditingMode(_ mode: ListRepresentationEditingMode)
    func setImportancy(_ isImportant: Bool)
    func setGroupEditingActionsEnabled(_ isEnabled: Bool)
    func setCompletionGroupEditingAction(_ action: GroupEditingCompletionAction)
    
    func showConfirmationAlert(title: String, message: String, confirmationTitle: String, success: @escaping () -> Void)
}

protocol ListRepresentationViewOutput: class {
    func didToggleImportancyInShortTaskEditor(to isImportant: Bool)
    func didInputTaskTitle(_ title: String?)
    func didPressAddTaskButton()
    func didPressMoreButton()
    
    func groupEditingWillToggle(to isEditing: Bool)
    func groupEditingToggled(to isEditing: Bool)
    func didSelectGroupEditingAction(_ action: GroupEditingAction)
}

final class ListRepresentationView: UIViewController {

    var output: ListRepresentationViewOutput!
    
    @IBOutlet private var tableContainerView: UIView!
    
    @IBOutlet private var shortTaskEditorView: UIView!
    
    @IBOutlet private var bottomContainerConstraint: NSLayoutConstraint!
    
    private let keyboardManager = KeyboardManager()
    
    private var editingMode: ListRepresentationEditingMode = .default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            self.bottomContainerConstraint.constant = frame.height
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            self.bottomContainerConstraint.constant = 0
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableContainerView.backgroundColor = AppTheme.current.middlegroundColor
    }

}

extension ListRepresentationView: ListRepresentationViewInput {
    
    func clearTaskTitleInput() {
        
    }
    
    func setEditingMode(_ mode: ListRepresentationEditingMode) {
        self.editingMode = mode
        let isGroupEditing = mode == .group
        
//        newTaskTitleTextField.resignFirstResponder()
//        groupEditingActionsView.setEnabled(false)
//        groupEditingActionsView.setVisible(isGroupEditing, animated: true)
        
        self.output.groupEditingWillToggle(to: isGroupEditing)
        
        UIView.animate(withDuration: 0.33, animations: {
            self.shortTaskEditorView.alpha = isGroupEditing ? 0 : 1
        }) { _ in
            self.output.groupEditingToggled(to: isGroupEditing)
        }
    }
    
    func setImportancy(_ isImportant: Bool) {
        
        output.didToggleImportancyInShortTaskEditor(to: isImportant)
    }
    
    func setGroupEditingActionsEnabled(_ isEnabled: Bool) {

    }
    
    func setCompletionGroupEditingAction(_ action: GroupEditingCompletionAction) {
        
    }

    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool) {
        
    }
    
    func showConfirmationAlert(title: String,
                               message: String,
                               confirmationTitle: String,
                               success: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: confirmationTitle,
                                      style: .default) { _ in success() })
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}
