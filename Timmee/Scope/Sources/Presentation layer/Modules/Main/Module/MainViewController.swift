//
//  MainViewController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit
import StoreKit

final class MainViewController: UIViewController {
    
    @IBOutlet private var listRepresentationContainer: UIView!
        
    @IBOutlet private var bottomContainer: UIView!
    @IBOutlet private var taskCreationPanelContainer: UIView!
    @IBOutlet private var groupEditingPanelContainer: UIView!
    
    @IBOutlet private var dimmedBackgroundView: UIView!
    
    @IBOutlet private var bottomContainerConstraint: NSLayoutConstraint!
    
    private var menuPanel: MenuPanelInput!
    private var taskCreationPanel: TaskCreationPanelInput!
    private var temporaryActionPanel: TemporaryActionPanelInput!
    
    private lazy var representationManager: ListRepresentationManagerInput = {
        let manager = ListRepresentationManager()
        setupRepresentationManager(manager)
        return manager
    }()
    
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
        setupAppLaunchTracker()
        setupKeyboardManager()
        setupEditingModeController()
        subscribeToApplicationDidBecomeActive()
        
        representationManager.setRepresentation(.table, animated: false)
        
        menuPanel.showList(state.currentList)
        groupEditingPanelContainer.isHidden = true
        
        Trackers.appLaunchTracker?.commit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = AppTheme.current.backgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performGlobalRouting()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedMenuPanel" {
            guard let menuPanel = segue.destination as? MenuPanelViewController else { return }
            menuPanel.output = self
            self.menuPanel = menuPanel
        } else if segue.identifier == "EmbedTaskCreationPanel" {
            guard let taskCreationPanel = segue.destination as? TaskCreationPanelViewController else { return }
            taskCreationPanel.output = self
            taskCreationPanel.containerView = view
            taskCreationPanel.taskCreationMenuAnchorView = bottomContainer
            taskCreationPanel.dimmedBackgroundView = dimmedBackgroundView
            self.taskCreationPanel = taskCreationPanel
        } else if segue.identifier == "EmbedGroupEditingPanel" {
            guard let groupEditingPanel = segue.destination as? GroupEditingPanelViewController else { return }
            groupEditingPanel.output = editingModeController
            editingModeController.groupEditingPanel = groupEditingPanel
        } else if segue.identifier == "EmbedTemporaryActionPanel" {
            guard let temporaryActionPanel = segue.destination as? TemporaryActionPanelViewController else { return }
            temporaryActionPanel.output = self
            self.temporaryActionPanel = temporaryActionPanel
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension MainViewController: ListsViewOutput {
    
    func didSelectList(_ list: List) {
        state.currentList = list
        menuPanel.showList(list)
        menuPanel.showControls(animated: true)
        representationManager.currentListRepresentationInput.setList(list: list)
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
        representationManager.currentListRepresentationInput.setList(list: list)
    }
    
    func didCreateList() {
        taskCreationPanel.setTaskTitleFieldFirstResponder(true)
    }
    
    func didClose() {
        menuPanel.showControls(animated: true)
        state.isPickingList = false
    }
    
}

extension MainViewController: MenuPanelOutput {
    
    func didPressOnPanel() {
        guard editingModeController.editingMode == .default || state.isPickingList else { return }
        showLists(animated: true)
    }
    
    func didPressGroupEditingButton() {
        editingModeController.toggleEditingMode()
        representationManager.currentListRepresentationInput.prepareToGroupEditing()
    }
    
}

extension MainViewController: TaskCreationPanelOutput {
    
    func didPressAddTaskButton() {
        if let title = taskCreationPanel.enteredTaskTitle {
            addShortTask(with: title,
                        dueDate: state.currentList.defaultDueDate,
                        inProgress: progressStateForInProgressSmartList(),
                        isImportant: taskCreationPanel.isImportancySelected,
                        listID: state.currentList.id,
                        tags: tagsForCurrentSmartList())
        }
    }
    
    func didPressCreateTaskButton(taskKind: Task.Kind) {
        if let title = taskCreationPanel.enteredTaskTitle.nilIfEmpty {
            router.showTaskEditor(with: title,
                                  list: state.currentList,
                                  taskKind: taskKind,
                                  isImportant: taskCreationPanel.isImportancySelected,
                                  tags: tagsForCurrentSmartList(),
                                  output: self)
        } else {
            router.showTaskEditor(with: nil,
                                  list: state.currentList,
                                  taskKind: taskKind,
                                  isImportant: taskCreationPanel.isImportancySelected,
                                  tags: tagsForCurrentSmartList(),
                                  output: self)
        }
    }
    
}

extension MainViewController: TemporaryActionPanelOutput {
    
    func didSelectAction(_ action: TemporaryAction) {
        switch action {
        case .rollback: break
        case let .showList(list):
            didSelectList(list)
        }
    }
    
}

extension MainViewController: EditingModeControllerOutput {
    
    func performGroupEditingAction(_ action: TargetGroupEditingAction) {
        representationManager.currentListRepresentationInput?.performGroupEditingAction(action) { [weak self] affectedTasks in
            switch action {
            case let .move(list):
                self?.temporaryActionPanel.show(action: .showList(list), deadline: 5)
            default: break
            }
        }
    }
    
    func performEditingModeChange(to mode: ListRepresentationEditingMode) {
        groupEditingPanelContainer.isHidden = mode == .default
        taskCreationPanelContainer.isHidden = mode == .group
        taskCreationPanel.setTaskTitleFieldFirstResponder(false)
        UIView.animate(withDuration: 0.33, animations: {
            self.taskCreationPanelContainer.alpha = mode == .group ? 0 : 1
        })
        menuPanel.setNotGroupEditingControlsHidden(mode == .group)
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
        representation.setList(list: state.currentList)
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
        router.showTaskEditor(with: task,
                              list: state.currentList,
                              taskKind: task.kind,
                              isImportant: taskCreationPanel.isImportancySelected,
                              tags: task.tags,
                              output: self)
    }
    
}

extension MainViewController: TaskEditorOutput {
    
    func taskCreated() {
        taskCreationPanel.clearTaskTitleInput()
    }
    
}

private extension MainViewController {
    
    func setupRepresentationManager(_ representationManager: ListRepresentationManager) {
        representationManager.output = self
        representationManager.listRepresentationOutput = self
        representationManager.containerViewController = self
        representationManager.listsContainerView = listRepresentationContainer
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
    
    func subscribeToApplicationDidBecomeActive() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc private func onApplicationDidBecomeActive() {
        performGlobalRouting()
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
    
    func addShortTask(with title: String, dueDate: Date?, inProgress: Bool, isImportant: Bool, listID: String, tags: [Tag]) {
        let task = Task(id: RandomStringGenerator.randomString(length: 24),
                        title: title)
        
        if let dueDate = dueDate {
            task.dueDate = dueDate
        }
        task.inProgress = inProgress
        task.isImportant = isImportant
        task.tags = tags
        
        tasksService.addTask(task, listID: listID, completion: { _ in })
    }
    
}

private extension MainViewController {
    
    func progressStateForInProgressSmartList() -> Bool {
        if let smartList = state.currentList as? SmartList, smartList.smartListType == .inProgress {
            return true
        }
        return false
    }
    
    func tagsForCurrentSmartList() -> [Tag] {
        if let smartList = state.currentList as? SmartList, case .tag(let tag) = smartList.smartListType {
            return [tag]
        }
        return []
    }
    
    func setupAppLaunchTracker() {
        Trackers.appLaunchTracker?.checkpoint = {
            guard #available(iOS 10.3, *) else { return }
            SKStoreReviewController.requestReview()
        }
    }
    
}

// MARK: - Global routing

private extension MainViewController {
    
    func performGlobalRouting() {
        switch GlobalRoutingManager.shared.currentTarget {
        case let .taskEditor(kind)?:
            GlobalRoutingManager.shared.currentTarget = nil
            router.showTaskEditor(with: nil,
                                  list: state.currentList,
                                  taskKind: kind,
                                  isImportant: taskCreationPanel.isImportancySelected,
                                  tags: tagsForCurrentSmartList(),
                                  output: self)
        default: break
        }
    }
    
}
