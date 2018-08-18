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
    
    var section = SprintCreationSection.habits {
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
    
    weak var transitionHandler: UIViewController?
    
    @IBOutlet private var contentView: UITableView!
    
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = PlaceholderView.loadedFromNib()
    
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: contentView)
    private var cacheObserver: CacheObserver<Task>?
    
    private let targetCellActionsProvider = StageCellActionsProvider()
    private let habitCellActionsProvider = StageCellActionsProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.contentInset.top = 10
        contentView.contentInset.bottom = 64 + 16
        contentView.estimatedRowHeight = 56
        contentView.rowHeight = UITableViewAutomaticDimension
        setupPlaceholder()
        setupCacheObserver(forSection: section, sprintID: sprintID)
        targetCellActionsProvider.onDelete = { [unowned self] indexPath in
            
        }
        habitCellActionsProvider.onDelete = { [unowned self] indexPath in
            
        }
    }
    
}

extension SprintContentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cacheObserver?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cacheObserver?.numberOfItems(in: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section.itemsKind {
        case .habit:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SprintCreationHabitCell", for: indexPath) as! SprintCreationHabitCell
            if let habit = cacheObserver?.item(at: indexPath) {
                cell.configure(habit: habit)
                cell.delegate = habitCellActionsProvider
            }
            return cell
        case .target:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SprintCreationTargetCell", for: indexPath) as! SprintCreationTargetCell
            if let target = cacheObserver?.item(at: indexPath) {
                cell.configure(target: target)
                cell.delegate = targetCellActionsProvider
            }
            return cell
        }
    }
    
}

extension SprintContentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch section.itemsKind {
        case .habit:
            guard let habit = cacheObserver?.item(at: indexPath) else { return }
            transitionHandler?.performSegue(withIdentifier: "ShowHabitCreation", sender: habit)
        case .target:
            guard let target = cacheObserver?.item(at: indexPath) else { return }
            transitionHandler?.performSegue(withIdentifier: "ShowTargetCreation", sender: target)
        }
    }
    
}

private extension SprintContentViewController {
    
    func setupCacheObserver(forSection section: SprintCreationSection, sprintID: String) {
        let predicate = NSPredicate(format: "list.id = %@ AND kind = %@", sprintID, section.itemsKind.id)
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
        placeholderContainer.isHidden = true
    }
    
    func showPlaceholder() {
        placeholderContainer.isHidden = false
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
        placeholderContainer.isHidden = true
    }
    
}
