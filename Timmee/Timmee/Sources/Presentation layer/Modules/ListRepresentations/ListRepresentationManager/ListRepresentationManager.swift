//
//  ListRepresentationManager.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIView
import PureLayout

final class ListRepresentationManager {

    weak var containerViewController: UIViewController!
    weak var listsContainerView: UIView!
    
    fileprivate var representation: ListRepresentation = .table
    
    fileprivate var currentListRepresentationInput: ListRepresentationInput?
    
    fileprivate var currentList: List?

}

extension ListRepresentationManager: ListRepresentationManagerInput {

    func setRepresentation(_ representation: ListRepresentation, animated: Bool) {
        performRepresentationChange(to: representation, animated: animated)
        self.representation = representation
    }
    
    func setList(_ list: List) {
        currentList = list
        currentListRepresentationInput?.setList(list: list)
    }
    
    func forceTaskCreation() {
        currentListRepresentationInput?.forceTaskCreation()
    }

}

extension ListRepresentationManager: ListRepresentationOutput {

    func didAskToShowTaskEditor(with taskTitle: String) {
        showTaskEditor(with: taskTitle)
    }
    
    func didAskToShowTaskEditor(with task: Task?) {
        showTaskEditor(with: task)
    }

}

extension ListRepresentationManager: TaskEditorOutput {

    func taskCreated() {
        currentListRepresentationInput?.clearInput()
    }

}

fileprivate extension ListRepresentationManager {

    func performRepresentationChange(to: ListRepresentation, animated: Bool) {
        let newPresentation: ListRepresentationInput
        switch to {
        case .table:
            let view = ViewControllersFactory.tableListRepresentation
            
            containerViewController.addChildViewController(view)
            
            newPresentation = TableListRepresentationAssembly.assembly(with: view,
                                                                       output: self)
            
            view.loadViewIfNeeded()
        case .eisenhower:
            newPresentation = "" as! ListRepresentationInput
        }
        
        let toView = newPresentation.viewController.view!

        guard let currentRepresentation = currentListRepresentationInput else {
            listsContainerView.addSubview(toView)
            newPresentation.viewController.didMove(toParentViewController: containerViewController)
            self.layoutRepresentationView(toView)
            currentListRepresentationInput = newPresentation
            return
        }
        
        let fromView = currentRepresentation.viewController.view
        
        let transition = {
            fromView?.removeFromSuperview()
            self.listsContainerView.addSubview(toView)
            self.layoutRepresentationView(toView)
        }
        
        let completion = { (finished: Bool) in
            if finished {
                self.currentListRepresentationInput = newPresentation
                newPresentation.viewController.didMove(toParentViewController: self.containerViewController)
            }
        }
        
        if animated {
            UIView.transition(with: listsContainerView,
                              duration: 0.35,
                              options: .transitionFlipFromBottom,
                              animations: transition,
                              completion: completion)
        } else {
            transition()
            newPresentation.viewController.didMove(toParentViewController: containerViewController)
            currentListRepresentationInput = newPresentation
        }
    }
    
    func layoutRepresentationView(_ view: UIView) {
        view.autoPinEdgesToSuperviewEdges()
    }
    
    func showTaskEditor(with task: Task?) {
        showTaskEditor { taskEditorInput in
            taskEditorInput.setTask(task)
        }
    }
    
    func showTaskEditor(with taskTitle: String) {
        showTaskEditor { taskEditorInput in
            taskEditorInput.setTask(nil)
            taskEditorInput.setTaskTitle(taskTitle)
        }
    }
    
    private func showTaskEditor(configuration: (TaskEditorInput) -> Void) {
        let taskEditorView = ViewControllersFactory.taskEditor
        taskEditorView.loadViewIfNeeded()
        
        let taskEditorInput = TaskEditorAssembly.assembly(with: taskEditorView)
        taskEditorInput.output = self
        taskEditorInput.setListID(currentList?.id)
        
        configuration(taskEditorInput)
        
        if let smartList = currentList as? SmartList, smartList.smartListType == .today {
            taskEditorInput.setDueDate(Date.startOfNextHour)
        }
        
        containerViewController.present(taskEditorView, animated: true, completion: nil)
    }

}
