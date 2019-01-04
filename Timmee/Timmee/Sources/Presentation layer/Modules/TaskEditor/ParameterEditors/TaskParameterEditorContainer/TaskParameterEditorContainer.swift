//
//  TaskParameterEditorContainer.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

enum TaskParameterEditorType {
    case dueDateTime
    case dueDate
    case dueTime
    case startDate
    case endDate
    case reminder
    case repeating
    case repeatEndingDate
    case location
    case tags
    case timeTemplates
    case attachments
    case audioNote
    
    var title: String {
        switch self {
        case .dueDateTime: return "due_date".localized
        case .dueDate: return "due_date".localized
        case .dueTime: return "due_time".localized
        case .startDate: return "start_date".localized
        case .endDate: return "end_date".localized
        case .reminder: return "reminder".localized
        case .repeating: return "repeat".localized
        case .repeatEndingDate: return "repeat_ending_date".localized
        case .location: return "location".localized
        case .tags: return "tags_picker".localized
        case .timeTemplates: return "time_templates".localized
        case .attachments: return "attachments".localized
        case .audioNote: return "audio_note".localized
        }
    }
}

enum TaskRepeatingPickerType {
    case interval
    case weekly
    
    var editorTitle: String {
        switch self {
        case .interval: return "choose_interval".localized
        case .weekly: return "choose_days".localized
        }
    }
}

protocol TaskParameterEditorContainerInput: class {
    func setType(_ type: TaskParameterEditorType)
}

protocol TaskParameterEditorContainerOutput: class {
    func editorViewController(forType type: TaskParameterEditorType) -> UIViewController
    func repeatingPickerViewController(forType type: TaskRepeatingPickerType) -> UIViewController
    
    func taskParameterEditingCancelled(type: TaskParameterEditorType)
    func taskParameterEditingFinished(type: TaskParameterEditorType)
}


protocol TaskParameterEditorInput: class {
    var container: TaskParameterEditorOutput? { get set }
    var requiredHeight: CGFloat { get }
    func completeEditing(completion: @escaping (Bool) -> Void)
}

extension TaskParameterEditorInput {
    func completeEditing(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}

protocol TaskParameterEditorOutput: class {
    var closeButton: UIButton! { get }
    var doneButton: UIButton! { get }
}


final class TaskParameterEditorContainer: UIViewController, TaskParameterEditorOutput {

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var editorContainer: UIView!
    
    @IBOutlet private var editorContainerHeightConstraint: NSLayoutConstraint!
    
    weak var output: TaskParameterEditorContainerOutput?
    
    private var type: TaskParameterEditorType!
    
    private var viewControllers: [UIViewController] = []
    
    let transitionHandler = FadePresentationTransitionHandler()
    
    @IBAction private func closeButtonPressed() {
        if viewControllers.count <= 1 {
            output?.taskParameterEditingCancelled(type: type)
            dismiss(animated: true, completion: nil)
        } else {
            popViewController()
        }
    }
    
    @IBAction private func doneButtonPressed() {
        if let currentParameterEditor = viewControllers.last as? TaskParameterEditorInput {
            currentParameterEditor.completeEditing(completion: { [unowned self] shouldDismiss in
                if shouldDismiss {
                    self.completeEditing()
                }
            })
        } else {
            completeEditing()
        }
    }
    
    @IBAction private func backgroundViewPressed() {
        completeEditing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = transitionHandler
        
        editorContainer.backgroundColor = AppTheme.current.foregroundColor
        titleLabel.textColor = AppTheme.current.backgroundTintColor
        closeButton.tintColor = AppTheme.current.redColor
        doneButton.tintColor = AppTheme.current.greenColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension TaskParameterEditorContainer: TaskParameterEditorContainerInput {

    func setType(_ type: TaskParameterEditorType) {
        self.type = type
        
        setupEditor(for: type)
        setEditorTitle(type.title)
    }

}

extension TaskParameterEditorContainer: TaskRepeatingEditorTransitionOutput {

    func didAskToShowIntervalPiker(completion: @escaping  (TaskIntervalRepeatingPicker) -> Void) {
        pushPicker(type: .interval, completion: { viewController in
            if let intervalPicker = viewController as? TaskIntervalRepeatingPicker {
                completion(intervalPicker)
            }
        })
    }
    
    func didAskToShowWeeklyPicker(completion: @escaping (TaskWeeklyRepeatingPicker) -> Void) {
        pushPicker(type: .weekly, completion: { viewController in
            if let repeatingPicker = viewController as? TaskWeeklyRepeatingPicker {
                completion(repeatingPicker)
            }
        })
    }

}

extension TaskParameterEditorContainer: TaskTimeTemplatePickerTransitionOutput {
    
    func didAskToShowTimeTemplateEditor(completion: @escaping (TaskTimeTemplateEditor) -> Void) {
        let controller = ViewControllersFactory.taskTimeTemplateEditor
        controller.title = "time_template".localized
        pushViewController(controller) { viewController in
            if let timeTemplateEditor = viewController as? TaskTimeTemplateEditor {
                completion(timeTemplateEditor)
            }
        }
    }
    
    func didCompleteTimeTemplateEditing() {
        popViewController()
    }
    
}

extension TaskParameterEditorContainer: TaskReminderEditorTransitionOutput {
    
    func didAskToShowNotificationDatePicker(completion: @escaping (TaskDueDateTimeEditor) -> Void) {
        let controller = ViewControllersFactory.taskDueDateTimeEditor
        controller.title = "notification_date".localized
        pushViewController(controller) { viewController in
            guard let dueDateTimeEditor = viewController as? TaskDueDateTimeEditor else { return }
            completion(dueDateTimeEditor)
        }
    }
    
    func didAskToShowNotificationTimePicker(completion: @escaping (TaskDueTimePicker) -> Void) {
        let controller = ViewControllersFactory.taskDueTimePicker
        controller.title = "notification_time".localized
        pushViewController(controller) { viewController in
            guard let dueTimePicker = viewController as? TaskDueTimePicker else { return }
            completion(dueTimePicker)
        }
    }
    
}

private extension TaskParameterEditorContainer {
    
    func completeEditing() {
        output?.taskParameterEditingFinished(type: type)
        dismiss(animated: true, completion: nil)
    }
    
}

private extension TaskParameterEditorContainer {

    func setupEditor(for type: TaskParameterEditorType) {
        guard let viewController = output?.editorViewController(forType: type) else { return }
        
        addChild(viewController)
        editorContainer.addSubview(viewController.view)
        viewController.view.allEdges().toSuperview()
        viewController.didMove(toParent: self)
        
        if let editorInput = viewController as? TaskParameterEditorInput {
            editorInput.container = self
            editorContainerHeightConstraint.constant = editorInput.requiredHeight
        }
        
        viewControllers.append(viewController)
    }

    func setEditorTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func pushPicker(type: TaskRepeatingPickerType, completion: @escaping (UIViewController) -> Void) {
        guard let viewController = output?.repeatingPickerViewController(forType: type) else { return }
        viewController.title = type.editorTitle
        pushViewController(viewController, completion: completion)
    }
    
    func pushViewController(_ viewController: UIViewController, completion: @escaping (UIViewController) -> Void) {
        addChild(viewController)
        
        let offset = editorContainer.bounds.width
        if let editorInput = viewController as? TaskParameterEditorInput {
            editorInput.container = self
            editorContainerHeightConstraint.constant = editorInput.requiredHeight
        }
        
        if let fromView = editorContainer.subviews.first {
            editorContainer.addSubview(viewController.view)
            viewController.view.allEdges().toSuperview()
            viewController.view.transform = CGAffineTransform(translationX: offset, y: 0)
            
            completion(viewController)
            
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            self.setEditorTitle(viewController.title ?? "")
                            self.closeButton.tintColor = AppTheme.current.backgroundTintColor
                            self.closeButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
                            fromView.transform = CGAffineTransform(translationX: -offset, y: 0)
                            viewController.view.transform = .identity
                            self.view.layoutIfNeeded()
            }, completion: { _ in
                fromView.removeFromSuperview()
                viewController.didMove(toParent: self)
                self.viewControllers.append(viewController)
            })
        }
    }
    
    func popViewController() {
        guard let fromView = viewControllers.last else { return }
        guard let toView = viewControllers.item(at: viewControllers.count - 2) else { return }
        
        let offset = editorContainer.bounds.width
        if let editorInput = toView as? TaskParameterEditorInput {
            editorContainerHeightConstraint.constant = editorInput.requiredHeight
        }
        
        editorContainer.addSubview(toView.view)
        toView.view.allEdges().toSuperview()
        toView.view.transform = CGAffineTransform(translationX: -offset, y: 0)
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.setEditorTitle(self.type.title)
                        self.closeButton.tintColor = AppTheme.current.redColor
                        self.closeButton.setImage(#imageLiteral(resourceName: "trash"), for: .normal)
                        toView.view.transform = .identity
                        fromView.view.transform = CGAffineTransform(translationX: offset, y: 0)
                        self.view.layoutIfNeeded()
        }, completion: { _ in
            toView.view.allEdges().toSuperview()
            fromView.view.removeFromSuperview()
            fromView.removeFromParent()
            self.viewControllers.remove(object: fromView)
        })
    }
    
}
