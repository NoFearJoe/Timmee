//
//  TableListRepresentationView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol TableListRepresentationViewInput: class {
    func showNoTasksPlaceholder()
    func hideNoTasksPlaceholder()
    
    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool)
    func clearTaskTitleInput()
    
    func toggleGroupEditing()
    func setGroupEditingActionsEnabled(_ isEnabled: Bool)
    func setCompletionGroupEditingAction(_ action: GroupEditingCompletionAction)
    
    func connect(with tableViewManagable: TableViewManageble)
    
    func resetOffset()
    
    func setInteractionsEnabled(_ isEnabled: Bool)
    
    func showConfirmationAlert(title: String, message: String, confirmationTitle: String, success: @escaping () -> Void)
}

protocol TableListRepresentationViewOutput: class {
    func viewDidLoad()
    func viewWillAppear()
    
    func didToggleImportancyInShortTaskEditor(to isImportant: Bool)
    func didInputTaskTitle(_ title: String?)
    func didPressAddTaskButton()
    func didPressMoreButton()
    
    func didPressEdit(for task: Task)
    func didPressDelete(task: Task)
    func didPressComplete(task: Task)
    func didPressStart(task: Task)
    func didPressStop(task: Task)
    
    func toggleImportancy(of task: Task)
    
    func didCheckTask(_ task: Task)
    func didUncheckTask(_ task: Task)
    func taskIsChecked(_ task: Task) -> Bool
    
    func groupEditingToggled(to isEditing: Bool)
    func didSelectGroupEditingAction(_ action: GroupEditingAction)
}

protocol TableListRepresentationViewDataSource: class {
    func sectionsCount() -> Int
    func itemsCount(in section: Int) -> Int
    func item(at index: Int, in section: Int) -> Task?
    func sectionInfo(forSectionAt index: Int) -> (name: String, numberOfItems: Int)?
    func sectionInfo(forSectionWithName name: String) -> (name: String, numberOfItems: Int)?
    func totalObjectsCount() -> Int
}

final class TableListRepresentationView: UIViewController {

    weak var dataSource: TableListRepresentationViewDataSource!
    var output: TableListRepresentationViewOutput!
    
    @IBOutlet fileprivate var tableContainerView: UIView!
    @IBOutlet fileprivate var tableView: UITableView!
    
    @IBOutlet fileprivate var shortTaskEditorView: UIView!
    @IBOutlet fileprivate var importancyView: UIImageView!
    @IBOutlet fileprivate var newTaskTitleTextField: UITextField!
    @IBOutlet fileprivate var rightBarButton: UIButton!
    
    @IBOutlet fileprivate var groupEditingActionsView: GroupEditingActionsView!
    
    @IBOutlet fileprivate var bottomContainerConstraint: NSLayoutConstraint!
    
    fileprivate lazy var placeholder: PlaceholderView = PlaceholderView.loadedFromNib()
    
    fileprivate let swipeTableActionsProvider = SwipeTaskActionsProvider()
    
    fileprivate let keyboardManager = KeyboardManager()
    
    fileprivate var isTaskTitleEntered: Bool {
        if let text = newTaskTitleTextField.text, !text.isEmpty,
           newTaskTitleTextField.isFirstResponder {
            return true
        }
        return false
    }
    
    var isGroupEditing: Bool = false {
        didSet {
            tableView.hideSwipeCell(animated: true)
            tableView.visibleCells
                .map { $0 as! TableListRepresentationCell }
                .forEach {
                    $0.setGroupEditing(isGroupEditing, animated: true)
                    $0.delegate = isGroupEditing ? nil : swipeTableActionsProvider
                    
                    if isGroupEditing {
                        $0.isChecked = false
                    }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlaceholder()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "TableListRepresentationCell", bundle: nil),
                           forCellReuseIdentifier: "TableListRepresentationCell")
        tableView.register(TableListRepresentationFooter.self,
                           forHeaderFooterViewReuseIdentifier: "TableListRepresentationFooter")
        
        swipeTableActionsProvider.onDelete = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                self.output.didPressDelete(task: task)
            }
        }
        swipeTableActionsProvider.onStart = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                self.output.didPressStart(task: task)
            }
        }
        swipeTableActionsProvider.onStop = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                self.output.didPressStop(task: task)
            }
        }
        swipeTableActionsProvider.onDone = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                self.output.didPressComplete(task: task)
            }
        }
        swipeTableActionsProvider.isDone = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                return task.isDone
            }
            return false
        }
        swipeTableActionsProvider.progressActionForRow = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                if task.isDone { return .none }
                else { return task.inProgress ? .stop : .start }
            }
            return .none
        }
        
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
        
        groupEditingActionsView.onAction = { [unowned self] action in
            self.output.didSelectGroupEditingAction(action)
        }
        
        addTapGestureRecognizerToImportancyView()
        subscribeToTaskTitleChange()
        output.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableContainerView.backgroundColor = AppTheme.current.middlegroundColor
        
        newTaskTitleTextField.textColor = AppTheme.current.backgroundTintColor
        newTaskTitleTextField.tintColor = AppTheme.current.backgroundTintColor.withAlphaComponent(0.75)
        newTaskTitleTextField.attributedPlaceholder = "new_task".localized.asPlaceholder
        
        rightBarButton.tintColor = AppTheme.current.blueColor
        
        groupEditingActionsView.setVisible(false, animated: false)
        
        tableView.reloadData()

        output.viewWillAppear()
    }
    
    @IBAction fileprivate func rightBarButtonPressed() {
        if isTaskTitleEntered {
            if let text = newTaskTitleTextField.text {
                output.didInputTaskTitle(text)
                output.didPressAddTaskButton()
                
                clearTaskTitleInput()
            }
        } else {
            output.didPressMoreButton()
        }
    }

}

extension TableListRepresentationView: TableListRepresentationViewInput {
    
    func showNoTasksPlaceholder() {
        guard placeholder.isHidden else { return }
        self.placeholder.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 1
        }, completion: { _ in
            self.placeholder.isHidden = false
        })
    }
    
    func hideNoTasksPlaceholder() {
        guard !placeholder.isHidden else { return }
        self.placeholder.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 0
        }, completion: { _ in
            self.placeholder.isHidden = true
        })
    }
    
    func clearTaskTitleInput() {
        newTaskTitleTextField.text = nil
        updateRightBarButton()
    }
    
    func toggleGroupEditing() {
        isGroupEditing = !isGroupEditing
        newTaskTitleTextField.resignFirstResponder()
        groupEditingActionsView.setEnabled(false)
        groupEditingActionsView.setVisible(isGroupEditing, animated: true)
        UIView.animate(withDuration: 0.33, animations: {
            self.shortTaskEditorView.alpha = self.isGroupEditing ? 0 : 1
        }) { _ in
            self.output.groupEditingToggled(to: self.isGroupEditing)
        }
    }
    
    func setGroupEditingActionsEnabled(_ isEnabled: Bool) {
        groupEditingActionsView.setEnabled(isEnabled)
    }
    
    func setCompletionGroupEditingAction(_ action: GroupEditingCompletionAction) {
        groupEditingActionsView.updateAction(.complete,
                                             withTitle: action.title,
                                             andImage: action.image)
    }
    
    func connect(with tableViewManagable: TableViewManageble) {
        tableViewManagable.setTableView(tableView)
    }
    
    func resetOffset() {
        if dataSource.totalObjectsCount() > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func setInteractionsEnabled(_ isEnabled: Bool) {
        tableView.isUserInteractionEnabled = isEnabled
    }

    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool) {
        if isFirstResponder && !newTaskTitleTextField.isFirstResponder {
            newTaskTitleTextField.becomeFirstResponder()
        } else if newTaskTitleTextField.isFirstResponder {
            newTaskTitleTextField.resignFirstResponder()
        }
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

extension TableListRepresentationView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sectionsCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.itemsCount(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableListRepresentationCell",
                                                 for: indexPath) as! TableListRepresentationCell
        
        if let task = dataSource.item(at: indexPath.row, in: indexPath.section) {
            cell.setTask(task)
            
            cell.setGroupEditing(isGroupEditing)
            
            cell.isChecked = output.taskIsChecked(task)
            
            cell.onTapToImportancy = { [unowned self] in
                guard let indexPath = tableView.indexPath(for: cell) else { return }
                if let task = self.dataSource.item(at: indexPath.row, in: indexPath.section) {
                    self.output.toggleImportancy(of: task)
                }
            }
            
            cell.onCheck = { [unowned self] isChecked in
                if isChecked { self.output.didCheckTask(task) }
                else { self.output.didUncheckTask(task) }
            }
        }
        
        cell.delegate = isGroupEditing ? nil : swipeTableActionsProvider
        
        return cell
    }

}

extension TableListRepresentationView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isGroupEditing else { return }
        if let task = dataSource.item(at: indexPath.row, in: indexPath.section) {
            output.didPressEdit(for: task)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            // Если это секция незавершенных задач && есть секция завершенных задач и секция завершенных задач не пустая -> показывать кнопку
        if let sectionInfo = dataSource.sectionInfo(forSectionAt: section), sectionInfo.name == "1", sectionInfo.numberOfItems > 0 {
            return 40
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 56
        
        if let item = dataSource.item(at: indexPath.row, in: indexPath.section) {
            if item.isDone { height -= 15 }
            if item.tags.count > 0 { height += 6 }
            return height
        }
        return height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            // Если это секция незавершенных задач && есть секция завершенных задач и секция завершенных задач не пустая -> показывать кнопку
            if let sectionInfo = dataSource.sectionInfo(forSectionAt: section), sectionInfo.name == "1", sectionInfo.numberOfItems > 0 {
                let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableListRepresentationFooter") as! TableListRepresentationFooter
                
                view.title = "Завершенные задачи"
                
                view.applyAppearance()
                
                return view
            }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? TableListRepresentationCell)?.applyAppearance()
    }

}

extension TableListRepresentationView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return !isGroupEditing
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateRightBarButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.trimmed.isEmpty {
            output.didInputTaskTitle(text)
            output.didPressAddTaskButton()
            
            clearTaskTitleInput()
            
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        output.didInputTaskTitle(textField.text)
        updateRightBarButton()
    }
    
}

fileprivate extension TableListRepresentationView {

    func subscribeToTaskTitleChange() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(taskTitleDidChange),
                                               name: .UITextFieldTextDidChange,
                                               object: nil)
    }
    
    func updateRightBarButton() {
        if isTaskTitleEntered {
            rightBarButton.setImage(UIImage(named: "checkmark"), for: .normal)
        } else {
            rightBarButton.setImage(UIImage(named: "plus"), for: .normal)
        }
    }
    
    @objc func taskTitleDidChange() {
        updateRightBarButton()
    }
    
    func setupPlaceholder() {
        placeholder.setup(into: tableContainerView)
        placeholder.icon = #imageLiteral(resourceName: "faceIDBig")
        placeholder.title = "no_tasks".localized
        placeholder.subtitle = "no_tasks_hint".localized
        placeholder.isHidden = true
    }
    
    func addTapGestureRecognizerToImportancyView() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleImportancy))
        importancyView.addGestureRecognizer(recognizer)
    }
    
    @objc func toggleImportancy() {
        importancyView.isHighlighted = !importancyView.isHighlighted
        output.didToggleImportancyInShortTaskEditor(to: importancyView.isHighlighted)
    }

}

final class TableListRepresentationFooter: UITableViewHeaderFooterView {

    fileprivate var button: UIButton!
    
    var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }
    
    var onTap: (() -> Void)?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addButton()
        applyAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addButton()
        applyAppearance()
    }
    
    fileprivate func addButton() {
        button = UIButton(frame: .zero)
        self.addSubview(button)
        button.height(32)
        button.centerY().to(self)
        button.centerX().toSuperview()
        button.backgroundColor = AppTheme.current.middlegroundColor
        button.setTitleColor(AppTheme.current.secondaryTintColor, for: .normal)
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    
    @objc fileprivate func tap() {
        onTap?()
    }
    
    func applyAppearance() {
        contentView.backgroundColor = .clear
        backgroundView = UIView()
    }

}

