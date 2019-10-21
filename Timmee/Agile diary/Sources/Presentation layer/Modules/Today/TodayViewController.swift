//
//  TodayViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents
import Synchronization

protocol TodayViewSectionProgressListener: class {
    func didChangeProgress(for section: SprintSection, to progress: CGFloat)
}

final class TodayViewController: BaseViewController, SprintInteractorTrait, AlertInput {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var pickDayButton: PickDayButton!
    @IBOutlet private var actionsButton: UIButton!
    @IBOutlet private var sectionSwitcher: Switcher!
    @IBOutlet private var progressBar: ProgressBar!
    @IBOutlet private var createSprintButton: UIButton!
    @IBOutlet private var backgroundImageView: UIImageView!
    
    @IBOutlet private var contentViewContainer: UIView!
    @IBOutlet private var activityViewContainer: UIView!
    
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = PlaceholderView.loadedFromNib()
    
    private var contentViewController: TodayContentViewController!
    private var activityViewController: ActivityViewController!
    
    @IBOutlet private var contentViewTopConstraint: NSLayoutConstraint!
    
    private var synchronizationDidFinishObservation: Any?
    
    lazy var calendarTransitionHandler = CalendarTransitionHandler(sourceView: pickDayButton)
    
    // MARK: - State
    
    private var currentSection = SprintSection.habits
    
    var currentDate: Date = Date.now.startOfDay() {
        didSet {
            updateCurrentDateLabel()
            contentViewController?.currentDate = currentDate
            activityViewController?.currentDate = currentDate
        }
    }
    
    var sprint: Sprint! {
        didSet {
            hidePlaceholder()
            contentViewController.sprintID = sprint.id
            contentViewController.currentDate = currentDate
            activityViewController.sprint = sprint
            activityViewController.currentDate = currentDate
            updateHeaderSubtitle(sprint: sprint)
        }
    }
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    
    override func prepare() {
        super.prepare()
        
        headerView.subtitleLabel.text = nil
        headerView.subtitleLabel.isHidden = true
        setupSections()
        progressBar.setProgress(0)
        contentViewContainer.isHidden = false
        activityViewContainer.isHidden = true
        createSprintButton.isHidden = true
        
        setupPlaceholder()
        
        subscribeToSynchronizationCompletion()
        setupShowProVersionTracker()
        
        BackgroundImagesLoader.shared.onLoad = { [weak self] in
            DispatchQueue.main.async {
                self?.setupBackgroundImage()
            }
        }
    }
    
    override func refresh() {
        super.refresh()
        
        updateCurrentDateLabel()
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
        
        contentViewController.updateAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackersConfigurator.shared.showProVersionTracker?.commit()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SprintContent" {
            contentViewController = segue.destination as? TodayContentViewController
            contentViewController.section = currentSection
            contentViewController.transitionHandler = self
            contentViewController.progressListener = self
        } else if segue.identifier == "Activity" {
            activityViewController = segue.destination as? ActivityViewController
        } else if segue.identifier == "ShowTargetEditor" {
            segue.destination.presentationController?.delegate = self
            guard let controller = segue.destination as? TargetCreationViewController else { return }
            controller.setGoal(sender as? Goal, sprintID: sprint.id)
            controller.setEditingMode(.short)
        } else if segue.identifier == "ShowHabitEditor" {
            segue.destination.presentationController?.delegate = self
            guard let controller = segue.destination as? HabitCreationViewController else { return }
            controller.setHabit(sender as? Habit, sprintID: sprint.id)
            controller.setEditingMode(.short)
        } else if segue.identifier == "ShowSettings" {
            segue.destination.presentationController?.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc private func onSwitchSection() {
        currentSection = SprintSection(rawValue: sectionSwitcher.selectedItemIndex) ?? .habits
        guard sprint != nil else { return }
        switch currentSection {
        case .habits, .goals:
            contentViewController.section = currentSection
            setSectionContainersVisible(content: true, activity: false)
        case .activity:
            progressBar.setProgress(0, animated: true)
            setSectionContainersVisible(content: false, activity: true)
        }
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
    
    private func setSectionContainersVisible(content: Bool, activity: Bool) {
        contentViewController.performAppearanceTransition(isAppearing: content) { contentViewContainer.isHidden = !content }
        activityViewController.performAppearanceTransition(isAppearing: activity) { activityViewContainer.isHidden = !activity }
    }
    
}

extension TodayViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
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
            setSectionContainersVisible(content: false, activity: false)
        } else {
            pickDayButton.isHidden = true
            createSprintButton.isHidden = false
            setSwitcherEnabled(false)
            headerView.subtitleLabel.text = nil
            headerView.subtitleLabel.isHidden = true
            showCreateSprintPlaceholder()
            setSectionContainersVisible(content: false, activity: false)
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
        if ProVersionPurchase.shared.isPurchased() {
            sectionSwitcher.items = [SprintSection.habits.title, SprintSection.goals.title, SprintSection.activity.title]
        } else {
            sectionSwitcher.items = [SprintSection.habits.title, SprintSection.goals.title]
        }
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
