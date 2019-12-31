//
//  SprintContentViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 14.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

protocol SprintContentViewControllerDelegate: class {
    func didChangeItemsCount(in section: SprintSection, to count: Int)
}

final class SprintContentViewController: UIViewController {
    
    enum State {
        case empty
        case content
    }
    
    var section = SprintSection.habits {
        didSet {
            guard isViewLoaded else { return }
            setupCurrentCacheObserver()
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
            setupCurrentCacheObserver()
        }
    }
    
    weak var transitionHandler: UIViewController?
    weak var delegate: SprintContentViewControllerDelegate?
    
    private var contentView: UITableView!
    
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = PlaceholderView.loadedFromNib()
    
    let habitsService = ServicesAssembly.shared.habitsService
    let goalsService = ServicesAssembly.shared.goalsService
    
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: contentView)
    private var habitsCacheObserver: CacheObserver<Habit>?
    private var goalsCacheObserver: CacheObserver<Goal>?
    
    private let targetCellActionsProvider = CellDeleteSwipeActionProvider()
    private let habitCellActionsProvider = CellDeleteSwipeActionProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentView()
        setupPlaceholder()
        setupCurrentCacheObserver()
        
        targetCellActionsProvider.onDelete = { [unowned self] indexPath in
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return }
            self.goalsService.removeGoal(goal, completion: { _ in })
        }
        habitCellActionsProvider.onDelete = { [unowned self] indexPath in
            guard let habit = self.habitsCacheObserver?.item(at: indexPath) else { return }
            self.habitsService.removeHabit(habit, completion: { _ in })
            HabitsSchedulerService.shared.removeNotifications(for: habit, completion: {})
        }
        
        cacheAdapter.onReloadFail = { [weak self] in
            self?.setupContentView()
            self?.contentView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
    }
    
    func setupAppearance() {
        contentView.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
}

extension SprintContentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch section {
        case .habits: return habitsCacheObserver?.numberOfSections() ?? 0
        case .goals: return goalsCacheObserver?.numberOfSections() ?? 0
        case .activity: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.section {
        case .habits: return habitsCacheObserver?.numberOfItems(in: section) ?? 0
        case .goals: return goalsCacheObserver?.numberOfItems(in: section) ?? 0
        case .activity: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section.itemsKind {
        case .habit:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SprintCreationHabitCell", for: indexPath) as! SprintCreationHabitCell
            if let habit = habitsCacheObserver?.item(at: indexPath) {
                cell.configure(habit: habit)
                cell.delegate = habitCellActionsProvider
            }
            return cell
        case .goal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SprintCreationTargetCell", for: indexPath) as! SprintCreationTargetCell
            if let goal = goalsCacheObserver?.item(at: indexPath) {
                cell.configure(goal: goal)
                cell.delegate = targetCellActionsProvider
            }
            return cell
        case .activity: return UITableViewCell()
        }
    }
    
}

extension SprintContentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch section.itemsKind {
        case .habit:
            guard let habit = habitsCacheObserver?.item(at: indexPath) else { return }
            transitionHandler?.performSegue(withIdentifier: "ShowHabitCreation", sender: habit)
        case .goal:
            guard let goal = goalsCacheObserver?.item(at: indexPath) else { return }
            transitionHandler?.performSegue(withIdentifier: "ShowGoalCreation", sender: goal)
        case .activity: break
        }
    }
    
}

private extension SprintContentViewController {
    
    func setupCurrentCacheObserver() {
        switch section {
        case .habits: setupHabitsCacheObserver(forSection: section, sprintID: sprintID)
        case .goals: setupGoalsCacheObserver(forSection: section, sprintID: sprintID)
        case .activity: break
        }
    }
    
    func setupHabitsCacheObserver(forSection section: SprintSection, sprintID: String) {
        goalsCacheObserver = nil
        habitsCacheObserver = habitsService.habitsObserver(sprintID: sprintID, day: nil)
        habitsCacheObserver?.setActions(
            onInitialFetch: nil,
            onItemsCountChange: { [weak self] count in
                guard let self = self else { return }
                self.state = count == 0 ? .empty : .content
                self.delegate?.didChangeItemsCount(in: self.section, to: count)
            },
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: nil)
        habitsCacheObserver?.setSubscriber(cacheAdapter)
        habitsCacheObserver?.fetchInitialEntities()
    }
    
    func setupGoalsCacheObserver(forSection section: SprintSection, sprintID: String) {
        habitsCacheObserver = nil
        goalsCacheObserver = goalsService.goalsObserver(sprintID: sprintID)
        goalsCacheObserver?.setActions(
            onInitialFetch: nil,
            onItemsCountChange: { [weak self] count in
                guard let self = self else { return }
                self.state = count == 0 ? .empty : .content
                self.delegate?.didChangeItemsCount(in: self.section, to: count)
        },
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: nil)
        goalsCacheObserver?.setSubscriber(cacheAdapter)
        goalsCacheObserver?.fetchInitialEntities()
    }
    
}

private extension SprintContentViewController {
    
    func setupContentView() {
        let contentView = UITableView()
        
        self.contentView?.removeFromSuperview()
        
        view.addSubview(contentView)
        
        if #available(iOS 11.0, *) {
            contentView.allEdges().to(view)
        } else {
            contentView.allEdges().to(view)
        }
        
        contentView.delegate = self
        contentView.dataSource = self
        
        contentView.contentInset.top = 10
        contentView.contentInset.bottom = 64 + 16
        contentView.estimatedRowHeight = 56
        contentView.rowHeight = UITableView.automaticDimension
        contentView.showsVerticalScrollIndicator = false
        contentView.tableFooterView = UIView()
        contentView.separatorStyle = .none
        
        contentView.backgroundColor = AppTheme.current.colors.middlegroundColor
        
        contentView.register(
            SprintCreationHabitCell.self,
            forCellReuseIdentifier: SprintCreationHabitCell.reuseIdentifier
        )
        contentView.register(
            SprintCreationTargetCell.self,
            forCellReuseIdentifier: SprintCreationTargetCell.reuseIdentifier
        )
        
        self.contentView = contentView
        
        cacheAdapter.tableView = contentView
    }
    
}

private extension SprintContentViewController {
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderView.backgroundColor = .clear
        placeholderView.titleLabel.font = AppTheme.current.fonts.medium(18)
        placeholderView.subtitleLabel.font = AppTheme.current.fonts.regular(14)
        placeholderView.titleLabel.textColor = AppTheme.current.colors.activeElementColor
        placeholderView.subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        placeholderContainer.isHidden = true
    }
    
    func showPlaceholder() {
        placeholderContainer.isHidden = false
        placeholderView.icon = nil
        switch section {
        case .goals:
            placeholderView.title = "targets_section_placeholder_title".localized
            placeholderView.subtitle = "targets_section_placeholder_subtitle".localized
        case .habits:
            placeholderView.title = "habits_section_placeholder_title".localized
            placeholderView.subtitle = "habits_section_placeholder_subtitle".localized
        case .activity: break
        }
    }
    
    func hidePlaceholder() {
        placeholderContainer.isHidden = true
    }
    
}
