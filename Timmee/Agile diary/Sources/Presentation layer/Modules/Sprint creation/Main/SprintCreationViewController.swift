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
    
    @IBOutlet private var startDateButton: UIButton!
    @IBOutlet private var notificationsButton: UIButton!
    
    @IBOutlet private var addButton: UIButton!
    @IBOutlet private var addHabitMenu: UIStackView!
    @IBOutlet private var createHabitMenuButton: UIButton!
    @IBOutlet private var habitsCollectionMenuButton: UIButton!
    @IBOutlet private var dimmedBackgroundView: UIView!
    
    private var contentViewController: SprintContentViewController!
    
    private var currentSection = SprintSection.habits
    
    private var itemsCountBySection: [SprintSection: Int] = [:]
    
    var sprint: Sprint! {
        didSet {
            contentViewController.sprintID = sprint.id
            headerView.titleLabel.text = "Sprint".localized + " #\(sprint.number)"
            showStartDate(sprint.startDate)
            updateDoneButtonState()
        }
    }
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    let habitsService = ServicesAssembly.shared.habitsService
    let goalsService = ServicesAssembly.shared.goalsService
    let schedulerService = HabitsSchedulerService()
    
    override func prepare() {
        super.prepare()
        
        UserProperty.isInitialSprintCreated.setBool(false)
        setupDoneButton()
        headerView.leftButton?.isHidden = sprint == nil
        sectionSwitcher.items = [SprintSection.habits.title, SprintSection.goals.title]
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        
        createHabitMenuButton.setTitle("create_habit".localized, for: .normal)
        habitsCollectionMenuButton.setTitle("choose_habits_from_collection".localized, for: .normal)
        
        hideAddHabitMenu()
        
        if sprint == nil {
            getOrCreateSprint { [weak self] sprint in
                self?.sprint = sprint
            }
        }
    }
    
    override func refresh() {
        super.refresh()
        
        guard let sprint = sprint else { return }
        
        if sprint.startDate.compare(Date.now.startOfDay) == .orderedAscending {
            sprint.startDate = Date.now.startOfDay
            sprint.endDate = Date.now.startOfDay + Constants.sprintDuration.asWeeks
            updateDoneButtonState()
        }
        
        showStartDate(sprint.startDate)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        contentContainerView.backgroundColor = AppTheme.current.colors.middlegroundColor
        headerView.titleLabel.textColor = AppTheme.current.colors.activeElementColor
        headerView.subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        headerView.leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        headerView.rightButton?.tintColor = AppTheme.current.colors.mainElementColor
        sectionSwitcher.setupAppearance()
        
        addButton.tintColor = .white
        addButton.adjustsImageWhenHighlighted = false
        addButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        addButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .highlighted)
        addButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .selected)
        createHabitMenuButton.tintColor = .white
        createHabitMenuButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        createHabitMenuButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .highlighted)
        createHabitMenuButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .selected)
        habitsCollectionMenuButton.tintColor = .white
        habitsCollectionMenuButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        habitsCollectionMenuButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .highlighted)
        habitsCollectionMenuButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .selected)
        
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SprintContent" {
            contentViewController = segue.destination as? SprintContentViewController
            contentViewController.section = currentSection
            contentViewController.transitionHandler = self
            contentViewController.delegate = self
        } else if segue.identifier == "ShowGoalCreation" {
            guard let controller = segue.destination as? TargetCreationViewController else { return }
            controller.setGoal(sender as? Goal, sprintID: sprint.id)
        } else if segue.identifier == "ShowHabitCreation" {
            guard let controller = segue.destination as? HabitCreationViewController else { return }
            controller.setHabit(sender as? Habit, sprintID: sprint.id)
        } else if segue.identifier == "ShowHabitsCollection" {
            guard let controller = segue.destination as? HabitsCollectionViewController else { return }
            controller.sprintID = sprint.id
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func showStartDate(_ date: Date) {
        let resultStirng = NSMutableAttributedString(string: "starts".localized + " ", attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        let dateString = NSAttributedString(string: date.asNearestShortDateString.lowercased(), attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor])
        resultStirng.append(dateString)
        headerView.subtitleLabel.attributedText = resultStirng
    }
    
    @objc private func onSwitchSection() {
        currentSection = SprintSection(rawValue: sectionSwitcher.selectedItemIndex) ?? .habits
        contentViewController.section = currentSection
    }
    
    @IBAction private func onTapToSprintStartDate() {
        let editorContainer = ViewControllersFactory.editorContainer
        editorContainer.loadViewIfNeeded()
        let dueDatePicker = ViewControllersFactory.dueDatePicker
        dueDatePicker.output = self
        dueDatePicker.loadViewIfNeeded()
        dueDatePicker.setDueDate(sprint.startDate)
        editorContainer.setViewController(dueDatePicker)
        present(editorContainer, animated: true, completion: nil)
    }
    
    @IBAction private func onTapToNotificationsButton() {
        performSegue(withIdentifier: "ShowSprintNotificationsSettings", sender: nil)
    }
    
    @IBAction private func onClose() {
        showAlert(title: "attention".localized,
                  message: "are_you_sure_you_want_to_cancel_sprint_creation".localized,
                  actions: [.cancel, .ok("close".localized)])
            { action in
                self.close()
            }
    }
    
    @IBAction private func onAdd() {
        switch currentSection {
        case .goals: performSegue(withIdentifier: "ShowGoalCreation", sender: nil)
        case .habits: toggleAddHabitMenu()
        case .water: break
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
        showAlert(title: "attention".localized,
                  message: "are_you_sure_you_want_to_finish_sprint_creation".localized,
                  actions: [.cancel, .ok("finish".localized)])
            { action in
                guard case .ok = action else { return }
                self.sprint.isReady = true
                self.updateNotificationInfoForAllHabits { [weak self] habits in
                    guard let `self` = self else { return }
                    let saveSprintThanClose = {
                        self.saveSprint(self.sprint) { [weak self] success in
                            UserProperty.isInitialSprintCreated.setBool(true)
                            self?.close()
                        }
                    }
                    let scheduleTasksAndSaveSprintThanClose = {
                        habits.forEach { self.schedulerService.scheduleHabit($0) }
                        saveSprintThanClose()
                    }
                    NotificationsConfigurator.getNotificationsPermissionStatus { isAuthorized in
                        if isAuthorized {
                            scheduleTasksAndSaveSprintThanClose()
                        } else {
                            NotificationsConfigurator.registerForLocalNotifications(application: UIApplication.shared) { isAuthorized in
                                if isAuthorized {
                                    scheduleTasksAndSaveSprintThanClose()
                                } else {
                                    saveSprintThanClose()
                                }
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
    
}

extension SprintCreationViewController: DueDatePickerOutput {
    
    func didChangeDueDate(to date: Date) {
        sprint.startDate = date
        sprint.endDate = date + Constants.sprintDuration.asWeeks
        showStartDate(date)
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
    
    func updateNotificationInfoForAllHabits(completion: @escaping ([Habit]) -> Void) {
        let habits = habitsService.fetchHabits(sprintID: sprint.id)
        let repeatEndingDate = sprint.endDate
        habits.forEach {
            guard $0.notificationDate != nil else { return }
            let notificationHour = $0.notificationDate?.hours ?? 0
            let notificationMinute = $0.notificationDate?.minutes ?? 0
            $0.notificationDate = sprint.startDate.startOfDay
            $0.notificationDate => notificationHour.asHours
            $0.notificationDate => notificationMinute.asMinutes
            $0.repeatEndingDate = repeatEndingDate
        }
        habitsService.updateHabits(habits) { _ in
            completion(habits)
        }
    }
    
    func showAddHabitMenu(animated: Bool = false) {
        addHabitMenu.transform = makeaddHabitMenuInitialTransform()
        
        addHabitMenu.isHidden = false
        dimmedBackgroundView.alpha = 0
        dimmedBackgroundView.isHidden = false
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.addHabitMenu.alpha = 1
            self.dimmedBackgroundView.alpha = 1
            self.addHabitMenu.transform = .identity
            self.addButton.isSelected = true
            self.addButton.transform = self.makeAddListButtonRotationTransform()
        }
    }
    
    func hideAddHabitMenu(animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.2 : 0,
                       animations: {
                        self.addHabitMenu.alpha = 0
                        self.dimmedBackgroundView.alpha = 0
                        self.addHabitMenu.transform = self.makeaddHabitMenuInitialTransform()
                        self.addButton.isSelected = false
                        self.addButton.transform = .identity
        }) { _ in
            self.addHabitMenu.isHidden = true
            self.dimmedBackgroundView.isHidden = true
        }
    }
    
    func makeaddHabitMenuInitialTransform() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: 0, y: 64)
        let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
        return scale.concatenating(translation)
    }
    
    func makeAddListButtonRotationTransform() -> CGAffineTransform {
        return CGAffineTransform(rotationAngle: 45 * .pi / 180)
    }
    
}
