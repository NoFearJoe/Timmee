//
//  EditingModeController.swift
//  Timmee
//
//  Created by Илья Харабет on 23.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol EditingModeControllerOutput: class {
    func performGroupEditingAction(_ action: TargetGroupEditingAction)
    func performEditingModeChange(to mode: ListRepresentationEditingMode)
    
    func showListsForMoveTasks(completion: @escaping (List) -> Void)
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
}

final class EditingModeController {
    
    var groupEditingPanel: GroupEditingPanelInput!
    
    weak var output: EditingModeControllerOutput!
    
    var editingMode: ListRepresentationEditingMode = .default
    
}

extension EditingModeController {
    
    func toggleEditingMode() {
        editingMode = editingMode.next
        editingMode == .group ? groupEditingPanel.show() : groupEditingPanel.hide()
        output.performEditingModeChange(to: editingMode)
    }
    
}

extension EditingModeController: GroupEditingPanelOutput {
    
    func didSelectGroupEditingAction(_ action: GroupEditingAction) {
        switch action {
        case .delete:
            let message = "are_you_sure_you_want_to_delete_tasks".localized
            showConfirmationAlert(title: "remove_tasks".localized,
                                  message: message,
                                  confirmationTitle: "remove".localized) { [weak self] in
                                    self?.output.performGroupEditingAction(.delete)
                                    self?.toggleEditingMode()
            }
        case .complete:
            output.performGroupEditingAction(.complete)
            toggleEditingMode()
        case .move:
            output?.showListsForMoveTasks { [weak self] list in
                let message = "are_you_sure_you_want_to_move_tasks".localized + " \"\(list.title)\""
                self?.showConfirmationAlert(title: "move_tasks".localized,
                                            message: message,
                                            confirmationTitle: "move".localized) { [weak self] in
                                                self?.output.performGroupEditingAction(.move(list: list))
                                                self?.toggleEditingMode()
                }
            }
        }
    }
    
}

extension EditingModeController: ListRepresentationEditingOutput {
    
    func setGroupEditingActionsEnabled(_ isEnabled: Bool) {
        groupEditingPanel.setActionsEnabled(isEnabled)
    }
    
    func setCompletionGroupEditingAction(_ action: GroupEditingCompletionAction) {
        groupEditingPanel.updateCompletionAction(with: action)
    }
    
}

private extension EditingModeController {
    
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
        
        output.present(alert, animated: true, completion: nil)
    }
    
}
