//
//  TodayViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import TasksKit
import UIComponents
import Synchronization

final class TodayViewController: BaseViewController, SprintInteractorTrait, AlertInput {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var pickDayButton: PickDayButton!
    @IBOutlet private var actionsButton: UIButton!
    @IBOutlet private var sectionSwitcher: Switcher!
    @IBOutlet private var progressBar: ProgressBar!
    @IBOutlet private var createSprintButton: UIButton!
    @IBOutlet private var backgroundImageView: UIImageView!
            
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = PlaceholderView.loadedFromNib()
    
    @IBOutlet private var contentViewContainer: UIView!
    
    private let habitsViewController = TodayContentViewController(section: .habits)
    private let goalsViewController = TodayContentViewController(section: .goals)
    
    private var synchronizationDidFinishObservation: Any?
    
    lazy var calendarTransitionHandler = CalendarTransitionHandler(sourceView: pickDayButton)
    
    // MARK: - State
    
    private var currentSection = SprintSection.habits
    
    var currentDateIsToday = true
    var currentDate: Date = Date.now.startOfDay() {
        didSet {
            currentDateIsToday = currentDate.isWithinSameDay(of: Date.now.startOfDay())
            updateCurrentDateLabel()
            habitsViewController.currentDate = currentDate
            goalsViewController.currentDate = currentDate
        }
    }
    
    var sprint: Sprint! {
        didSet {
            hidePlaceholder()
            habitsViewController.sprintID = sprint.id
            habitsViewController.currentDate = currentDate
            goalsViewController.sprintID = sprint.id
            goalsViewController.currentDate = currentDate
            updateHeaderSubtitle(sprint: sprint)
        }
    }
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    
    override func prepare() {
        super.prepare()
        
        contentViewContainer.addSubview(habitsViewController.view)
        habitsViewController.view.allEdges().toSuperview()
        
        contentViewContainer.addSubview(goalsViewController.view)
        goalsViewController.view.allEdges().toSuperview()
        
        headerView.subtitleLabel.text = nil
        headerView.subtitleLabel.isHidden = true
        setupSections()
        progressBar.setProgress(0)
        createSprintButton.isHidden = true
        
        habitsViewController.transitionHandler = self
        habitsViewController.progressListener = self
        goalsViewController.transitionHandler = self
        goalsViewController.progressListener = self
        
        setupPlaceholder()
        
        subscribeToSynchronizationCompletion()
        setupShowProVersionTracker()
        
        setSectionContainersVisible(section: currentSection)
        
        BackgroundImagesLoader.shared.onLoad = { [weak self] in
            DispatchQueue.main.async {
                self?.setupBackgroundImage()
            }
        }
    }
    
    override func refresh() {
        super.refresh()
        
        /// Ситуация, когда текущая дата - не сегодняшний день, но до этого был выбран сегодняшний день.
        /// Это возникает, когда изменился день с момента последнего обновления экрана.
        if currentDateIsToday, !currentDate.isWithinSameDay(of: Date.now.startOfDay()) {
            currentDate = Date.now.startOfDay()
        } else {
            updateCurrentDateLabel()
        }
        setupSections()
        setupBackgroundImage()
        
        loadSprint()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        headerView.titleLabel.textColor = AppTheme.current.colors.activeElementColor
        headerView.subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        headerView.leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        actionsButton?.tintColor = AppTheme.current.colors.mainElementColor
        progressBar.fillColor = AppTheme.current.colors.mainElementColor
        headerView.backgroundColor = AppTheme.current.colors.foregroundColor
        sectionSwitcher.setupAppearance()
        setupPlaceholderAppearance()
        setupCreateSprintButton()
        sprint.flatMap { updateHeaderSubtitle(sprint: $0) }
        
        habitsViewController.updateAppearance()
        goalsViewController.updateAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TrackersConfigurator.shared.showProVersionTracker?.commit()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTargetEditor" {
            segue.destination.presentationController?.delegate = self
            guard let controller = segue.destination as? GoalCreationViewController else { return }
            let goal = sender as? Goal
            controller.setGoal(goal, sprintID: sprint.id)
            controller.setEditingMode(goal == nil ? .full : .short)
        } else if segue.identifier == "ShowHabitEditor" {
            segue.destination.presentationController?.delegate = self
            guard let controller = segue.destination as? HabitCreationViewController else { return }
            let habit = sender as? Habit
            controller.setHabit(habit, sprintID: sprint.id, goalID: nil)
            controller.setEditingMode(habit == nil ? .full : .short)
        } else if segue.identifier == "ShowSettings" {
            segue.destination.presentationController?.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc private func onSwitchSection() {
        guard sprint != nil else { return }

        let selectedSection = SprintSection(rawValue: sectionSwitcher.selectedItemIndex) ?? .habits
        
        guard selectedSection != currentSection else { return }
                
        currentSection = selectedSection

        setSectionContainersVisible(section: currentSection)
    }
    
    @IBAction private func onTapToPickDayButton() {
        let appColors = AppTheme.current.colors
        let calendarDesign = CalendarDesign(
            defaultBackgroundColor: appColors.foregroundColor,
            defaultTintColor: appColors.activeElementColor,
            selectedBackgroundColor: appColors.mainElementColor,
            selectedTintColor: appColors.activeElementColor,
            disabledBackgroundColor: appColors.middlegroundColor,
            disabledTintColor: appColors.inactiveElementColor,
            weekdaysColor: appColors.wrongElementColor,
            badgeBackgroundColor: appColors.incompleteElementColor,
            badgeTintColor: appColors.activeElementColor
        )
        let calendar = CalendarViewController(design: calendarDesign)
        calendar.view.backgroundColor = AppTheme.current.colors.middlegroundColor
        calendar.configure(selectedDate: currentDate,
                           minimumDate: sprint.startDate,
                           maximumDate: Date.now)
        calendar.onSelectDate = { [unowned self, unowned calendar] date in
            guard let date = date else { return }
            self.currentDate = date
            calendar.dismiss(animated: true, completion: nil)
        }
        
        calendar.modalPresentationStyle = .custom
        calendar.transitioningDelegate = calendarTransitionHandler
        
        present(calendar, animated: true, completion: nil)
    }
    
    @IBAction private func onTapToActionsButton() {
        let actionSheetViewController = ActionSheetViewController(items: [
            ActionSheetItem(
                icon: UIImage(imageLiteralResourceName: "charts"),
                title: "my_progress".localized,
                action: { [unowned self] in
                    self.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "ShowCharts", sender: nil)
                    }
                }
            ),
            ActionSheetItem(
                icon: UIImage(imageLiteralResourceName: "chart"),
                title: "my_sprints".localized,
                action: { [unowned self] in
                    self.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "ShowSprints", sender: nil)
                    }
                }
            ),
            ActionSheetItem(
                icon: UIImage(imageLiteralResourceName: "diary"),
                title: "diary".localized,
                action: { [unowned self] in
                    let diaryViewController = DiaryViewController()
                    
                    self.dismiss(animated: true) {
                        self.present(diaryViewController, animated: true, completion: nil)
                    }
                }
            ),
            ActionSheetItem(
                icon: UIImage(imageLiteralResourceName: "cogwheel"),
                title: "settings".localized,
                action: { [unowned self] in
                    self.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "ShowSettings", sender: nil)
                    }
                }
            )
        ])
        
        actionSheetViewController.backgroundColor = AppTheme.current.colors.foregroundColor
        actionSheetViewController.tintColor = AppTheme.current.colors.activeElementColor
        actionSheetViewController.separatorColor = AppTheme.current.colors.decorationElementColor
        
        present(actionSheetViewController, animated: true, completion: nil)
    }
    
    private func updateHeaderSubtitle(sprint: Sprint) {
        let daysRemaining = Date.now.days(before: sprint.endDate)
        let subtitle = NSMutableAttributedString()
        subtitle.append(NSAttributedString(string: "Sprint".localized, attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        subtitle.append(NSAttributedString(string: " #\(sprint.number)", attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        
        let remainingDaysString = NSMutableAttributedString(string: ", " + "remains_n_days".localized(with: daysRemaining),
                                                            attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor])
        let daysCountRange = NSString(string: remainingDaysString.string).range(of: "\(daysRemaining)")
        remainingDaysString.setAttributes([.foregroundColor: AppTheme.current.colors.mainElementColor], range: daysCountRange)
        
        subtitle.append(remainingDaysString)
        headerView.subtitleLabel.attributedText = subtitle
        headerView.subtitleLabel.isHidden = false
    }
    
    private func setSwitcherEnabled(_ isEnabled: Bool) {
        sectionSwitcher.isEnabled = isEnabled
        sectionSwitcher.alpha = isEnabled ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
        sectionSwitcher.isHidden = !isEnabled
    }
    
    private func setSectionContainersVisible(section: SprintSection?) {
        habitsViewController.performAppearanceTransition(isAppearing: section == .habits) { habitsViewController.view.isHidden = section == .goals }
        goalsViewController.performAppearanceTransition(isAppearing: section == .goals) { goalsViewController.view.isHidden = section == .habits }
    }
    
}

extension TodayViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        refresh()
        setupAppearance()
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        refresh()
        setupAppearance()
    }
    
}

private extension TodayViewController {
    
    func loadSprint() {
        if let currentSprint = getCurrentSprint() {
            pickDayButton.isHidden = false
            createSprintButton.isHidden = true
            setSwitcherEnabled(true)
            sprint = currentSprint
        } else if let nextSprint = getNextSprint() {
            pickDayButton.isHidden = true
            createSprintButton.isHidden = true
            setSwitcherEnabled(false)
            headerView.subtitleLabel.text = "next_sprint_starts".localized + " " + nextSprint.startDate.asNearestShortDateString.lowercased()
            headerView.subtitleLabel.isHidden = false
            showNextSprintPlaceholder(sprintNumber: nextSprint.number, startDate: nextSprint.startDate)
            setSectionContainersVisible(section: nil)
        } else {
            pickDayButton.isHidden = true
            createSprintButton.isHidden = false
            setSwitcherEnabled(false)
            headerView.subtitleLabel.text = nil
            headerView.subtitleLabel.isHidden = true
            showCreateSprintPlaceholder()
            setSectionContainersVisible(section: nil)
        }
    }
    
}

extension TodayViewController: TodayViewSectionProgressListener {
    
    func didChangeProgress(for section: SprintSection, to progress: CGFloat) {
        guard section == currentSection else { return }
        progressBar.setProgress(progress, animated: true)
    }
    
}

private extension TodayViewController {
    
    func updateCurrentDateLabel() {
        headerView.titleLabel.text = currentDate.asNearestShortDateString
    }
    
    func setupSections() {
        sectionSwitcher.items = [SprintSection.habits.title, SprintSection.goals.title]
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        sectionSwitcher.selectedItemIndex = sectionSwitcher.selectedItemIndex
    }
    
    func setupBackgroundImage() {
        if ProVersionPurchase.shared.isPurchased() {
            backgroundImageView.image = BackgroundImage.current.image
        } else {
            backgroundImageView.image = nil
        }
    }
    
}

private extension TodayViewController {
    
    func setupCreateSprintButton() {
        createSprintButton.setTitle("create_sprint".localized, for: .normal)
        createSprintButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        createSprintButton.setTitleColor(.white, for: .normal)
        createSprintButton.layer.cornerRadius = 12
        createSprintButton.clipsToBounds = true
    }
    
}

private extension TodayViewController {
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderContainer.isHidden = true
    }
    
    func setupPlaceholderAppearance() {
        placeholderView.backgroundColor = .clear
        placeholderView.titleLabel.font = AppTheme.current.fonts.medium(18)
        placeholderView.subtitleLabel.font = AppTheme.current.fonts.regular(14)
        placeholderView.titleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        placeholderView.subtitleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
    }
    
    func showNextSprintPlaceholder(sprintNumber: Int, startDate: Date) {
        placeholderContainer.isHidden = false
        placeholderView.icon = #imageLiteral(resourceName: "calendar")
        placeholderView.title = "next_sprint_is".localized + " \("Sprint".localized) #\(sprintNumber)"
        placeholderView.subtitle = "starts".localized + " " + startDate.asNearestShortDateString.lowercased()
    }
    
    func showCreateSprintPlaceholder() {
        placeholderContainer.isHidden = false
        placeholderView.icon = #imageLiteral(resourceName: "calendar")
        placeholderView.title = "there_is_no_sprints".localized
        placeholderView.subtitle = "do_you_want_to_create_new_sprint".localized
    }
    
    func hidePlaceholder() {
        placeholderContainer.isHidden = true
    }
    
}

private extension TodayViewController {
    
    func subscribeToSynchronizationCompletion() {
        let notificationName = NSNotification.Name(rawValue: PeriodicallySynchronizationRunner.didFinishSynchronizationNotificationName)
        synchronizationDidFinishObservation = NotificationCenter.default.addObserver(forName: notificationName,
                                                                                     object: nil,
                                                                                     queue: .main) { [weak self] _ in
                                                                                        self?.loadSprint()
        }
    }
    
    func setupShowProVersionTracker() {
        guard !ProVersionPurchase.shared.isPurchased() else { return }
        TrackersConfigurator.shared.showProVersionTracker?.checkpoint = { [weak self] in
            guard !ProVersionPurchase.shared.isPurchased() else { return }
            self?.performSegue(withIdentifier: "ShowProVersionPurchase", sender: nil)
        }
    }
    
}
