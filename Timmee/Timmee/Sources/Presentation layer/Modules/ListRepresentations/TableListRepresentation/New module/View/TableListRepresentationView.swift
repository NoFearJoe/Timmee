//
//  TableListRepresentationView.swift
//  Timmee
//
//  Created by i.kharabet on 12.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class TableListRepresentationView: UIViewController {
    
    var output: TableListRepresentationViewOutput!
    var adapter: TableListRepresentationAdapterInput!
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var placeholder = PlaceholderView.loadedFromNib()
    
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: tableView)
    
    private var editingMode: ListRepresentationEditingMode = .default {
        didSet {
            adapter.setEditingMode(editingMode)
            tableView.hideSwipeCell(animated: true)
            tableView.visibleCells
                .map { $0 as! TableListRepresentationCell }
                .forEach {
                    adapter.applyEditingMode(editingMode, toCell: $0)
                    if editingMode == .group { $0.isChecked = false }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPlaceholder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func setEditingMode(_ mode: ListRepresentationEditingMode) {
        self.editingMode = mode
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
    
}

private extension TableListRepresentationView {
    
    func setupTableView() {
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "TableListRepresentationCell", bundle: nil),
                           forCellReuseIdentifier: "TableListRepresentationCell")
        tableView.register(ListRepresentationFooter.self,
                           forHeaderFooterViewReuseIdentifier: "ListRepresentationFooter")
    }
    
    func setupPlaceholder() {
        placeholder.setup(into: view)
        placeholder.icon = #imageLiteral(resourceName: "no_tasks")
        placeholder.title = "no_tasks".localized
        placeholder.subtitle = "no_tasks_hint".localized
        placeholder.isHidden = true
    }
    
}
