//
//  SearchViewController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 07.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

struct SearchResultDisplayItem {
    let title: String
    let icon: UIImage
}

protocol SearchViewInput: class {
    func updateSearchResults()
    func setInitialPlaceholderVisible(_ isVisible: Bool)
    func setNoSearchResultsPlaceholderVisible(_ isVisible: Bool)
    func setInteractionsEnabled(_ isEnabled: Bool)
    func connect(with tableViewManagable: TableViewManageble)
}

protocol SearchViewOutput: class {
    func searchStringChanged(to string: String)
    func searchStringCleared()
    
    func didPressDelete(task: Task)
    func didPressComplete(task: Task)
    func didPressStart(task: Task)
    func didPressStop(task: Task)
    func toggleImportancy(of task: Task)
}

final class SearchViewController: UIViewController {
    
    var output: SearchViewOutput!
    weak var dataSource: SearchDataSource!
    
    @IBOutlet fileprivate var searchImageView: UIImageView!
    @IBOutlet fileprivate var searchTextField: UITextField!
    @IBOutlet fileprivate var closeButton: UIButton!
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var tableViewContainer: BarView!
    
    fileprivate lazy var placeholder: PlaceholderView = PlaceholderView.loadedFromNib()
    
    fileprivate let swipeTableActionsProvider = SwipeTaskActionsProvider()
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlaceholder()
        setInitialPlaceholderVisible(true)
        
        tableView.backgroundView = UIView()
        tableView.register(UINib(nibName: "TableListRepresentationCell", bundle: nil),
                           forCellReuseIdentifier: "TableListRepresentationCell")
        tableView.register(TasksImportHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "TasksImportHeaderView")
        
        subscribeToSearchStringChanges()
        
        swipeTableActionsProvider.onDelete = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath) {
                self.output.didPressDelete(task: task)
            }
        }
        swipeTableActionsProvider.onStart = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath) {
                self.output.didPressStart(task: task)
            }
        }
        swipeTableActionsProvider.onStop = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath) {
                self.output.didPressStop(task: task)
            }
        }
        swipeTableActionsProvider.onDone = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath) {
                self.output.didPressComplete(task: task)
            }
        }
        swipeTableActionsProvider.isDone = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath) {
                return task.isDone
            }
            return false
        }
        swipeTableActionsProvider.progressActionForRow = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath) {
                if task.isDone { return .none }
                else { return task.inProgress ? .stop : .start }
            }
            return .none
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.backgroundColor
        tableViewContainer.barColor = AppTheme.current.middlegroundColor
        searchImageView.tintColor = AppTheme.current.secondaryBackgroundTintColor
        closeButton.tintColor = AppTheme.current.redColor
        
        searchTextField.tintColor = AppTheme.current.specialColor
        searchTextField.textColor = AppTheme.current.backgroundTintColor
        
        let attributes = [NSForegroundColorAttributeName: AppTheme.current.secondaryBackgroundTintColor]
        searchTextField.attributedPlaceholder = NSAttributedString(string: "search".localized,
                                                                   attributes: attributes)
        
        searchTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.resignFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension SearchViewController: SearchViewInput {
    
    func updateSearchResults() {
        tableView.reloadData()
    }
    
    func setInitialPlaceholderVisible(_ isVisible: Bool) {
        configurePlaceholder(with: "initial_search_title".localized,
                             subtitle: "initial_search_subtitle".localized,
                             image: #imageLiteral(resourceName: "search_placeholder"))
        placeholder.isHidden = !isVisible
    }
    
    func setNoSearchResultsPlaceholderVisible(_ isVisible: Bool) {
        configurePlaceholder(with: "no_searched_tasks".localized,
                             subtitle: "",
                             image: #imageLiteral(resourceName: "search_placeholder"))
        placeholder.isHidden = !isVisible
    }
    
    func setInteractionsEnabled(_ isEnabled: Bool) {
        view.isUserInteractionEnabled = isEnabled
    }
    
    func connect(with tableViewManagable: TableViewManageble) {
        tableViewManagable.setTableView(tableView)
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sectionsCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.itemsCount(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableListRepresentationCell",
                                                 for: indexPath) as! TableListRepresentationCell
        
        if let task = dataSource.item(at: indexPath) {
            cell.setTask(task)
            
            cell.setGroupEditing(false)
            cell.isChecked = false
            
            cell.onTapToImportancy = { [unowned self] in
                guard let indexPath = tableView.indexPath(for: cell) else { return }
                if let task = self.dataSource.item(at: indexPath) {
                    self.output.toggleImportancy(of: task)
                }
            }
        }
        
        cell.delegate = swipeTableActionsProvider
        
        return cell
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let task = dataSource.item(at: indexPath) {
            showTaskEditor { input in
                input.setTask(task)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 56
        
        if let item = dataSource.item(at: indexPath) {
            if item.isDone { height -= 15 }
            if item.tags.count > 0 { height += 6 }
            return height
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TasksImportHeaderView") as! TasksImportHeaderView
        var title = dataSource.sectionTitle(forSectionAt: section)
        if title == nil || title!.isEmpty {
            title = "tasks_without_list".localized
        }
        view.title = title!.uppercased() // todo default title and uppercase
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

fileprivate extension SearchViewController {
    
    func setupPlaceholder() {
        placeholder.setup(into: tableViewContainer)
        placeholder.isHidden = true
    }
    
    func configurePlaceholder(with title: String, subtitle: String, image: UIImage) {
        placeholder.icon = image
        placeholder.title = title
        placeholder.subtitle = subtitle
    }
    
    func subscribeToSearchStringChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(searchStringChanged),
                                               name: .UITextFieldTextDidChange,
                                               object: nil)
    }
    
    @objc func searchStringChanged() {
        guard let string = searchTextField.text?.trimmed, !string.isEmpty else {
            output.searchStringCleared()
            return
        }
        
        output.searchStringChanged(to: string)
    }
    
    fileprivate func showTaskEditor(configuration: (TaskEditorInput) -> Void) {
        let taskEditorView = ViewControllersFactory.taskEditor
        taskEditorView.loadViewIfNeeded()
        
        let taskEditorInput = TaskEditorAssembly.assembly(with: taskEditorView)
        
        configuration(taskEditorInput)
        
        present(taskEditorView, animated: true, completion: nil)
    }
    
}
