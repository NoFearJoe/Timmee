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
    
    func connect(with tableViewManagable: TableViewManageble)
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

    @IBOutlet fileprivate weak var containerView: BarView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var errorLabel: UILabel!
    @IBOutlet fileprivate weak var closeButton: UIButton!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    
    fileprivate lazy var placeholder: PlaceholderView = PlaceholderView.loadedFromNib()
    
    var output: TasksImportViewOutput!
    weak var dataSource: TasksImportViewDataSource!
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupPlaceholder()
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.backgroundView = UIView()
        tableView.register(TasksImportHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "TasksImportHeaderView")
        
        output.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        closeButton.tintColor = AppTheme.current.backgroundTintColor
        doneButton.tintColor = AppTheme.current.greenColor
        
        containerView.barColor = AppTheme.current.middlegroundColor
        tableView.backgroundColor = AppTheme.current.middlegroundColor
        
        tableView.tableHeaderView?.backgroundColor = .clear
        searchController.searchBar.tintColor = AppTheme.current.blueColor
        searchController.searchBar.barTintColor = AppTheme.current.panelColor
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.backgroundImage = UIImage.plain(color: .clear)
        
        errorLabel.textColor = AppTheme.current.tintColor
        
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
    
    func connect(with tableViewManagable: TableViewManageble) {
        tableViewManagable.setTableView(tableView)
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
        view.title = title!.uppercased() // todo default title and uppercase
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

extension TasksImportView: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalDismissalTransition()
    }
    
}

fileprivate extension TasksImportView {
    
    func setupPlaceholder() {
        placeholder.setup(into: containerView)
        placeholder.icon = #imageLiteral(resourceName: "faceIDBig")
        placeholder.subtitle = nil
        placeholder.isHidden = true
        
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
        titleLabel = UILabel(forAutoLayout: ())
        addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 22, bottom: 4, right: 22))
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = AppTheme.current.secondaryTintColor
    }
    
}
