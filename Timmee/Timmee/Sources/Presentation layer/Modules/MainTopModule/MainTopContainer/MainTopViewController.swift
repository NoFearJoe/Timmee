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
    
    private var menuPanel: MenuPanelInput!
    private var taskCreationPanel: TaskCreationPanelInput!
    private var groupEditingPanel: GroupEditingPanelInput!
    
    private let representationManager = ListRepresentationManager()
    
    private lazy var router: MainRouterInput = {
        let router = MainRouter()
        router.transitionHandler = self
        return router
    }()
    
    weak var editingInput: TableListRepresentationEditingInput?
    
    private var currentList: List = SmartList(type: .all)
    
    private var isGroupEditing: Bool = false
    private var isPickingList: Bool = false
    
    private var pickingListCompletion: ((List) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRepresentationManager()
        menuPanel.showList(currentList)
        representationManager.setList(currentList)
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
            groupEditingPanel.output = self
            self.groupEditingPanel = groupEditingPanel
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
    }
    
    func didPickList(_ list: List) {
        pickingListCompletion?(list)
        menuPanel.showControls(animated: true)
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

extension MainTopViewController: ListRepresentationEditingOutput {
    
    func groupEditingWillToggle(to isEditing: Bool) {
        guard isEditing else { return }
        isGroupEditing = true
    }
    
    func groupEditingToggled(to isEditing: Bool) {
        isGroupEditing = isEditing
        menuPanel.setGroupEditingButtonEnabled(true)
        menuPanel.changeGroupEditingState(to: isEditing)
    }
    
    func didAskToShowListsForMoveTasks(completion: @escaping (List) -> Void) {
        isPickingList = true
        pickingListCompletion = completion
        showLists(animated: true)
    }
    
    func setGroupEditingVisible(_ isVisible: Bool) {
        menuPanel.setGroupEditingButtonVisible(isVisible)
    }
    
}

extension MainTopViewController: MenuPanelOutput {
    
    func didPressOnPanel() {
        guard !isGroupEditing || isPickingList else { return }
        showLists(animated: true)
    }
    
    func didPressGroupEditingButton() {
        editingInput?.setEditingMode(.default) // TODO
    }
    
}

extension MainTopViewController: TaskCreationPanelOutput {
    
    func didUpdateTaskTitle(to title: String) {
        
    }
    
    func didPressAddTaskButton() {
        
    }
    
    func didPressCreateTaskButton() {
        
    }
    
}

extension MainTopViewController: GroupEditingPanelOutput {
    
    func didSelectGroupEditingAction(_ action: GroupEditingAction) {
        
    }
    
}

extension MainTopViewController: ListRepresentationManagerOutput {
    
    func configureListRepresentation(_ representation: ListRepresentationInput) {
        representation.editingOutput = self
    }
    
}

extension MainTopViewController: ListRepresentationOutput {
    
    func tasksCountChanged(count: Int) {
        
    }
    
    func groupEditingOperationCompleted() {
        
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
    
}
