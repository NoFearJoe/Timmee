//
//  SprintCreationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

/*
 Есть 2 кейса при редактировании спринта:
 1. Спринт уже есть. Тогда он передается в свойство sprint
 2. Спринта нет или он создан не до конца. Тогда его нужно создать:
     1. Находим недосозданный спринт (isCompleted == false):
         + Присваиваем в свойство sprint
         - 1. Находим последний спринт
           2. Создаем новый с повышенным порядковым числом
           3. Сохраняем в БД
 */

final class SprintCreationViewController: BaseViewController, SprintInteractorTrait, AlertInput {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    
    @IBOutlet private var contentContainerView: UIView!
    @IBOutlet private var waterControlConfigurationContainerView: UIView!
    
    @IBOutlet private var startDateButton: UIButton!
    @IBOutlet private var notificationsButton: UIButton!
    @IBOutlet private var sprintDurationButton: UIButton!
    
    @IBOutlet private var addButton: AddButton!
    @IBOutlet private var addHabitMenu: UIStackView!
    @IBOutlet private var createHabitMenuButton: AddMenuButton!
    @IBOutlet private var habitsCollectionMenuButton: AddMenuButton!
    @IBOutlet private var dimmedBackgroundView: UIView!
    
    private var sprintSettingsButtons: [UIButton] {
        return [startDateButton, notificationsButton, sprintDurationButton, addButton]
    }
    
    private var contentViewController: SprintContentViewController!
    private var waterControlConfigurationViewController: WaterControlConfigurationViewController!
    
    private var currentSection = SprintSection.habits
    
    private var minimumStartDate: Date = Date.now.startOfDay
    
    private var itemsCountBySection: [SprintSection: Int] = [:]
    
    var sprint: Sprint! {
        didSet {
            guard sprint != nil else { return }
            minimumStartDate = sprint.startDate
            contentViewController.sprintID = sprint.id
            waterControlConfigurationViewController.sprint = sprint
            headerView.titleLabel.text = sprint.title
            headerView?.leftButton?.isHidden = !(canClose || sprint.isReady)
            updateHeaderSubtitle(startDate: sprint.startDate, duration: sprint.duration, sprintNotifications: sprint.notifications)
            updateDoneButtonState()
            updateSprintSettingsButtons()
        }
    }
    
    var canClose: Bool = false
    var isFirstTimeSprintCreation: Bool = true
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    let habitsService = ServicesAssembly.shared.habitsService
    let goalsService = ServicesAssembly.shared.goalsService
    let habitsSchedulerService = HabitsSchedulerService()
    let sprintSchedulerService = SprintSchedulerService()
    
    override func prepare() {
        super.prepare()
        
        setupDoneButton()
        headerView.leftButton?.isHidden = sprint == nil
        headerView.rightButton?.setTitle("done".localized, for: .normal)
        if ProVersionPurchase.shared.isPurchased() {
            sectionSwitcher.items = [SprintSection.habits.title, SprintSection.goals.title, "water".localized]
        } else {
            sectionSwitcher.items = [SprintSection.habits.title, SprintSection.goals.title]
        }
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        
        createHabitMenuButton.setTitle("create_habit".localized, for: .normal)
        habitsCollectionMenuButton.setTitle("choose_habits_from_collection".localized, for: .normal)
        
        hideAddHabitMenu()
        
        setSectionsVisible(content: true, waterConfiguration: false)
    }
    
    override func refresh() {
        super.refresh()
        
        guard let sprint = sprint else {
            getOrCreateSprint { [weak self] sprint in
                self?.sprint = sprint
            }
            return
        }
        
        if sprint.startDate.compare(Date.now.startOfDay) == .orderedAscending, !sprint.isReady {
            sprint.startDate = Date.now.startOfDay
            sprint.endDate = Date.now.endOfDay + sprint.duration.asWeeks
            updateDoneButtonState()
        }
        
        updateHeaderSubtitle(startDate: sprint.startDate, duration: sprint.duration, sprintNotifications: sprint.notifications)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        contentContainerView.backgroundColor = AppTheme.current.colors.middlegroundColor
        waterControlConfigurationContainerView.backgroundColor = AppTheme.current.colors.middlegroundColor
        headerView.titleLabel.textColor = AppTheme.current.colors.activeElementColor
        headerView.subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        headerView.leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        headerView.rightButton?.tintColor = AppTheme.current.colors.mainElementColor
        sectionSwitcher.setupAppearance()
        
        addButton.setupAppearance()
        createHabitMenuButton.setupAppearance()
        habitsCollectionMenuButton.setupAppearance()
        
        startDateButton.tintColor = .white
        startDateButton.adjustsImageWhenHighlighted = false
        startDateButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.selectedElementColor), for: .normal)
        startDateButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .highlighted)
        startDateButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .selected)
        notificationsButton.tintColor = .white
        notificationsButton.adjustsImageWhenHighlighted = false
        notificationsButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.incompleteElementColor), for: .normal)
        notificationsButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .highlighted)
        notificationsButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .selected)
        sprintDurationButton.tintColor = .white
        sprintDurationButton.adjustsImageWhenHighlighted = false
        sprintDurationButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.wrongElementColor), for: .normal)
        sprintDurationButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .highlighted)
        sprintDurationButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .selected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SprintContent" {
            contentViewController = segue.destination as? SprintContentViewController
            contentViewController.section = currentSection
            contentViewController.transitionHandler = self
            contentViewController.delegate = self
        } else if segue.identifier == "WaterControlConfiguration" {
            waterControlConfigurationViewController = segue.destination as? WaterControlConfigurationViewController
            waterControlConfigurationViewController?.mode = .embed
        } else if segue.identifier == "ShowGoalCreation" {
            guard let controller = segue.destination as? TargetCreationViewController else { return }
            controller.setGoal(sender as? Goal, sprintID: sprint.id)
        } else if segue.identifier == "ShowHabitCreation" {
            guard let controller = segue.destination as? HabitCreationViewController else { return }
            controller.setHabit(sender as? Habit, sprintID: sprint.id)
        } else if segue.identifier == "ShowHabitsCollection" {
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard let controller = navigationController.topViewController as? HabitsCollectionViewController else { return }
            controller.sprintID = sprint.id
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc private func onSwitchSection() {
        currentSection = SprintSection(rawValue: sectionSwitcher.selectedItemIndex) ?? .habits
        if currentSection == .activity {
            setSectionsVisible(content: false, waterConfiguration: true)
        } else {
            setSectionsVisible(content: true, waterConfiguration: false)
            contentViewController.section = currentSection
        }
    }
    
    @IBAction private func onTapToSprintStartDate() {
        let editorContainer = ViewControllersFactory.editorContainer
        editorContainer.loadViewIfNeeded()
        let dueDatePicker = ViewControllersFactory.dueDatePicker
        dueDatePicker.output = self
        dueDatePicker.loadViewIfNeeded()
        dueDatePicker.minimumAvailableDate = minimumStartDate
        dueDatePicker.setDueDate(sprint.startDate)
        editorContainer.setViewController(dueDatePicker)
        present(editorContainer, animated: true, completion: nil)
    }
    
    @IBAction private func onTapToNotificationsButton() {
        let editorContainer = ViewControllersFactory.editorContainer
        editorContainer.loadViewIfNeeded()
        let sprintNotificationTimePicker = ViewControllersFactory.sprintNotificationTimePicker
        sprintNotificationTimePicker.output = self
        sprintNotificationTimePicker.loadViewIfNeeded()
        sprintNotificationTimePicker.setNotificationsEnabled(sprint.notifications.isEnabled)
        sprintNotificationTimePicker.setNotificationsDays(sprint.notifications.days ?? [])
        sprintNotificationTimePicker.setNotificationsTime(sprint.notifications.time ?? (0, 0))
        editorContainer.setViewController(sprintNotificationTimePicker)
        present(editorContainer, animated: true, completion: nil)
    }
    
    @IBAction private func onTapToSprintDurationButton() {
        let editorContainer = ViewControllersFactory.editorContainer
        editorContainer.loadViewIfNeeded()
        let sprintDurationPicker = ViewControllersFactory.sprintDurationPicker
        sprintDurationPicker.delegate = self
        sprintDurationPicker.loadViewIfNeeded()
        sprintDurationPicker.setSprintDuration(sprint.duration)
        editorContainer.setViewController(sprintDurationPicker)
        present(editorContainer, animated: true, completion: nil)
    }
    
    @IBAction private func onClose() {
        if sprint.isReady || !isFirstTimeSprintCreation {
            close()
        } else {
            showAlert(title: "attention".localized,
                      message: "are_you_sure_you_want_to_cancel_sprint_creation".localized,
                      actions: [.cancel, .ok("close".localized)])
                { [unowned self] action in
                    guard case .ok = action else { return }
                    self.sprintsService.removeSprint(self.sprint, completion: { [weak self] _ in
                        self?.close()
                    })
                }
        }
    }
    
    @IBAction private func onAdd() {
        switch currentSection {
        case .goals: performSegue(withIdentifier: "ShowGoalCreation", sender: nil)
        case .habits: toggleAddHabitMenu()
        case .activity: break
        }
    }
    
    @IBAction private func toggleAddHabitMenu() {
        if addHabitMenu.isHidden {
            showAddHabitMenu(animated: true)
        } else {
            hideAddHabitMenu(animated: true)
        }
    }
    
    @IBAction private func onTapToCreateHabitButton() {
        hideAddHabitMenu(animated: true)
        performSegue(withIdentifier: "ShowHabitCreation", sender: nil)
    }
    
    @IBAction private func onTapToHabitsCollectionButton() {
        hideAddHabitMenu(animated: true)
        performSegue(withIdentifier: "ShowHabitsCollection", sender: nil)
    }
    
    @IBAction private func onDone() {
        self.sprint.isReady = true
        self.updateNotificationInfoForAllHabits { [weak self] habits in
            guard let `self` = self else { return }
            let saveSprintThanClose = {
                self.saveSprint(self.sprint) { [weak self] success in
                    self?.close()
                }
            }
            let scheduleAndSaveSprintThanClose = {
                self.sprintSchedulerService.scheduleSprint(self.sprint)
                habits.forEach { self.habitsSchedulerService.scheduleHabit($0) }
                saveSprintThanClose()
            }
            NotificationsConfigurator.getNotificationsPermissionStatus { isAuthorized in
                if isAuthorized {
                    scheduleAndSaveSprintThanClose()
                } else {
                    NotificationsConfigurator.registerForLocalNotifications(application: UIApplication.shared) { isAuthorized in
                        if isAuthorized {
                            scheduleAndSaveSprintThanClose()
                        } else {
                            saveSprintThanClose()
                        }
                    }
                }
            }
        }
    }
    
    func setupDoneButton() {
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .disabled)
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.mainElementColor, for: .normal)
    }
    
    func close() {
        if presentingViewController == nil {
            AppDelegate.shared.window?.rootViewController = ViewControllersFactory.today
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func setSectionsVisible(content: Bool, waterConfiguration: Bool) {
        waterControlConfigurationContainerView.isHidden = !waterConfiguration
        contentContainerView.isHidden = !content
        sprintSettingsButtons.forEach { $0.isHidden = !content }
    }
    
}

extension SprintCreationViewController: DueDatePickerOutput {
    
    func didChangeDueDate(to date: Date) {
        sprint.startDate = date
        sprint.endDate = date.endOfDay + sprint.duration.asWeeks
        updateHeaderSubtitle(startDate: sprint.startDate, duration: sprint.duration, sprintNotifications: sprint.notifications)
        updateSprintSettingsButtons()
    }
    
}

extension SprintCreationViewController: SprintNotificationTimePickerOutput {
    
    func didSetNotificationsEnabled(_ isEnabled: Bool) {
        sprint.notifications.isEnabled = isEnabled
        updateHeaderSubtitle(startDate: sprint.startDate, duration: sprint.duration, sprintNotifications: sprint.notifications)
    }
    
    func didChangeNotificationsDays(_ days: [DayUnit]) {
        sprint.notifications.days = days
        updateHeaderSubtitle(startDate: sprint.startDate, duration: sprint.duration, sprintNotifications: sprint.notifications)
    }
    
    func didChangeNotificationsTime(_ time: (Int, Int)) {
        sprint.notifications.time = time
        updateHeaderSubtitle(startDate: sprint.startDate, duration: sprint.duration, sprintNotifications: sprint.notifications)
    }
    
}

extension SprintCreationViewController: SprintDurationPickerDelegate {
    
    func sprintDurationPicker(_ picker: SprintDurationPicker, didSelectSprintDuration duration: Int) {
        sprint.duration = duration
        sprint.endDate = sprint.startDate.endOfDay + duration.asWeeks
        updateHeaderSubtitle(startDate: sprint.startDate, duration: sprint.duration, sprintNotifications: sprint.notifications)
    }
    
}

extension SprintCreationViewController: SprintContentViewControllerDelegate {
    
    func didChangeItemsCount(in section: SprintSection, to count: Int) {
        itemsCountBySection[section] = count
        updateDoneButtonState()
    }
    
}

private extension SprintCreationViewController {
    
    func updateDoneButtonState() {
        let isHabitsEnough = itemsCountBySection[.habits].flatMap { $0 >= 3 } ?? false
        let isGoalsEnough = itemsCountBySection[.goals].flatMap { $0 >= 1 } ?? false
        headerView.rightButton?.isEnabled = Environment.isDebug ? true : isHabitsEnough && isGoalsEnough
    }
    
    func updateHeaderSubtitle(startDate: Date, duration: Int, sprintNotifications: Sprint.Notifications) {
        let resultString = NSMutableAttributedString(string: "starts".localized + " ",
                                                     attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        
        let dateString = NSAttributedString(string: startDate.asNearestShortDateString.lowercased(),
                                            attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor])
        resultString.append(dateString)
        
        let durationString = NSAttributedString(string: ", \(duration) " + "n_weeks".localized(with: duration),
                                                attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        resultString.append(durationString)
        
        if sprintNotifications.isEnabled, let days = sprintNotifications.days, let time = sprintNotifications.time {
            resultString.append(NSAttributedString(string: ", " + "reminder".localized.lowercased() + " ",
                                                   attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor]))
            let repeating = RepeatMask(type: .on(.custom(Set(days))))
            resultString.append(NSAttributedString(string: repeating.localized.lowercased(),
                                                   attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
            resultString.append(NSAttributedString(string: " " + "at".localized + " ",
                                                   attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor]))
            let minutesString = time.1 < 10 ? "0\(time.1)" : "\(time.1)"
            resultString.append(NSAttributedString(string: "\(time.0):" + minutesString,
                                                   attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        } else {
            resultString.append(NSAttributedString(string: ", " + "notifications_are_disabled".localized.lowercased(),
                                                   attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor]))
        }
        
        headerView.subtitleLabel.attributedText = resultString
    }
    
    func updateNotificationInfoForAllHabits(completion: @escaping ([Habit]) -> Void) {
        let habits = habitsService.fetchHabits(sprintID: sprint.id)
        let repeatEndingDate = sprint.endDate
        habits.forEach {
            $0.repeatEndingDate = repeatEndingDate
            guard $0.notificationDate != nil else { return }
            let notificationHour = $0.notificationDate?.hours ?? 0
            let notificationMinute = $0.notificationDate?.minutes ?? 0
            $0.notificationDate = sprint.startDate.startOfDay
            $0.notificationDate => notificationHour.asHours
            $0.notificationDate => notificationMinute.asMinutes
        }
        habitsService.updateHabits(habits) { _ in
            completion(habits)
        }
    }
    
    func updateSprintSettingsButtons() {
        addButton.isHidden = sprint.isReady && sprint.tense == .past
        startDateButton.isHidden = sprint.isReady && sprint.tense != .future
        sprintDurationButton.isHidden = sprint.isReady && sprint.tense != .future
        notificationsButton.isHidden = sprint.isReady && sprint.tense == .past
    }
    
    func showAddHabitMenu(animated: Bool = false) {
        addHabitMenu.transform = makeAddHabitMenuInitialTransform()
        
        addHabitMenu.isHidden = false
        dimmedBackgroundView.alpha = 0
        dimmedBackgroundView.isHidden = false
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.addHabitMenu.alpha = 1
            self.dimmedBackgroundView.alpha = 1
            self.addHabitMenu.transform = .identity
            self.addButton.isSelected = true
        }
    }
    
    func hideAddHabitMenu(animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.2 : 0,
                       animations: {
                        self.addHabitMenu.alpha = 0
                        self.dimmedBackgroundView.alpha = 0
                        self.addHabitMenu.transform = self.makeAddHabitMenuInitialTransform()
                        self.addButton.isSelected = false
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
    
}
