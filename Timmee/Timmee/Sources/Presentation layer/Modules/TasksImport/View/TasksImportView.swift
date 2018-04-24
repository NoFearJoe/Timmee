//
//  TasksImportView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TasksImportViewInput: class {
    func reload()
    func reload(at indexPath: IndexPath)
    func showError(_ error: String)
    func hideError()
    func setDoneButtonEnabled(_ isEnabled: Bool)
    
    func subscribeToCacheObserver(_ observer: CacheSubscribable)
}

protocol TasksImportViewOutput: class {
    func viewDidLoad()
    func viewWillAppear()
    
    func didSelectTask(at indexPath: IndexPath)
    
    func didChangeSearchString(to string: String)
    func didFinishSearching()
    
    func closeButtonPressed()
    func doneButtonPressed()
}

protocol TasksImportViewDataSource: class {
    func numberOfSections() -> Int
    func numberOfTasks(in section: Int) -> Int
    func task(at indexPath: IndexPath) -> Task?
    func sectionTitle(forSectionAt index: Int) -> String?
    func isTaskChecked(at indexPath: IndexPath) -> Bool
}

final class TasksImportView: UIViewController {

    @IBOutlet private var containerView: BarView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var doneButton: UIButton!
    
    @IBOutlet private var containerViewBottomConstraint: NSLayoutConstraint!
    
    private lazy var placeholder: PlaceholderView = PlaceholderView.loadedFromNib()
    
    private let keyboardManager = KeyboardManager()
    private let cacheAdapter = TableViewCacheAdapter()
    
    var output: TasksImportViewOutput!
    weak var dataSource: TasksImportViewDataSource!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let transitionHandler = ModalPresentationTransitionHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = transitionHandler
        
        setupPlaceholder()
        setupKeyboardManager()
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.backgroundView = UIView()
        tableView.register(TasksImportHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "TasksImportHeaderView")
        
        cacheAdapter.setTableView(tableView)
        
        output.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        closeButton.tintColor = AppTheme.current.backgroundTintColor
        doneButton.tintColor = AppTheme.current.greenColor
        
        containerView.backgroundColor = AppTheme.current.middlegroundColor
        tableView.backgroundColor = AppTheme.current.middlegroundColor
        
        tableView.tableHeaderView?.backgroundColor = .clear
        searchController.searchBar.tintColor = AppTheme.current.blueColor
        searchController.searchBar.barTintColor = AppTheme.current.panelColor
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.backgroundImage = UIImage.plain(color: .clear)
        
        output.viewWillAppear()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func didPressCloseButton() {
        output.closeButtonPressed()
    }
    
    @IBAction func didPressDoneButton() {
        output.doneButtonPressed()
    }

}

extension TasksImportView: TasksImportViewInput {

    func reload() {
        tableView?.reloadData()
    }
    
    func reload(at indexPath: IndexPath) {
        tableView?.reloadRows(at: [indexPath],
                              with: .none)
    }
    
    func showError(_ error: String) {
        guard placeholder.isHidden else { return }
        placeholder.alpha = 0
        placeholder.title = error
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 1
        }, completion: { _ in
            self.placeholder.isHidden = false
        })
    }
    
    func hideError() {
        guard !placeholder.isHidden else { return }
        placeholder.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 0
        }, completion: { _ in
            self.placeholder.isHidden = true
        })
    }
    
    
    func setDoneButtonEnabled(_ isEnabled: Bool) {
        doneButton?.isEnabled = isEnabled
    }
    
    func subscribeToCacheObserver(_ observer: CacheSubscribable) {
        observer.setSubscriber(cacheAdapter)
    }

}

extension TasksImportView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfTasks(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksImportCell", for: indexPath) as! TasksImportCell
        
        if let task = dataSource.task(at: indexPath) {
            cell.title = task.title
            cell.isChecked = dataSource.isTaskChecked(at: indexPath)
            cell.isDone = task.isDone
        }
        
        return cell
    }

}

extension TasksImportView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.didSelectTask(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let task = dataSource.task(at: indexPath) {
            return task.isDone ? 32 : 52
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

extension TasksImportView: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.trimmed.isEmpty {
            output.didChangeSearchString(to: text)
        }
    }

}

extension TasksImportView: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        output.didFinishSearching()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        output.didFinishSearching()
    }

}

fileprivate extension TasksImportView {
    
    func setupPlaceholder() {
        placeholder.setup(into: containerView)
        placeholder.icon = #imageLiteral(resourceName: "search_placeholder")
        placeholder.subtitle = nil
        placeholder.isHidden = true
        
    }
    
    func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            self.containerViewBottomConstraint.constant =  frame.height
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            self.containerViewBottomConstraint.constant =  0
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

final class TasksImportHeaderView: UITableViewHeaderFooterView {
    
    fileprivate var titleLabel: UILabel!
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupTitleLabel()
        contentView.backgroundColor = AppTheme.current.middlegroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTitleLabel()
        contentView.backgroundColor = AppTheme.current.middlegroundColor
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel(frame: .zero)
        addSubview(titleLabel)
        [titleLabel.top(12), titleLabel.bottom(4), titleLabel.leading(22), titleLabel.trailing(22)].toSuperview()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = AppTheme.current.secondaryTintColor
    }
    
}
