//
//  HabitCreationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class HabitCreationViewController: BaseViewController {
    
    @IBOutlet var headerView: LargeHeaderView!
    
    let stackViewController = StackViewController()
    
    @IBOutlet var titleField: GrowingTextView!
    
    let dueDaysContainer = SectionContainer()
    let weekdaysView = HabitCreationDueDaysView()
    
    let valueContainer = SectionContainer()
    let valuePicker = HabitCreationValuePickerView()
    let valueToggle = FloatingButton()
    
    let dueTimeContainer = SectionContainer()
    let dueTimeLabel = UILabel()
    let dueTimeToggle = FloatingButton()
    
    let notificationContainer = SectionContainer()
    let notificationLabel = UILabel()
    let notificationTimeAddButton = FloatingButton()
    
    let descriptionContainer = SectionContainer()
    let descriptionField = GrowingTextView()
        
    private let interactor = HabitCreationInteractor()
    let habitsService = ServicesAssembly.shared.habitsService
    let schedulerService = HabitsSchedulerService()
    
    let keyboardManager = KeyboardManager()
    var contentScrollViewOffset: CGFloat?
    
    let timePickerContainer = ViewControllersFactory.editorContainer
    let timePicker = ViewControllersFactory.notificationTimePicker
    lazy var dueTimeEditorHandler = EditorHandler { [unowned self] in
        self.habit.dueTime = self.timePicker.time
        self.lastSelectedDueTime = self.timePicker.time
        self.updateDueTime()
        self.setDueTimeVisible(true, animated: true)
    }
    
    let notificationPickerContainer = ViewControllersFactory.editorContainer
    var notificationPicker: NotificationPicker?
    lazy var notificationsEditorHandler = EditorHandler { [unowned self] in
        self.habit.notification = notificationPicker?.selectedNotification ?? .none
        self.updateNotificationTime()
    }
    
    var habit: Habit!
    var sprint: Sprint!
    var goalID: String!
    
    var editingMode: GoalAndHabitEditingMode = .full
    
    var lastSelectedDueTime: Time?
    var lastSelectedValue: Habit.Value?
    
    func setHabit(_ habit: Habit?, sprint: Sprint, goalID: String?) {
        self.habit = habit?.copy ?? interactor.createHabit()
        self.sprint = sprint
        self.goalID = goalID
        self.lastSelectedDueTime = self.habit.dueTime
        self.lastSelectedValue = self.habit.value
    }
    
    func setEditingMode(_ mode: GoalAndHabitEditingMode) {
        self.editingMode = mode
        
        dueDaysContainer.isHidden = mode == .short
    }
    
    override func prepare() {
        super.prepare()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        setupContentViews()
        setupDoneButton()
        setupTitleField()
        setupKeyboardManager()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delaysTouchesEnded = false
        stackViewController.stackView.addGestureRecognizer(tapRecognizer)
    }
    
    override func refresh() {
        super.refresh()
        
        updateUI(habit: habit)
        if titleField.textView.text.isEmpty {
            titleField.becomeFirstResponder()
        }
    }
    
    override func setupAppearance() {
        super.setupAppearance()
                
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        stackViewController.view.backgroundColor = AppTheme.current.colors.middlegroundColor     
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleField.resignFirstResponder()
    }
    
    @IBAction private func onClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onDone() {
        updateHabitTitle()
        updateHabitDescription()
        habit.repeatEndingDate = sprint.endDate
        
        habitsService.updateHabit(habit, sprintID: sprint.id, goalID: goalID, completion: { [weak self] success in
            guard let `self` = self, success else { return }
            
            let scheduleHabitThanClose = {
                self.schedulerService.scheduleHabit(self.habit)
                self.dismiss(animated: true, completion: nil)
            }
            NotificationsConfigurator.getNotificationsPermissionStatus { isAuthorized in
                if isAuthorized {
                    scheduleHabitThanClose()
                } else {
                    NotificationsConfigurator.registerForLocalNotifications(application: UIApplication.shared) { isAuthorized in
                        if isAuthorized {
                            scheduleHabitThanClose()
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        })
    }
    
    @IBAction private func endEditing() {
        view.endEditing(true)
    }
    
    func updateDoneButtonState() {
        headerView.rightButton?.isEnabled = !habit.title.isEmpty
    }
    
    func showTimePicker(time: Time, handler: EditorHandler) {
        timePickerContainer.output = handler
        timePickerContainer.loadViewIfNeeded()
        timePicker.loadViewIfNeeded()
        timePickerContainer.setViewController(timePicker)
        timePicker.setHours(time.hours)
        timePicker.setMinutes(time.minutes)
        present(timePickerContainer, animated: true)
    }
    
    func showNotificationPicker(notification: Habit.Notification, handler: EditorHandler) {
        notificationPickerContainer.output = handler
        notificationPickerContainer.loadViewIfNeeded()
        let notificationPicker = NotificationPicker(notification: notification, isTimeSet: habit.dueTime != nil)
        self.notificationPicker = notificationPicker
        notificationPicker.loadViewIfNeeded()
        notificationPickerContainer.setViewController(notificationPicker)
        present(notificationPickerContainer, animated: true)
    }
    
}

extension HabitCreationViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        titleField.setContentOffset(.zero, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            endEditing()
            return false
        }
        return true
    }
    
}

extension HabitCreationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
    
}

extension HabitCreationViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        (touch.view == stackViewController.view || touch.view == stackViewController.stackView) && touch.view != descriptionContainer
    }

}

private extension HabitCreationViewController {
    
    func updateUI(habit: Habit) {
        titleField.textView.text = habit.title
        valueToggle.setState(habit.value == nil ? .default : .active)
        updateValueLabel()
        updateNotificationTime()
        updateDayButtons()
        descriptionField.textView.text = habit.description
        updateDoneButtonState()
        setNotificationTimePickerVisible(habit.notification != .none, animated: false)
        setValuePickerVisible(habit.value != nil, animated: false)
        setDueTimeVisible(habit.dueTime != nil, animated: false)
        updateDueTime()
    }
    
    func setupDoneButton() {
        headerView.rightButton?.setTitle("done".localized, for: .normal)
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .disabled)
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.mainElementColor, for: .normal)
    }
    
}

private extension HabitCreationViewController {
    
    func setupContentViews() {
        addChild(stackViewController)
        view.addSubview(stackViewController.view)
        [stackViewController.view.leading(), stackViewController.view.trailing(), stackViewController.view.bottom()].toSuperview()
        stackViewController.view.topToBottom().to(headerView, addTo: view)
        stackViewController.didMove(toParent: self)
        
        stackViewController.stackView.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        stackViewController.stackView.isLayoutMarginsRelativeArrangement = true
        
        stackViewController.stackView.spacing = 20
        
        setupDueDaysSection(index: 0)
        setupDueTimeSection(index: 1)
        setupNotificationSection(index: 2)
        setupValueSection(index: 3)
        setupDescriptionSection(index: 4)
    }
    
}

final class EditorHandler: EditorContainerOutput {
    
    let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func editingCancelled(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func editingFinished(viewController: UIViewController) {
        onFinish()
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
