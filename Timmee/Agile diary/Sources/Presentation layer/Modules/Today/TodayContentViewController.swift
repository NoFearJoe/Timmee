//
//  TodayContentViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class TodayContentViewController: UIViewController, TargetAndHabitInteractorTrait {
    
    enum State {
        case empty
        case content
    }
    
    var section = SprintSection.habits {
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
    
    let tasksService = ServicesAssembly.shared.tasksService
    let stagesService = ServicesAssembly.shared.subtasksService
    
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: contentView)
    private var cacheObserver: CacheObserver<Task>?
    
    private let targetCellActionsProvider = TodayTargetCellSwipeActionsProvider()
    private let habitCellActionsProvider = TodayHabitCellSwipeActionsProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.contentInset.top = 10
        contentView.contentInset.bottom = 64 + 16
        contentView.estimatedRowHeight = 56
        contentView.rowHeight = UITableViewAutomaticDimension
        
        setupPlaceholder()
        
        setupCacheObserver(forSection: section, sprintID: sprintID)
        
        habitCellActionsProvider.shouldShowLink = { [unowned self] indexPath in
            guard let habit = self.cacheObserver?.item(at: indexPath) else { return false }
            return !habit.link.trimmed.isEmpty
        }
        habitCellActionsProvider.onLink = { [unowned self] indexPath in
            guard let habit = self.cacheObserver?.item(at: indexPath) else { return }
            guard let linkURL = URL(string: habit.link.trimmed), UIApplication.shared.canOpenURL(linkURL) else { return }
            UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
        }
        habitCellActionsProvider.onEdit = { [unowned self] indexPath in
            guard let habit = self.cacheObserver?.item(at: indexPath) else { return }
            self.transitionHandler?.performSegue(withIdentifier: "ShowHabitEditor", sender: habit)
        }
        
        targetCellActionsProvider.shouldShowDoneAction = { [unowned self] indexPath in
            guard let target = self.cacheObserver?.item(at: indexPath) else { return false }
            return !target.isDone
        }
        targetCellActionsProvider.onDone = { [unowned self] indexPath in
            guard let target = self.cacheObserver?.item(at: indexPath) else { return }
            target.isDone = true
            self.saveTask(target, listID: self.sprintID, completion: nil)
        }
        targetCellActionsProvider.onEdit = { [unowned self] indexPath in
            guard let target = self.cacheObserver?.item(at: indexPath) else { return }
            self.transitionHandler?.performSegue(withIdentifier: "ShowTargetEditor", sender: target)
        }
    }
    
}

extension TodayContentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cacheObserver?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cacheObserver?.numberOfItems(in: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section.itemsKind {
        case .habit:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayHabitCell", for: indexPath) as! TodayHabitCell
            if let habit = cacheObserver?.item(at: indexPath) {
                cell.configure(habit: habit)
                cell.delegate = habitCellActionsProvider
                cell.onChangeCheckedState = { [unowned self] isChecked in
                    habit.isDone = isChecked
                    self.saveTask(habit, listID: self.sprintID, completion: nil) // TODO: Обработать?
                }
            }
            return cell
        case .target:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTargetCell", for: indexPath) as! TodayTargetCell
            if let target = cacheObserver?.item(at: indexPath) {
                cell.configure(target: target)
                cell.delegate = targetCellActionsProvider
                cell.onChangeCheckedState = { [unowned self] isChecked, stage in
                    stage.isDone = isChecked
                    self.stagesService.updateSubtask(stage, completion: nil)
                }
            }
            return cell
        }
    }
    
}

extension TodayContentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

private extension TodayContentViewController {
    
    func setupCacheObserver(forSection section: SprintSection, sprintID: String) {
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

private extension TodayContentViewController {
    
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
            placeholderView.title = "toady_targets_section_placeholder_title".localized
            placeholderView.subtitle = "today_targets_section_placeholder_subtitle".localized
        case .habits:
            placeholderView.title = "today_habits_section_placeholder_title".localized
            placeholderView.subtitle = "today_habits_section_placeholder_subtitle".localized
        }
    }
    
    func hidePlaceholder() {
        placeholderContainer.isHidden = true
    }
    
}
