//
//  SprintContentViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 14.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class SprintContentViewController: UIViewController {
    
    enum State {
        case empty
        case content
    }
    
    var section = SprintCreationSection.targets {
        didSet {
            guard isViewLoaded else { return }
            setupCacheObserver(forSection: section, sprintID: sprintID)
        }
    }
    var state = State.empty {
        didSet {
            switch state {
            case .empty: showPlaceholder()
            case .content: hidePlaceholder()
            }
        }
    }
    
    var sprintID: String = "" {
        didSet {
            guard isViewLoaded else { return }
            setupCacheObserver(forSection: section, sprintID: sprintID)
        }
    }
    
    @IBOutlet private var contentView: UITableView!
    
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = PlaceholderView.loadedFromNib()
    
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: contentView)
    
    private var cacheObserver: CacheObserver<Task>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.contentInset.bottom = 64 + 16
        setupPlaceholder()
        setupCacheObserver(forSection: section, sprintID: sprintID)
    }
    
}

private extension SprintContentViewController {
    
    func setupCacheObserver(forSection section: SprintCreationSection, sprintID: String) {
        let predicate = NSPredicate(format: "list.id = %@ AND ANY tags.id = %@", sprintID, section.itemsKind.id)
        cacheObserver = ServicesAssembly.shared.tasksService.tasksObserver(predicate: predicate)
        cacheObserver?.setMapping { Task(task: $0 as! TaskEntity) }
        cacheObserver?.setActions(
            onInitialFetch: nil,
            onItemsCountChange: { count in self.state = count == 0 ? .empty : .content },
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: nil)
        cacheObserver?.setSubscriber(cacheAdapter)
        cacheObserver?.fetchInitialEntities()
    }
    
}

private extension SprintContentViewController {
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderView.titleLabel.font = UIFont.avenirNextMedium(18)
        placeholderView.subtitleLabel.font = UIFont.avenirNextRegular(14)
        placeholderView.isHidden = true
    }
    
    func showPlaceholder() {
        placeholderView.isHidden = false
        placeholderView.icon = nil
        switch section {
        case .targets:
            placeholderView.title = "targets_section_placeholder_title".localized
            placeholderView.subtitle = "targets_section_placeholder_subtitle".localized
        case .habits:
            placeholderView.title = "habits_section_placeholder_title".localized
            placeholderView.subtitle = "habits_section_placeholder_subtitle".localized
        }
    }
    
    func hidePlaceholder() {
        placeholderView.isHidden = true
    }
    
}
