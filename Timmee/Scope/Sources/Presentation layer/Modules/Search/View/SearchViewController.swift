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
    func subscribeToCacheObserver(_ observer: CacheSubscribable)
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
    
    @IBOutlet private var searchImageView: UIImageView!
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var tableViewContainer: BarView!
    
    @IBOutlet private var tableViewContainerBottomConstraint: NSLayoutConstraint!
    
    private lazy var placeholder = PlaceholderView.loadedFromNib()
    
    private let swipeTableActionsProvider = SwipeTaskActionsProvider()
    
    private let keyboardManager = KeyboardManager()
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: tableView)
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlaceholder()
        setInitialPlaceholderVisible(true)
        setupKeyboardManager()
        
        tableView.backgroundView = UIView()
        tableView.register(UINib(nibName: "TableListRepresentationBaseCell", bundle: nil),
                           forCellReuseIdentifier: "TableListRepresentationBaseCell")
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
                return task.isDone(at: nil)
            }
            return false
        }
        swipeTableActionsProvider.progressActionForRow = { [unowned self] indexPath in
            if let task = self.dataSource.item(at: indexPath) {
                if task.isDone(at: nil) { return .none }
                else { return task.inProgress ? .stop : .start }
            }
            return .none
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.backgroundColor
        tableViewContainer.backgroundColor = AppTheme.current.middlegroundColor
        searchImageView.tintColor = AppTheme.current.secondaryBackgroundTintColor
        closeButton.tintColor = AppTheme.current.backgroundTintColor
        
        searchTextField.tintColor = AppTheme.current.specialColor
        searchTextField.textColor = AppTheme.current.backgroundTintColor
        
        let attributes = [NSAttributedString.Key.foregroundColor: AppTheme.current.secondaryBackgroundTintColor]
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
    
    func subscribeToCacheObserver(_ observer: CacheSubscribable) {
        observer.setSubscriber(cacheAdapter)
    }
    
}

// TODO: Вынести в adapter
extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sectionsCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.itemsCount(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let task = dataSource.item(at: indexPath) {
            let listRepresentationCell: TableListRepresentationBaseCell
            if task.isDone(at: nil) {
                listRepresentationCell = tableView.dequeueReusableCell(withIdentifier: "TableListRepresentationBaseCell",
                                                                       for: indexPath) as! TableListRepresentationBaseCell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableListRepresentationCell",
                                                         for: indexPath) as! TableListRepresentationCell
                
                cell.onTapToImportancy = { [unowned self, unowned tableView, unowned cell] in
                    guard let indexPath = tableView.indexPath(for: cell) else { return }
                    if let task = self.dataSource.item(at: indexPath) {
                        self.output.toggleImportancy(of: task)
                    }
                }
                
                listRepresentationCell = cell
            }
            
            listRepresentationCell.setTask(task)
            listRepresentationCell.isChecked = false
            listRepresentationCell.setGroupEditing(false)
            listRepresentationCell.delegate = swipeTableActionsProvider
            
            return listRepresentationCell
        }
        
        return UITableViewCell()
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
        if let task = dataSource.item(at: indexPath) {
            if task.isDone(at: nil) {
                return 40
            } else if task.tags.count > 0 {
                return 62
            }
            return 56
        }
        return 0
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
        view.title = title?.uppercased() ?? "empty_section".localized.uppercased()
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

private extension SearchViewController {
    
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
                                               name: UITextField.textDidChangeNotification,
                                               object: searchTextField)
    }
    
    @objc func searchStringChanged() {
        guard let string = searchTextField.text?.trimmed, !string.isEmpty else {
            output.searchStringCleared()
            return
        }
        
        output.searchStringChanged(to: string)
    }
    
    // TODO: Вынести в route
    func showTaskEditor(configuration: (TaskEditorInput) -> Void) {
        let taskEditorView = ViewControllersFactory.taskEditor
        taskEditorView.loadViewIfNeeded()
        
        let taskEditorInput = TaskEditorAssembly.assembly(with: taskEditorView)
        
        configuration(taskEditorInput)
        
        present(taskEditorView, animated: true, completion: nil)
    }
    
    func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            self.tableViewContainerBottomConstraint.constant = frame.height
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            self.tableViewContainerBottomConstraint.constant = 0
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
