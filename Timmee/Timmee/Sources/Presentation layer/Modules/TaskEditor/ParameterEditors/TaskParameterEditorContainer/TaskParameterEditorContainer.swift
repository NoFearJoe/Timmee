//
//  TaskParameterEditorContainer.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

enum TaskParameterEditorType {
    case dueDate
    case reminder
    case repeating
    case repeatEndingDate
    case location
    case tags
    case timeTemplates
    
    var title: String {
        switch self {
        case .dueDate: return "due_date".localized
        case .reminder: return "reminder".localized
        case .repeating: return "repeat".localized
        case .repeatEndingDate: return "repeat_ending_date".localized
        case .location: return "location".localized
        case .tags: return "tags_picker".localized
        case .timeTemplates: return "time_templates".localized
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
    var requiredHeight: CGFloat { get }
}


final class TaskParameterEditorContainer: UIViewController {

    @IBOutlet fileprivate weak var closeButton: UIButton!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var editorContainer: BarView!
    @IBOutlet fileprivate weak var editorContainerUnderlyingView: BarView!
    
    @IBOutlet fileprivate weak var editorContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var editorContainerBottomConstraint: NSLayoutConstraint!
    
    weak var output: TaskParameterEditorContainerOutput?
    
    fileprivate var type: TaskParameterEditorType!
    
    fileprivate var viewControllers: [UIViewController] = []
    
    @IBAction fileprivate func closeButtonPressed() {
        if viewControllers.count <= 1 {
            output?.taskParameterEditingCancelled(type: type)
            dismiss(animated: true, completion: nil)
        } else {
            popViewController()
        }
    }
    
    @IBAction fileprivate func doneButtonPressed() {
        output?.taskParameterEditingFinished(type: type)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction fileprivate func backgroundViewPressed() {
        output?.taskParameterEditingFinished(type: type)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        editorContainer.barColor = AppTheme.current.foregroundColor
        titleLabel.textColor = AppTheme.current.backgroundTintColor
        closeButton.tintColor = AppTheme.current.redColor
        doneButton.tintColor = AppTheme.current.greenColor
        editorContainerUnderlyingView.shadowRadius = 44
        editorContainerUnderlyingView.showShadow = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fullHeight: CGFloat = 64 + editorContainerHeightConstraint.constant
        view.transform = CGAffineTransform(translationX: 0, y: fullHeight)
        
        UIView.animate(withDuration: 0.25) { 
            self.view.transform = CGAffineTransform.identity
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let fullHeight: CGFloat = 64 + editorContainerHeightConstraint.constant
        UIView.animate(withDuration: 0.25) {
            self.view.transform = CGAffineTransform(translationX: 0, y: fullHeight)
        }
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

// TODO: Вынести в отдельный объект TransitionAnimator
extension TaskParameterEditorContainer: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInBackgroundModalTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeOutBackgroundModalTransition()
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

fileprivate extension TaskParameterEditorContainer {

    func setupEditor(for type: TaskParameterEditorType) {
        guard let viewController = output?.editorViewController(forType: type) else { return }
        
        // TODO: Вынести в отдельный метод
        addChildViewController(viewController)
        editorContainer.addSubview(viewController.view)
        viewController.view.autoPinEdgesToSuperviewEdges()
        viewController.didMove(toParentViewController: self)
        
        if let editorInput = viewController as? TaskParameterEditorInput {
            editorContainerHeightConstraint.constant = editorInput.requiredHeight
        }
        
        viewControllers.append(viewController)
    }

    func setEditorTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func pushPicker(type: TaskRepeatingPickerType, completion: @escaping (UIViewController) -> Void) {
        guard let viewController = output?.repeatingPickerViewController(forType: type) else { return }
                
        addChildViewController(viewController)
        
        let offset = editorContainer.frame.height
        if let editorInput = viewController as? TaskParameterEditorInput {
            editorContainerHeightConstraint.constant = editorInput.requiredHeight
        }
        
        if let fromView = editorContainer.subviews.first {
            editorContainer.addSubview(viewController.view)
            viewController.view.frame.origin.y = offset
            
            completion(viewController)
            
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            self.setEditorTitle(type.editorTitle)
                            self.closeButton.tintColor = AppTheme.current.backgroundColor
                            self.closeButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
                            fromView.transform = CGAffineTransform(translationX: 0, y: -offset)
                            viewController.view.frame.origin.y = 0
                            self.view.layoutIfNeeded()
            }, completion: { _ in
                fromView.removeFromSuperview()
                viewController.didMove(toParentViewController: self)
                self.viewControllers.append(viewController)
            })
        }
    }
    
    func popViewController() {
        guard let fromView = viewControllers.last else { return }
        guard let toView = viewControllers.item(at: viewControllers.count - 2) else { return }
        
        let offset = editorContainer.frame.height
        if let editorInput = toView as? TaskParameterEditorInput {
            editorContainerHeightConstraint.constant = editorInput.requiredHeight
        }
        
        editorContainer.addSubview(toView.view)
        toView.view.autoPinEdgesToSuperviewEdges()
        toView.view.transform = CGAffineTransform(translationX: 0, y: offset)
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.setEditorTitle(self.type.title)
                        self.closeButton.tintColor = AppTheme.current.redColor
                        self.closeButton.setImage(#imageLiteral(resourceName: "trash"), for: .normal)
                        toView.view.transform = CGAffineTransform(translationX: 0, y: 0)
                        fromView.view.transform = CGAffineTransform(translationX: 0, y: -offset)
                        self.view.layoutIfNeeded()
        }, completion: { _ in
            toView.view.autoPinEdgesToSuperviewEdges()
            fromView.view.removeFromSuperview()
            fromView.removeFromParentViewController()
            self.viewControllers.remove(object: fromView)
        })
    }
    
}
