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
    
    private var contentView: UITableView!
    
    // MARK: Add button
    
    private let createButton = FloatingButton()
    private let addHabitMenu = UIStackView()
    private let createHabitMenuButton = AddMenuButton()
    private let habitsCollectionMenuButton = AddMenuButton()
    private let dimmedBackgroundView = UIView()
    
    // MARK: Placeholder
    
    private let placeholderView = ScreenPlaceholderView()
    
    let habitsService = ServicesAssembly.shared.habitsService
    let goalsService = ServicesAssembly.shared.goalsService
    let stagesService = ServicesAssembly.shared.subtasksService
        
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: contentView)
    private var habitsCacheObserver: CachedEntitiesObserver<HabitEntity, Habit>?
    private var goalsCacheObserver: CachedEntitiesObserver<GoalEntity, Goal>?
    
    private let targetCellActionsProvider = TodayGoalCellSwipeActionsProvider()
    private let habitCellActionsProvider = TodayHabitCellSwipeActionsProvider()
    
    private let section: SprintSection
    
    init(section: SprintSection) {
        self.section = section
        
        super.init(nibName: nil, bundle: nil)
        
        setupCurrentCacheObserver()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentView()
        
        setupCreateButton()
        setupAddHabitMenu()
        
        setupPlaceholder()
        
        setupCurrentCacheObserver()
        
        cacheAdapter.onReloadFail = { [weak self] in
            self?.setupContentView()
            self?.contentView.reloadData()
        }
        
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
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.section {
        case .habits: return habitsCacheObserver?.numberOfItems(in: section) ?? 0
        case .goals: return goalsCacheObserver?.numberOfItems(in: section) ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section.itemsKind {
        case .habit:
            let cell = tableView.dequeueReusableCell(withIdentifier: TodayHabitCell.identifier, for: indexPath) as! TodayHabitCell
            if let habit = habitsCacheObserver?.item(at: indexPath) {
                cell.configure(habit: habit, currentDate: currentDate)
                cell.setFlat(false)
                cell.setHoriznotalInsets(15)
                cell.delegate = habitCellActionsProvider
                cell.onChangeCheckedState = { [unowned self] isChecked in
                    habit.setDone(isChecked, at: self.currentDate)
                    self.habitsService.updateHabit(habit, sprintID: self.sprintID, goalID: nil, completion: { _ in })
                }
            }
            return cell
        case .goal:
            let cell = tableView.dequeueReusableCell(withIdentifier: TodayGoalCell.identifier, for: indexPath) as! TodayGoalCell
            if let goal = goalsCacheObserver?.item(at: indexPath) {
                cell.configure(goal: goal, currentDate: self.currentDate)
                cell.delegate = targetCellActionsProvider
                
                cell.onChangeHabitCheckedState = { [unowned self] isChecked, habit in
                    habit.setDone(isChecked, at: self.currentDate)
                    self.habitsService.updateHabit(habit, completion: { _ in })
                }
                
                cell.onChangeStageCheckedState = { [unowned self] isChecked, stage in
                    stage.isDone = isChecked
                    self.stagesService.updateSubtask(stage, completion: nil)
                }
            }
            return cell
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
        tableView.deselectRow(at: indexPath, animated: false)
        
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
            let goalDetailsProvider = GoalDetailsProvider(goal: goal, currentDate: currentDate)
            let goalDetailsViewController = DetailsBaseViewController(content: goalDetailsProvider)
            let navigationController = makeNavigationController(root: goalDetailsViewController)
            
            goalDetailsProvider.holderViewController = navigationController
            
            goalDetailsProvider.onEdit = { [unowned self, unowned navigationController] in
                navigationController.dismiss(animated: true, completion: {
                    self.transitionHandler?.performSegue(withIdentifier: "ShowTargetEditor", sender: goal)
                })
            }
            goalDetailsProvider.onSelectHabit = { [unowned self, unowned navigationController] habit in
                navigationController.dismiss(animated: true, completion: {
                    self.transitionHandler?.performSegue(withIdentifier: "ShowHabitEditor", sender: habit)
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
        }
    }
    
}

private extension TodayContentViewController {
    
    func setupCurrentCacheObserver() {
        guard !sprintID.trimmed.isEmpty else { return }
        switch section {
        case .habits: setupHabitsCacheObserver(forSection: section, sprintID: sprintID)
        case .goals: setupGoalsCacheObserver(forSection: section, sprintID: sprintID)
        }
    }
    
    func setupHabitsCacheObserver(forSection section: SprintSection, sprintID: String) {
        goalsCacheObserver = nil
        habitsCacheObserver = ServicesAssembly.shared.habitsService.habitsScope(
            sprintID: sprintID,
            day: DayUnit(weekday: currentDate.weekday),
            date: currentDate.endOfDay() ?? currentDate.endOfDay
        )
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
    
    @objc func showTaskEditor() {
        switch section {
        case .habits:
            hideAddHabitMenu()
            transitionHandler?.performSegue(withIdentifier: "ShowHabitEditor", sender: nil)
        case .goals:
            transitionHandler?.performSegue(withIdentifier: "ShowTargetEditor", sender: nil)
        }
    }
    
}

private extension TodayContentViewController {
    
    func setupPlaceholder() {
        placeholderView.setup(into: view)
        placeholderView.setVisible(false, animated: false)
        
        placeholderView.configure(
            title: section == .habits
                ? "today_habits_section_placeholder_title".localized
                : "today_targets_section_placeholder_title".localized,
            message: nil,
            action: nil,
            onTapButton: nil
        )
    }
    
    func setupPlaceholderAppearance() {
        placeholderView.titleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        placeholderView.messageLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
    }
    
    func showPlaceholder() {
        contentView.isHidden = true
        placeholderView.setVisible(true, animated: false)
    }
    
    func hidePlaceholder() {
        contentView.isHidden = false
        placeholderView.setVisible(false, animated: false)
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

private extension TodayContentViewController {
    
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
        contentView.delaysContentTouches = false
        
        contentView.backgroundColor = AppTheme.current.colors.middlegroundColor
        
        contentView.register(
            TodayHabitCell.self,
            forCellReuseIdentifier: TodayHabitCell.identifier
        )
        contentView.register(
            TodayGoalCell.self,
            forCellReuseIdentifier: TodayGoalCell.identifier
        )
        contentView.register(
            TableHeaderViewWithTitle.self,
            forHeaderFooterViewReuseIdentifier: "Header"
        )
        
        self.contentView = contentView
        
        cacheAdapter.tableView = contentView
    }
    
    func setupCreateButton() {
        view.addSubview(createButton)
        createButton.setImage(UIImage(named: "plus"), for: .normal)
        createButton.addTarget(self, action: #selector(onTapCreateButton), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.colors = FloatingButton.Colors(tintColor: .white,
                                                    backgroundColor: AppTheme.current.colors.mainElementColor,
                                                    secondaryBackgroundColor: AppTheme.current.colors.inactiveElementColor)
        createButton.width(52)
        createButton.height(52)
        createButton.centerX().toSuperview()
        if #available(iOS 11.0, *) {
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        } else {
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        }
    }
    
    @objc func onTapCreateButton() {
        switch section {
        case .habits:
            toggleAddHabitMenu()
        case .goals:
            showTaskEditor()
        }
    }
    
}

// MARK: - Add habit

extension TodayContentViewController {
    
    @objc func toggleAddHabitMenu() {
        if addHabitMenu.isHidden {
            showAddHabitMenu(animated: true)
        } else {
            hideAddHabitMenu(animated: true)
        }
    }
    
    @objc func onTapAddHabitFromCollectionButton() {
        toggleAddHabitMenu()
        
        let screen = ViewControllersFactory.habitsCollectionViewController
        screen.sprintID = sprintID
        let navigation = UINavigationController(rootViewController: screen)
        navigation.isNavigationBarHidden = true
        
        transitionHandler?.present(navigation, animated: true, completion: nil)
    }
    
    @objc func onTapDimmedBackground() {
        toggleAddHabitMenu()
    }
    
    func showAddHabitMenu(animated: Bool = false) {
        addHabitMenu.transform = makeAddHabitMenuInitialTransform()
        addHabitMenu.isHidden = false
        
        dimmedBackgroundView.alpha = 0
        dimmedBackgroundView.isHidden = false
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.createButton.setState(.active)
            self.addHabitMenu.alpha = 1
            self.dimmedBackgroundView.alpha = 1
            self.addHabitMenu.transform = .identity
            self.createButton.isSelected = true
        }
    }
    
    func hideAddHabitMenu(animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.2 : 0,
                       animations: {
                        self.createButton.setState(.default)
                        self.addHabitMenu.alpha = 0
                        self.dimmedBackgroundView.alpha = 0
                        self.addHabitMenu.transform = self.makeAddHabitMenuInitialTransform()
                        self.createButton.isSelected = false
        }) { _ in
            self.addHabitMenu.isHidden = true
            self.dimmedBackgroundView.isHidden = true
        }
    }
    
    func makeAddHabitMenuInitialTransform() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: 0, y: 64)
        let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
        return scale.concatenating(translation)
    }
    
    func setupAddHabitMenu() {
        view.insertSubview(addHabitMenu, belowSubview: createButton)
        addHabitMenu.axis = .vertical
        addHabitMenu.spacing = 12
        addHabitMenu.translatesAutoresizingMaskIntoConstraints = false
        addHabitMenu.width(196)
        [addHabitMenu.centerX(), addHabitMenu.bottomToTop(-12)].to(createButton, addTo: view)
        
        [createHabitMenuButton, habitsCollectionMenuButton].forEach {
            $0.setupAppearance()
            $0.height(36)
            $0.titleLabel?.font = AppTheme.current.fonts.medium(15)
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            addHabitMenu.addArrangedSubview($0)
        }
        
        createHabitMenuButton.setTitle("create_habit".localized, for: .normal)
        habitsCollectionMenuButton.setTitle("choose_habits_from_collection".localized, for: .normal)
        
        createHabitMenuButton.addTarget(self, action: #selector(showTaskEditor), for: .touchUpInside)
        habitsCollectionMenuButton.addTarget(self, action: #selector(onTapAddHabitFromCollectionButton), for: .touchUpInside)
        
        hideAddHabitMenu()
        
        view.insertSubview(dimmedBackgroundView, belowSubview: addHabitMenu)
        dimmedBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        dimmedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        dimmedBackgroundView.allEdges().toSuperview()
        dimmedBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapDimmedBackground)))
    }
    
}
