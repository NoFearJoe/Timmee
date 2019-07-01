//
//  TableListRepresentationView.swift
//  Timmee
//
//  Created by i.kharabet on 12.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class TableListRepresentationView: UIViewController, AlertInput {
    
    var output: TableListRepresentationViewOutput!
    var adapter: TableListRepresentationAdapterInput!
    
    private lazy var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    private lazy var placeholder = PlaceholderView.loadedFromNib()
    
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: tableView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPlaceholder()
        subscribeToApplicationEvents()
        
        cacheAdapter.onReloadFail = { [weak self] in
            self?.recreateTableView()
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = AppTheme.current.middlegroundColor
        output.viewWillAppear()
    }
    
    @objc private func didBecomeActive() {
        output.viewWillAppear()
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
    
    func setEditingMode(_ mode: ListRepresentationEditingMode, completion: @escaping () -> Void) {
        adapter.setEditingMode(mode)
        tableView.hideSwipeCell(animated: true)
        
        if tableView.visibleCells.count > 0 {
            let group = DispatchGroup()
            tableView.visibleCells
                .map { $0 as! TableListRepresentationBaseCell }
                .forEach {
                    if mode == .group { $0.isChecked = false }
                    group.enter()
                    adapter.applyEditingMode(mode, toCell: $0, animated: true) {
                        group.leave()
                    }
                }
            if let completedTasksHeaderView =
                tableView.headerView(forSection: 0) as? TableListRepresentationCompletedSectionHeaderView
                ?? tableView.headerView(forSection: 1) as? TableListRepresentationCompletedSectionHeaderView {
                completedTasksHeaderView.showDeleteButton = mode == .default
            }
            group.notify(queue: .main, execute: completion)
        } else {
            completion()
        }
    }
    
    func subscribeToCacheObserver(_ observer: CacheSubscribable) {
        observer.setSubscriber(cacheAdapter)
    }
    
    func resetOffset() {
        if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func setInteractionsEnabled(_ isEnabled: Bool) {
        tableView.isUserInteractionEnabled = isEnabled
    }
    
    func animateModification(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TableListRepresentationCell else { return }
        cell.animateModification()
    }
    
    func reloadTasks() {
        tableView.reloadData()
    }
    
}

private extension TableListRepresentationView {
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        
        view.addSubview(tableView)
        tableView.allEdges().toSuperview()
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.insetsContentViewsToSafeArea = true
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "TableListRepresentationBaseCell", bundle: nil),
                           forCellReuseIdentifier: "TableListRepresentationBaseCell")
        tableView.register(UINib(nibName: "TableListRepresentationCell", bundle: nil),
                           forCellReuseIdentifier: "TableListRepresentationCell")
        tableView.register(UINib(nibName: "TableListRepresentationCellForFinishedTask", bundle: nil),
                           forCellReuseIdentifier: "TableListRepresentationCellForFinishedTask")
        tableView.register(UINib(nibName: "TableListRepresentationCompletedSectionHeaderView", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "TableListRepresentationCompletedSectionHeaderView")
        
        adapter.setupTableView(tableView)
        cacheAdapter.tableView = tableView
    }
    
    func recreateTableView() {
        tableView.removeFromSuperview()
        setupTableView()
    }
    
    func setupPlaceholder() {
        placeholder.setup(into: view)
        placeholder.icon = #imageLiteral(resourceName: "no_tasks")
        placeholder.title = "no_tasks".localized
        placeholder.subtitle = "no_tasks_hint".localized
        placeholder.isHidden = true
    }
    
    func subscribeToApplicationEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
}
