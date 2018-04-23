//
//  MainTopViewController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class MainTopViewController: UIViewController {

    @IBOutlet private var overlayView: UIView!
    
    @IBOutlet private var listRepresentationContainer: UIView!
    
    @IBOutlet private var controlPanelContainer: UIView!
    
    @IBOutlet private var bottomContainer: UIView!
    @IBOutlet private var taskCreationPanelContainer: UIView!
    @IBOutlet private var groupEditingPanelContainer: UIView!
    
    @IBOutlet private var bottomContainerConstraint: NSLayoutConstraint!
    
    private var menuPanel: MenuPanelInput!
    private var taskCreationPanel: TaskCreationPanelInput!
    
    private let representationManager = ListRepresentationManager()
    
    private let editingModeController = EditingModeController()
    
    private let keyboardManager = KeyboardManager()
    
    private let tasksService = ServicesAssembly.shared.tasksService
    
    private lazy var router: MainRouterInput = {
        let router = MainRouter()
        router.transitionHandler = self
        return router
    }()
    
    private var currentList: List = SmartList(type: .all)
    
    private var isPickingList: Bool = false
    
    private var pickingListCompletion: ((List) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardManager()
        setupRepresentationManager()
        setupEditingModeController()
        menuPanel.showList(currentList)
        representationManager.setList(currentList)
        groupEditingPanelContainer.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLists" {
            guard let listsViewController = segue.destination as? ListsViewController else { return }
            listsViewController.output = self
            listsViewController.setCurrentList(currentList)
            listsViewController.setPickingList(isPickingList)
        } else if segue.identifier == "EmbedMenuPanel" {
            guard let menuPanel = segue.destination as? MenuPanelViewController else { return }
            menuPanel.output = self
            self.menuPanel = menuPanel
        } else if segue.identifier == "EmbedTaskCreationPanel" {
            guard let taskCreationPanel = segue.destination as? TaskCreationPanelViewController else { return }
            taskCreationPanel.output = self
            self.taskCreationPanel = taskCreationPanel
        } else if segue.identifier == "EmbedGroupEditingPanel" {
            guard let groupEditingPanel = segue.destination as? GroupEditingPanelViewController else { return }
            groupEditingPanel.output = editingModeController
            editingModeController.groupEditingPanel = groupEditingPanel
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func showLists(animated: Bool) {
        overlayView.isHidden = false
        menuPanel.hideControls(animated: animated)
        taskCreationPanel.setTaskTitleFieldFirstResponder(false)
        
        performSegue(withIdentifier: "ShowLists", sender: nil)
    }

}

extension MainTopViewController: ListsViewOutput {
    
    func didSelectList(_ list: List) {
        currentList = list
        menuPanel.showList(list)
        menuPanel.showControls(animated: true)
        representationManager.setList(list)
        if let smartList = list as? SmartList, smartList.smartListType == .important {
            taskCreationPanel.setImportancy(true)
        }
    }
    
    func didPickList(_ list: List) {
        pickingListCompletion?(list)
        menuPanel.showControls(animated: true)
        isPickingList = false
    }
    
    func didUpdateList(_ list: List) {
        currentList = list
        menuPanel.showList(list)
        representationManager.setList(list)
    }
    
    func didCreateList() {
        taskCreationPanel.setTaskTitleFieldFirstResponder(true)
    }
    
    func willClose() {
        menuPanel.showControls(animated: true)
        taskCreationPanel.setTaskTitleFieldFirstResponder(false)
    }
    
}

extension MainTopViewController: MenuPanelOutput {
    
    func didPressOnPanel() {
        guard editingModeController.editingMode == .default || isPickingList else { return }
        showLists(animated: true)
    }
    
    func didPressGroupEditingButton() {
        editingModeController.toggleEditingMode()
    }
    
}

extension MainTopViewController: TaskCreationPanelOutput {
    
    func didPressAddTaskButton() {
        if let title = taskCreationPanel.enteredTaskTitle {
            addShortTask(with: title,
                        dueDate: dateForTodaySmartList(),
                        inProgress: progressStateForInProgressSmartList(),
                        isImportant: taskCreationPanel.isImportancySelected,
                        listID: currentList.id)
        }
    }
    
    func didPressCreateTaskButton() {
        if let title = taskCreationPanel.enteredTaskTitle, !title.isEmpty {
            router.showTaskEditor(with: title, list: currentList, output: self)
        } else {
            router.showTaskEditor(with: nil, list: currentList, output: self)
        }
    }
    
}

extension MainTopViewController: EditingModeControllerOutput {
    
    func performGroupEditingAction(_ action: TargetGroupEditingAction) {
        representationManager.currentListRepresentationInput?.performGroupEditingAction(action)
    }
    
    func performEditingModeChange(to mode: ListRepresentationEditingMode) {
        groupEditingPanelContainer.isHidden = mode == .default
        taskCreationPanelContainer.isHidden = mode == .group
        taskCreationPanel.setTaskTitleFieldFirstResponder(false)
        UIView.animate(withDuration: 0.33, animations: {
            self.taskCreationPanelContainer.alpha = mode == .group ? 0 : 1
        })
        representationManager.currentListRepresentationInput?.setEditingMode(mode) {
            self.menuPanel.setGroupEditingButtonEnabled(true)
            self.menuPanel.changeGroupEditingState(to: mode == .group)
        }
    }
    
    func showListsForMoveTasks(completion: @escaping (List) -> Void) {
        isPickingList = true
        pickingListCompletion = completion
        showLists(animated: true)
    }
    
}

extension MainTopViewController: ListRepresentationManagerOutput {
    
    func configureListRepresentation(_ representation: ListRepresentationInput) {
        representation.editingOutput = editingModeController
    }
    
}

extension MainTopViewController: ListRepresentationOutput {
    
    func tasksCountChanged(count: Int) {
        menuPanel.setGroupEditingButtonVisible(count > 0)
    }
    
    func groupEditingOperationCompleted() {
        editingModeController.groupEditingPanel.setActionsEnabled(false)
    }
    
    func didPressEdit(for task: Task) {
        router.showTaskEditor(with: task, list: currentList, output: self)
    }
    
}

extension MainTopViewController: TaskEditorOutput {
    
    func taskCreated() {
        taskCreationPanel.clearTaskTitleInput()
    }
    
}

private extension MainTopViewController {
    
    func setupRepresentationManager() {
        representationManager.output = self
        representationManager.listRepresentationOutput = self
        representationManager.containerViewController = self
        representationManager.listsContainerView = listRepresentationContainer
        representationManager.setRepresentation(.table, animated: false)
    }
    
    func setupEditingModeController() {
        editingModeController.output = self
    }
    
    func setupKeyboardManager() {
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
    
    func addShortTask(with title: String, dueDate: Date?, inProgress: Bool, isImportant: Bool, listID: String) {
        let task = Task(id: RandomStringGenerator.randomString(length: 24),
                        title: title)
        
        if let dueDate = dueDate {
            task.dueDate = dueDate
        }
        task.inProgress = inProgress
        task.isImportant = isImportant
        
        tasksService.addTask(task, listID: listID, completion: { _ in })
    }
    
}

private extension MainTopViewController {
    
    func dateForTodaySmartList() -> Date? {
        if let smartList = currentList as? SmartList, smartList.smartListType == .today {
            let startOfNextHour = Date().startOfHour + 1.asHours
            return startOfNextHour
        }
        return nil
    }
    
    func progressStateForInProgressSmartList() -> Bool {
        if let smartList = currentList as? SmartList, smartList.smartListType == .inProgress {
            return true
        }
        return false
    }
    
}
