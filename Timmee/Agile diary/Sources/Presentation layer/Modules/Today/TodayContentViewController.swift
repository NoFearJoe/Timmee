//
//  TodayContentViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import TasksKit
import UIComponents
import Synchronization

final class TodayContentViewController: UIViewController, AlertInput {
    
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
            guard isViewLoaded, sprintID != oldValue else { return }
            setupCurrentCacheObserver()
        }
    }
    
    var currentDate: Date = Date.now.startOfDay() {
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
    
//    let habitsSynchronizationService = AgileeHabitsSynchronizationService.shared
    
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: contentView)
    private var habitsCacheObserver: CachedEntitiesObserver<HabitEntity, Habit>?
    private var goalsCacheObserver: CachedEntitiesObserver<GoalEntity, Goal>?
    
    private let targetCellActionsProvider = TodayGoalCellSwipeActionsProvider()
    private let habitCellActionsProvider = TodayHabitCellSwipeActionsProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.contentInset.bottom = 64 + 16
        contentView.estimatedRowHeight = 56
        contentView.rowHeight = UITableView.automaticDimension
        contentView.register(TableHeaderViewWithTitle.self, forHeaderFooterViewReuseIdentifier: "Header")
        
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
    
    func updateAppearance() {
        contentView.reloadData()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayHabitCell", for: indexPath) as! TodayHabitCell
            if let habit = habitsCacheObserver?.item(at: indexPath) {
                cell.configure(habit: habit, currentDate: currentDate)
                cell.delegate = habitCellActionsProvider
                cell.onChangeCheckedState = { [unowned self] isChecked in
                    habit.setDone(isChecked, at: self.currentDate)
                    self.habitsService.updateHabit(habit, sprintID: self.sprintID, goalID: nil, completion: { _ in })/*{ [weak self] _ in
                        guard let self = self else { return }
                        self.habitsSynchronizationService.sync(habit: habit, sprintID: self.sprintID, completion: { _ in })
                    })*/
                }
            }
            return cell
        case .goal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayGoalCell", for: indexPath) as! TodayGoalCell
            if let goal = goalsCacheObserver?.item(at: indexPath) {
                cell.configure(goal: goal)
                cell.delegate = targetCellActionsProvider
                cell.onChangeCheckedState = { [unowned self] isChecked, stage in
                    stage.isDone = isChecked
                    self.stagesService.updateSubtask(stage, completion: nil)
                }
            }
            return cell
        case .activity: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard case .habits = self.section else { return 0 }
        return 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard case .habits = self.section else { return nil }
        guard let sectionName = habitsCacheObserver?.sectionInfo(at: section)?.name else { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! TableHeaderViewWithTitle
        
        let hasBGImage = BackgroundImage.current != .noImage
        view.titleLabel.backgroundColor = hasBGImage ? AppTheme.current.colors.middlegroundColor.withAlphaComponent(0.75) : .clear
        view.backgroundView?.backgroundColor = hasBGImage ? .clear : AppTheme.current.colors.middlegroundColor
        let dayTime = Habit.DayTime(sortID: sectionName)
        view.titleLabel.text = hasBGImage ? "  " + dayTime.localizedAt : dayTime.localizedAt
        return view
    }
    
}

extension TodayContentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func makeNavigationController(root: UIViewController & UIViewControllerTransitioningDelegate) -> UINavigationController {
            let navigationController = UINavigationController(rootViewController: root)
            navigationController.isNavigationBarHidden = true
            if #available(iOS 13, *), UIDevice.current.isPhone {
                navigationController.modalPresentationStyle = .fullScreen
            } else {
                navigationController.modalPresentationStyle = .formSheet
            }
            if UIDevice.current.isPhone {
                navigationController.transitioningDelegate = root
            }
            return navigationController
        }
        
        switch section.itemsKind {
        case .habit:
            guard let habit = habitsCacheObserver?.item(at: indexPath) else { return }
            let habitDetailsProvider = HabitDetailsProvider(habit: habit, currentDate: currentDate)
            let habitDetailsViewController = DetailsBaseViewController(content: habitDetailsProvider)
            let navigationController = makeNavigationController(root: habitDetailsViewController)
            
            habitDetailsProvider.holderViewController = navigationController
            
            habitDetailsProvider.onEdit = { [unowned self, unowned navigationController] in
                navigationController.dismiss(animated: true, completion: {
                    self.transitionHandler?.performSegue(withIdentifier: "ShowHabitEditor", sender: habit)
                })
            }
            habitDetailsProvider.onAddDiaryEntry = { [unowned self, unowned navigationController] in
                navigationController.dismiss(animated: true, completion: {
                    let diaryViewController = DiaryViewController()
                    self.transitionHandler?.present(diaryViewController, animated: true) {
                        diaryViewController.forceEntryCreation(text: "",
                                                               attachment: .habit(id: habit.id),
                                                               attachedEntity: habit)
                    }
                })
            }
            
            self.transitionHandler?.present(navigationController, animated: true, completion: nil)
        case .goal:
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return }
            let goalDetailsProvider = GoalDetailsProvider(goal: goal)
            let goalDetailsViewController = DetailsBaseViewController(content: goalDetailsProvider)
            let navigationController = makeNavigationController(root: goalDetailsViewController)
            
            goalDetailsProvider.holderViewController = navigationController
            
            goalDetailsProvider.onEdit = { [unowned self, unowned navigationController] in
                navigationController.dismiss(animated: true, completion: {
                    self.transitionHandler?.performSegue(withIdentifier: "ShowTargetEditor", sender: goal)
                })
            }
            goalDetailsProvider.onAddDiaryEntry = { [unowned self, unowned navigationController] in
                navigationController.dismiss(animated: true, completion: {
                    let diaryViewController = DiaryViewController()
                    self.transitionHandler?.present(diaryViewController, animated: true) {
                        diaryViewController.forceEntryCreation(text: "",
                                                               attachment: .goal(id: goal.id),
                                                               attachedEntity: goal)
                    }
                })
            }
            
            self.transitionHandler?.present(navigationController, animated: true, completion: nil)
        case .activity: return
        }
    }
    
}

private extension TodayContentViewController {
    
    func setupCurrentCacheObserver() {
        guard !sprintID.trimmed.isEmpty else { return }
        switch section {
        case .habits: setupHabitsCacheObserver(forSection: section, sprintID: sprintID)
        case .goals: setupGoalsCacheObserver(forSection: section, sprintID: sprintID)
        case .activity: break
        }
    }
    
    func setupHabitsCacheObserver(forSection section: SprintSection, sprintID: String) {
        goalsCacheObserver = nil
        habitsCacheObserver = ServicesAssembly.shared.habitsService.habitsScope(sprintID: sprintID, day: DayUnit(weekday: currentDate.weekday))
        let delegate = CachedEntitiesObserverDelegate<Habit>(
            onInitialFetch: { [unowned self] _ in
                self.updateSprintProgress(habits: self.habitsCacheObserver?.allObjects() ?? [])
            },
            onEntitiesCountChange: { [unowned self] count in
                self.state = count == 0 ? .empty : .content
            },
            onBatchUpdatesCompleted: { [unowned self] in
                self.updateSprintProgress(habits: self.habitsCacheObserver?.allObjects() ?? [])
            }
        )
        habitsCacheObserver?.setDelegate(delegate)
        habitsCacheObserver?.setSubscriber(cacheAdapter)
        habitsCacheObserver?.fetch()
    }
    
    func setupGoalsCacheObserver(forSection section: SprintSection, sprintID: String) {
        habitsCacheObserver = nil
        goalsCacheObserver = ServicesAssembly.shared.goalsService.goalsScope(sprintID: sprintID)
        let delegate = CachedEntitiesObserverDelegate<Goal>(
            onInitialFetch: { [unowned self] _ in
                self.updateSprintProgress(goals: self.goalsCacheObserver?.items(in: 0) ?? [])
            },
            onEntitiesCountChange: { [unowned self] count in
                self.state = count == 0 ? .empty : .content
            },
            onBatchUpdatesCompleted: { [unowned self] in
                self.updateSprintProgress(goals: self.goalsCacheObserver?.items(in: 0) ?? [])
            }
        )
        goalsCacheObserver?.setDelegate(delegate)
        goalsCacheObserver?.setSubscriber(cacheAdapter)
        goalsCacheObserver?.fetch()
    }
    
}

private extension TodayContentViewController {
    
    private func updateSprintProgress(habits: [Habit]) {
        let progress = CGFloat(habits.filter { $0.isDone(at: currentDate) }.count).safeDivide(by: CGFloat(habits.count))
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
        case .activity: break
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
        habitCellActionsProvider.shouldShowEditAction = { _ in false }
        habitCellActionsProvider.shouldShowDeleteAction = { _ in false }
        
        habitCellActionsProvider.onLink = { [unowned self] indexPath in
            guard let habit = self.habitsCacheObserver?.item(at: indexPath) else { return }
            self.openLink(habit.link)
        }
        habitCellActionsProvider.onEdit = { [unowned self] indexPath in
            guard let habit = self.habitsCacheObserver?.item(at: indexPath) else { return }
            self.transitionHandler?.performSegue(withIdentifier: "ShowHabitEditor", sender: habit)
        }
        habitCellActionsProvider.onDelete = { [unowned self] indexPath in
            guard let habit = self.habitsCacheObserver?.item(at: indexPath) else { return }
            self.showAlert(title: "attention".localized,
                           message: "are_you_sure_you_want_to_remove_habit".localized,
                           actions: [.cancel, .ok("remove".localized)],
                           completion: { action in
                               guard case .ok = action else { return }
                               self.view.isUserInteractionEnabled = false
                               self.habitsService.removeHabit(habit, completion: { [weak self] _ in
                                   HabitsSchedulerService.shared.removeNotifications(for: habit, completion: {})
                                   guard let self = self else { return }
                                   self.view.isUserInteractionEnabled = true
//                                   self.habitsSynchronizationService.sync(habit: habit, sprintID: self.sprintID, completion: { _ in })
                               })
                           })
        }
    }
    
    func setupTargetCellActionsProvider() {
        targetCellActionsProvider.shouldShowDoneAction = { [unowned self] indexPath in
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return false }
            return !goal.isDone
        }
        targetCellActionsProvider.shouldShowEditAction = { _ in false }
        targetCellActionsProvider.shouldShowDeleteAction = { _ in true }
        
        targetCellActionsProvider.onDone = { [unowned self] indexPath in
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return }
            goal.isDone = !goal.isDone
            self.goalsService.updateGoal(goal, sprintID: self.sprintID, completion: { _ in })
        }
        targetCellActionsProvider.onEdit = { [unowned self] indexPath in
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return }
            self.transitionHandler?.performSegue(withIdentifier: "ShowTargetEditor", sender: goal)
        }
        targetCellActionsProvider.onDelete = { [unowned self] indexPath in
            guard let goal = self.goalsCacheObserver?.item(at: indexPath) else { return }
            self.showAlert(title: "attention".localized,
                           message: "are_you_sure_you_want_to_remove_goal".localized,
                           actions: [.cancel, .ok("remove".localized)],
                           completion: { action in
                               guard case .ok = action else { return }
                               self.view.isUserInteractionEnabled = false
                               self.goalsService.removeGoal(goal, completion: { _ in
                                   self.view.isUserInteractionEnabled = true
                               })
                           })
        }
    }
    
}
