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
    
    func setTaskTitleFieldFirstResponder()
    func clearTaskTitleInput()
    
    func connect(with tableViewManagable: TableViewManageble)
    
    func reloadCompletedTasks()
    
    func resetOffset()
    
    func setInteractionsEnabled(_ isEnabled: Bool)
}

protocol TableListRepresentationViewOutput: class {
    func viewDidLoad()
    func viewWillAppear()
    
    func didInputTaskTitle(_ title: String?)
    func didPressAddTaskButton()
    func didPressMoreButton()
    func didPressEdit(for task: Task)
    func didPressDelete(task: Task)
    func didPressComplete(task: Task)
    
    func toggleCompletedTasksVisibility()
    func isCompletedTasksVisible() -> Bool
    
    func toggleImportancy(of task: Task)
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
    
    @IBOutlet fileprivate weak var tableContainerView: BarView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    @IBOutlet fileprivate weak var newTaskTitleTextField: UITextField!
    @IBOutlet fileprivate weak var rightBarButton: UIButton!
    
    fileprivate lazy var placeholder: PlaceholderView = PlaceholderView.loadedFromNib()
    
    fileprivate let swipeTableActionsProvider = SwipeTaskActionsProvider()
    
    fileprivate var isTaskTitleEntered: Bool {
        if let text = newTaskTitleTextField.text, !text.isEmpty,
           newTaskTitleTextField.isFirstResponder {
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlaceholder()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(TableListRepresentationFooter.self,
                           forHeaderFooterViewReuseIdentifier: "TableListRepresentationFooter")
        
        swipeTableActionsProvider.onDelete = { [weak self] indexPath in
            if let task = self?.dataSource?.item(at: indexPath.row, in: indexPath.section) {
                self?.output.didPressDelete(task: task)
            }
        }
        swipeTableActionsProvider.onEdit = { [weak self] indexPath in
            if let task = self?.dataSource?.item(at: indexPath.row, in: indexPath.section) {
                self?.output.didPressEdit(for: task)
            }
        }
        swipeTableActionsProvider.onDone = { [weak self] indexPath in
            if let task = self?.dataSource?.item(at: indexPath.row, in: indexPath.section) {
                self?.output.didPressComplete(task: task)
            }
        }
        swipeTableActionsProvider.isDone = { [weak self] indexPath in
            if let task = self?.dataSource.item(at: indexPath.row, in: indexPath.section) {
                return task.isDone
            }
            return false
        }
        
        subscribeToTaskTitleChange()
        output.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableContainerView.barColor = AppTheme.current.scheme.backgroundColor
        
        newTaskTitleTextField.textColor = AppTheme.current.scheme.backgroundColor
        newTaskTitleTextField.tintColor = AppTheme.current.scheme.backgroundColor.withAlphaComponent(0.75)
        newTaskTitleTextField.attributedPlaceholder = NSAttributedString(string: "new_task".localized,
                                                                         attributes:
        [
            NSForegroundColorAttributeName: AppTheme.current.scheme.backgroundColor.withAlphaComponent(0.5)
        ])
        
        rightBarButton.tintColor = AppTheme.current.scheme.blueColor

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
    
    func connect(with tableViewManagable: TableViewManageble) {
        tableViewManagable.setTableView(tableView)
    }
    
    func reloadCompletedTasks() {
        let section0 = dataSource.sectionInfo(forSectionWithName: "0")
        let section1 = dataSource.sectionInfo(forSectionWithName: "1")
        
        UIView.performWithoutAnimation {
            if section0 != nil && section1 != nil {
                self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
            } else if section1 != nil {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
    }
    
    func resetOffset() {
        if dataSource.totalObjectsCount() > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func setInteractionsEnabled(_ isEnabled: Bool) {
        view.isUserInteractionEnabled = isEnabled
    }

    func setTaskTitleFieldFirstResponder() {
        if !newTaskTitleTextField.isFirstResponder {
            newTaskTitleTextField.becomeFirstResponder()
        }
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
        if let sectionInfo = dataSource.sectionInfo(forSectionAt: indexPath.section),
            sectionInfo.name == "1",
            !output.isCompletedTasksVisible() {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableListRepresentationCell",
                                                 for: indexPath) as! TableListRepresentationCell
        
        if let item = dataSource.item(at: indexPath.row, in: indexPath.section) {
            cell.title = item.title
            cell.dueDate = item.dueDate?.asDayMonthTime
            cell.subtasksInfo = (item.subtasks.filter { $0.isDone }.count, item.subtasks.count)
            cell.isImportant = item.isImportant
            cell.containsAttachments = false // TODO
            cell.isDone = item.isDone
            cell.updateTagColors(with:
                item.tags
                    .sorted(by: { $0.0.title < $0.1.title })
                    .map { $0.color }
            )
            
            cell.maxTitleLinesCount = item.subtasks.count > 0 || item.isDone || item.dueDate != nil /*|| attachments*/ ? 1 : 2
            
            cell.onTapToImportancy = { [weak self] in
                guard let indexPath = tableView.indexPath(for: cell) else { return }
                if let task = self?.dataSource.item(at: indexPath.row, in: indexPath.section) {
                    self?.output.toggleImportancy(of: task)
                }
            }
        }
        
        cell.delegate = swipeTableActionsProvider
        
        return cell
    }

}

extension TableListRepresentationView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Перенести в SwipeActions
        if let task = dataSource.item(at: indexPath.row, in: indexPath.section) {
            output.didPressEdit(for: task)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            // Если это секция незавершенных задач && есть секция завершенных задач и секция завершенных задач не пустая -> показывать кнопку
        if let sectionInfo = dataSource.sectionInfo(forSectionAt: section), sectionInfo.name == "1", sectionInfo.numberOfItems > 0 {
            if let activeSectionInfo = dataSource.sectionInfo(forSectionWithName: "0"), activeSectionInfo.numberOfItems > 0 {
                return 72
            }
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource.sectionInfo(forSectionAt: indexPath.section)?.name == "1", !output.isCompletedTasksVisible() {
            return 0
        }
        
        if let item = dataSource.item(at: indexPath.row, in: indexPath.section), item.tags.count > 0 {
            return 58
        }
        return 52
    }
    
    static var titleAttributes: [String: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        return [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
    }()

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            // Если это секция незавершенных задач && есть секция завершенных задач и секция завершенных задач не пустая -> показывать кнопку
            if let sectionInfo = dataSource.sectionInfo(forSectionAt: section), sectionInfo.name == "1", sectionInfo.numberOfItems > 0 {
                if let activeSectionInfo = dataSource.sectionInfo(forSectionWithName: "0"), activeSectionInfo.numberOfItems > 0 {
                    let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableListRepresentationFooter") as! TableListRepresentationFooter
                    
                    view.title = output.isCompletedTasksVisible() ? "Скрыть завершенные задачи" : "Показать завершенные задачи"  // TODO
                    view.onTap = {
                        self.output.toggleCompletedTasksVisibility()
                    }
                    
                    view.applyAppearance()
                    
                    return view
                }
            }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

}

extension TableListRepresentationView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateRightBarButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
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
            rightBarButton.setImage(UIImage(named: "edit"), for: .normal)
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
        button = UIButton(forAutoLayout: ())
        self.addSubview(button)
        button.autoSetDimension(.height, toSize: 32)
        button.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: -8)
        button.autoAlignAxis(toSuperviewAxis: .vertical)
        button.backgroundColor = AppTheme.current.scheme.panelColor
        button.setTitleColor(AppTheme.current.scheme.tintColor, for: .normal)
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

