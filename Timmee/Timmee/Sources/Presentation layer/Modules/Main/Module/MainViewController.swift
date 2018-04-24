//
//  MainViewController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class MainViewController: UIViewController {
    
    @IBOutlet private var listRepresentationContainer: UIView!
        
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
    
    private var state = State()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToApplicationEvents()
        setupKeyboardManager()
        setupRepresentationManager()
        setupEditingModeController()
        menuPanel.showList(state.currentList)
        representationManager.setList(state.currentList)
        groupEditingPanelContainer.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = AppTheme.current.backgroundColor
        
        tasksService.updateTasksDueDates()
    }
    
    @objc private func didBecomeActive() {
        tasksService.updateTasksDueDates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedMenuPanel" {
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

}

extension MainViewController: ListsViewOutput {
    
    func didSelectList(_ list: List) {
        state.currentList = list
        menuPanel.showList(list)
        menuPanel.showControls(animated: true)
        representationManager.setList(list)
        if let smartList = list as? SmartList, smartList.smartListType == .important {
            taskCreationPanel.setImportancy(true)
        }
    }
    
    func didPickList(_ list: List) {
        state.pickingListCompletion?(list)
        menuPanel.showControls(animated: true)
        state.isPickingList = false
    }
    
    func didUpdateList(_ list: List) {
        state.currentList = list
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

extension MainViewController: MenuPanelOutput {
    
    func didPressOnPanel() {
        guard editingModeController.editingMode == .default || state.isPickingList else { return }
        showLists(animated: true)
    }
    
    func didPressGroupEditingButton() {
        editingModeController.toggleEditingMode()
    }
    
}

extension MainViewController: TaskCreationPanelOutput {
    
    func didPressAddTaskButton() {
        if let title = taskCreationPanel.enteredTaskTitle {
            addShortTask(with: title,
                        dueDate: dateForTodaySmartList(),
                        inProgress: progressStateForInProgressSmartList(),
                        isImportant: taskCreationPanel.isImportancySelected,
                        listID: state.currentList.id)
        }
    }
    
    func didPressCreateTaskButton() {
        if let title = taskCreationPanel.enteredTaskTitle, !title.isEmpty {
            router.showTaskEditor(with: title, list: state.currentList, output: self)
        } else {
            router.showTaskEditor(with: nil, list: state.currentList, output: self)
        }
    }
    
}

extension MainViewController: EditingModeControllerOutput {
    
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
        state.isPickingList = true
        state.pickingListCompletion = completion
        showLists(animated: true)
    }
    
}

extension MainViewController: ListRepresentationManagerOutput {
    
    func configureListRepresentation(_ representation: ListRepresentationInput) {
        representation.editingOutput = editingModeController
    }
    
}

extension MainViewController: ListRepresentationOutput {
    
    func tasksCountChanged(count: Int) {
        menuPanel.setGroupEditingButtonVisible(count > 0)
    }
    
    func groupEditingOperationCompleted() {
        editingModeController.groupEditingPanel.setActionsEnabled(false)
    }
    
    func didPressEdit(for task: Task) {
        router.showTaskEditor(with: task, list: state.currentList, output: self)
    }
    
}

extension MainViewController: TaskEditorOutput {
    
    func taskCreated() {
        taskCreationPanel.clearTaskTitleInput()
    }
    
}

private extension MainViewController {
    
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
    
    func subscribeToApplicationEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    func showLists(animated: Bool) {
        menuPanel.hideControls(animated: animated)
        taskCreationPanel.setTaskTitleFieldFirstResponder(false)
        
        let listsViewController = ViewControllersFactory.lists
        listsViewController.output = self
        listsViewController.setCurrentList(state.currentList)
        listsViewController.setPickingList(state.isPickingList)
        present(listsViewController, animated: true, completion: nil)
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

private extension MainViewController {
    
    func dateForTodaySmartList() -> Date? {
        if let smartList = state.currentList as? SmartList, smartList.smartListType == .today {
            let startOfNextHour = Date().startOfHour + 1.asHours
            return startOfNextHour
        }
        return nil
    }
    
    func progressStateForInProgressSmartList() -> Bool {
        if let smartList = state.currentList as? SmartList, smartList.smartListType == .inProgress {
            return true
        }
        return false
    }
    
}