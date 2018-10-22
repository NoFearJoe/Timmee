//
//  TodayContentViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class TodayContentViewController: UIViewController {
    
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
    weak var progressListener: TodayViewSectionProgressListener?
    
    @IBOutlet private var contentView: UITableView!
    
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = PlaceholderView.loadedFromNib()
    
    let habitsService = ServicesAssembly.shared.habitsService
    let goalsService = ServicesAssembly.shared.goalsService
    let stagesService = ServicesAssembly.shared.subtasksService
    
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: contentView)
    private var habitsCacheObserver: CacheObserver<Habit>?
    private var goalsCacheObserver: CacheObserver<Goal>?
    
    private let targetCellActionsProvider = TodayTargetCellSwipeActionsProvider()
    private let habitCellActionsProvider = TodayHabitCellSwipeActionsProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.contentInset.top = 10
        contentView.contentInset.bottom = 64 + 16
        contentView.estimatedRowHeight = 56
        contentView.rowHeight = UITableView.automaticDimension
        
        setupPlaceholder()
        
        setupCurrentCacheObserver()
        
        setupHabitCellActionsProvider()
        setupTargetCellActionsProvider()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPlaceholderAppearance()
        setupCurrentCacheObserver()
    }
    
    @objc private func onBecameActive() {
        setupCurrentCacheObserver()
    }
    
    @objc private func willResignActive() {
        habitsCacheObserver = nil
        goalsCacheObserver = nil
    }
    
    private func openLink(_ link: String) {
        guard !link.trimmed.isEmpty, let linkURL = URL(string: link.trimmed), UIApplication.shared.canOpenURL(linkURL) else { return }
        UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
    }
    
}

extension TodayContentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch section {
        case .habits: return habitsCacheObserver?.numberOfSections() ?? 0
        case .goals: return goalsCacheObserver?.numberOfSections() ?? 0
        case .water: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.section {
        case .habits: return habitsCacheObserver?.numberOfItems(in: section) ?? 0
        case .goals: return goalsCacheObserver?.numberOfItems(in: section) ?? 0
        case .water: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section.itemsKind {
        case .habit:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayHabitCell", for: indexPath) as! TodayHabitCell
            if let habit = habitsCacheObserver?.item(at: indexPath) {
                cell.configure(habit: habit)
                cell.delegate = habitCellActionsProvider
                cell.onChangeCheckedState = { [unowned self] isChecked in
                    habit.setDone(isChecked, at: Date.now)
                    self.habitsService.updateHabit(habit, sprintID: self.sprintID, completion: { _ in })
                }
            }
            return cell
        case .goal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTargetCell", for: indexPath) as! TodayTargetCell
            if let goal = goalsCacheObserver?.item(at: indexPath) {
                cell.configure(goal: goal)
                cell.delegate = targetCellActionsProvider
                cell.onChangeCheckedState = { [unowned self] isChecked, stage in
                    stage.isDone = isChecked
                    self.stagesService.updateSubtask(stage, completion: nil)
                }
            }
            return cell
        case .water: return UITableViewCell()
        }
    }
    
}

extension TodayContentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch section.itemsKind {
        case .habit:
            guard let habit = habitsCacheObserver?.item(at: indexPath) else { return }
            openLink(habit.link)
        case .goal, .water: return
        }
    }
    
}

private extension TodayContentViewController {
    
    func setupCurrentCacheObserver() {
        switch section {
        case .habits: setupHabitsCacheObserver(forSection: section, sprintID: sprintID)
        case .goals: setupGoalsCacheObserver(forSection: section, sprintID: sprintID)
        case .water: break
        }
    }
    
    func setupHabitsCacheObserver(forSection section: SprintSection, sprintID: String) {
        goalsCacheObserver = nil
        habitsCacheObserver = ServicesAssembly.shared.habitsService.habitsObserver(sprintID: sprintID, day: DayUnit(number: Date.now.weekday - 1))
        habitsCacheObserver?.setActions(
            onInitialFetch: { [unowned self] in self.updateSprintProgress(habits: self.habitsCacheObserver?.items(in: 0) ?? []) },
            onItemsCountChange: { count in self.state = count == 0 ? .empty : .content },
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: { [unowned self] in self.updateSprintProgress(habits: self.habitsCacheObserver?.items(in: 0) ?? []) })
        habitsCacheObserver?.setSubscriber(cacheAdapter)
        habitsCacheObserver?.fetchInitialEntities()
    }
    
    func setupGoalsCacheObserver(forSection section: SprintSection, sprintID: String) {
        habitsCacheObserver = nil
        goalsCacheObserver = ServicesAssembly.shared.goalsService.goalsObserver(sprintID: sprintID)
        goalsCacheObserver?.setActions(
            onInitialFetch: { [unowned self] in self.updateSprintProgress(goals: self.goalsCacheObserver?.items(in: 0) ?? []) },
            onItemsCountChange: { count in self.state = count == 0 ? .empty : .content },
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: { [unowned self] in self.updateSprintProgress(goals: self.goalsCacheObserver?.items(in: 0) ?? []) })
        goalsCacheObserver?.setSubscriber(cacheAdapter)
        goalsCacheObserver?.fetchInitialEntities()
    }
    
}

private extension TodayContentViewController {
    
    private func updateSprintProgress(habits: [Habit]) {
        let progress = CGFloat(habits.filter { $0.isDone(at: Date.now) }.count).safeDivide(by: CGFloat(habits.count))
        progressListener?.didChangeProgress(for: section, to: progress)
    }
    
    private func updateSprintProgress(goals: [Goal]) {
        let progress = CGFloat(goals.filter { $0.isDone }.count).safeDivide(by: CGFloat(goals.count))
        progressListener?.didChangeProgress(for: section, to: progress)
    }
    
}

private extension TodayContentViewController {
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderContainer.isHidden = true
    }
    
    func setupPlaceholderAppearance() {
        placeholderView.titleLabel.font = AppTheme.current.fonts.medium(18)
        placeholderView.subtitleLabel.font = AppTheme.current.fonts.regular(14)
        placeholderView.titleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        placeholderView.subtitleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
    }
    
    func showPlaceholder() {
        placeholderContainer.isHidden = false
        placeholderView.icon = nil
        switch section {
        case .goals:
            placeholderView.title = "today_targets_section_placeholder_title".localized
            placeholderView.subtitle = nil
        case .habits:
            placeholderView.title = "today_habits_section_placeholder_title".localized
            placeholderView.subtitle = nil
        case .water: break
        }
    }
    
    func hidePlaceholder() {
        placeholderContainer.isHidden = true
    }
    
}

private extension TodayContentViewController {
    
    func setupHabitCellActionsProvider() {
        habitCellActionsProvider.shouldShowLinkAction = { [unowned self] indexPath in
            guard let habit = self.habitsCacheObserver?.item(at: indexPath) else { return false }
            return !habit.link.trimmed.isEmpty
        }
        habitCellActionsProvider.shouldShowEditAction = { [unowned self] indexPath in
            guard let habit = self.habitsCacheObserver?.item(at: indexPath) else { return false }
            return !habit.isDone(at: Date.now)
        }
        habitCellActionsProvider.onLink = { [unowned self] indexPath in
            guard let habit = self.habitsCacheObserver?.item(at: indexPath) else { return }
            self.openLink(habit.link)
        }
        habitCellActionsProvider.onEdit = { [unowned self] indexPath in
            guard let habit = self.habitsCacheObserver?.item(at: indexPath) else { return }
            self.transitionHandler?.performSegue(withIdentifier: "ShowHabitEditor", sender: habit)
        }
    }
    
    func setupTargetCellActionsProvider() {
        targetCellActionsProvider.shouldShowDoneAction = { [unowned self] indexPath in
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return false }
            return !goal.isDone
        }
        targetCellActionsProvider.shouldShowEditAction = { [unowned self] indexPath in
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return false }
            return !goal.isDone
        }
        targetCellActionsProvider.onDone = { [unowned self] indexPath in
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return }
            goal.isDone = !goal.isDone
            self.goalsService.updateGoal(goal, sprintID: self.sprintID, completion: { _ in })
        }
        targetCellActionsProvider.onEdit = { [unowned self] indexPath in
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return }
            self.transitionHandler?.performSegue(withIdentifier: "ShowTargetEditor", sender: goal)
        }
    }
    
}
