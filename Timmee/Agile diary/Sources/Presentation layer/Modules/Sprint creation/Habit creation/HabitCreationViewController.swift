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
    
    @IBOutlet private var headerView: LargeHeaderView!
    
    private let stackViewController = StackViewController()
    
    @IBOutlet private var titleField: GrowingTextView!
    
    private let dueDaysContainer = SectionContainer()
    private let weekdaysView = HabitCreationDueDaysView()
    
    private let valueContainer = SectionContainer()
    private let valuePicker = HabitCreationValuePickerView()
    private let valueCheckbox = Checkbox()
    
    private let dayTimeContainer = SectionContainer()
    private let dayTimePicker = HabitCreationDayTimePicker()
    
    private let notificationContainer = SectionContainer()
    private let notificationTimeCheckbox = Checkbox()
    private let notificationTimePicker = UIStoryboard(name: "SprintCreation", bundle: nil)
        .instantiateViewController(withIdentifier: "NotificationTimePicker")
        as! NotificationTimePicker
    
    private let linkContainer = SectionContainer()
    private let linkField = UITextField()
        
    private let interactor = HabitCreationInteractor()
    let habitsService = ServicesAssembly.shared.habitsService
    let schedulerService = HabitsSchedulerService()
    
    private let keyboardManager = KeyboardManager()
    private var contentScrollViewOffset: CGFloat = 0
    
    var habit: Habit!
    var sprintID: String!
    var goalID: String!
    
    var editingMode: GoalAndHabitEditingMode = .full
    
    private var lastSelectedValue: Habit.Value?
    private var lastSelectedNotificationTime: Date?
    
    func setHabit(_ habit: Habit?, sprintID: String, goalID: String?) {
        self.habit = habit?.copy ?? interactor.createHabit()
        self.sprintID = sprintID
        self.goalID = goalID
        self.lastSelectedValue = self.habit.value
        self.lastSelectedNotificationTime = self.habit.notificationDate ?? Date.now
    }
    
    func setEditingMode(_ mode: GoalAndHabitEditingMode) {
        self.editingMode = mode
    }
    
    override func prepare() {
        super.prepare()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        setupContentViews()
        setupDoneButton()
        setupTitleField()
        setupLinkField()
        setupValueCheckbox()
        setupNotificationCheckbox()
        setupKeyboardManager()
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
        
        dueDaysContainer.setupAppearance()
        valueContainer.setupAppearance()
        dayTimeContainer.setupAppearance()
        notificationContainer.setupAppearance()
        linkContainer.setupAppearance()
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        stackViewController.view.backgroundColor = AppTheme.current.colors.middlegroundColor
        titleField.textView.textColor = AppTheme.current.colors.activeElementColor
        titleField.textView.font = AppTheme.current.fonts.bold(28)
        titleField.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme        
        linkField.textColor = AppTheme.current.colors.activeElementColor
        linkField.font = AppTheme.current.fonts.medium(17)
        linkField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
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
        updateHabitLink()
        habitsService.updateHabit(habit, sprintID: sprintID, goalID: goalID, completion: { [weak self] success in
            guard let `self` = self, success else { return }
            if self.editingMode == .full {
                self.dismiss(animated: true, completion: nil)
            } else {
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
            }
        })
    }
    
    @IBAction private func endEditing() {
        view.endEditing(true)
    }
    
}

extension HabitCreationViewController: NotificationTimePickerOutput {
    
    func didChangeHours(to hours: Int) {
        habit.notificationDate => hours.asHours
        lastSelectedNotificationTime => hours.asHours
        dayTimePicker.setDayTime(habit.calculatedDayTime)
    }
    
    func didChangeMinutes(to minutes: Int) {
        habit.notificationDate => minutes.asMinutes
        lastSelectedNotificationTime => minutes.asMinutes
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
        return touch.view == stackViewController.view || touch.view == stackViewController.stackView
    }

}

private extension HabitCreationViewController {
    
    func updateUI(habit: Habit) {
        titleField.textView.text = habit.title
        notificationTimeCheckbox.isChecked = habit.notificationDate != nil
        valueCheckbox.isChecked = habit.value != nil
        updateValueLabel()
        updateNotificationTime()
        updateDayButtons()
        linkField.text = habit.link
        updateDoneButtonState()
        setNotificationTimePickerVisible(habit.notificationDate != nil, animated: false)
        setValuePickerVisible(habit.value != nil, animated: false)
        dayTimePicker.setDayTime(habit.calculatedDayTime)
    }
    
    func updateValueLabel() {
        valuePicker.update(habit: habit)
    }
    
    func updateNotificationTime() {
        notificationTimePicker.setHours(habit.notificationDate?.hours ?? lastSelectedNotificationTime?.hours ?? 0)
        notificationTimePicker.setMinutes(habit.notificationDate?.minutes ?? lastSelectedNotificationTime?.minutes ?? 0)
        notificationTimePicker.view.isUserInteractionEnabled = habit.notificationDate != nil // TODO: ???
    }
    
    func setupDoneButton() {
        headerView.rightButton?.setTitle("done".localized, for: .normal)
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .disabled)
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.mainElementColor, for: .normal)
    }
    
    func updateDoneButtonState() {
        headerView.rightButton?.isEnabled = !habit.title.isEmpty && isHabitLinkValid(link: getHabitLink())
    }
    
    func updateHabitLinkValidity() {
        linkField.textColor = isHabitLinkValid(link: getHabitLink()) ? AppTheme.current.colors.activeElementColor : AppTheme.current.colors.wrongElementColor
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
        
        // due days
        dueDaysContainer.configure(title: "due_days".localized, content: weekdaysView)
        dueDaysContainer.contentContainer.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        weekdaysView.height(32)
        weekdaysView.onSelectDay = { [unowned self] _ in
            self.updateHabitRepeatingDays()
        }
        stackViewController.setChild(dueDaysContainer, at: 0)
        
        // value
        valueContainer.configure(
            title: "amount".localized,
            content: valuePicker,
            actionView: valueCheckbox
        )
        valuePicker.onChangeValue = { [unowned self] in
            self.updateHabitValue()
            self.updateValueLabel()
        }
        stackViewController.setChild(valueContainer, at: 1)
        
        // daytime
        dayTimeContainer.configure(
            title: "day_time".localized,
            content: dayTimePicker
        )
        dayTimeContainer.contentContainer.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        dayTimePicker.onSelectDayTime = { [unowned self] dayTime in
            self.habit.dayTime = dayTime
        }
        stackViewController.setChild(dayTimeContainer, at: 2)
        
        //reminder
        notificationContainer.configure(
            title: "reminder".localized,
            content: notificationTimePicker.view,
            actionView: notificationTimeCheckbox
        )
        notificationTimePicker.view.width(96)
        notificationTimePicker.view.height(96)
        stackViewController.setChild(notificationContainer, at: 3)
        
        // link
        linkContainer.configure(
            title: "link".localized,
            content: linkField,
            disclaimer: "link_hint".localized
        )
        linkContainer.contentContainer.layoutMargins = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
        stackViewController.setChild(linkContainer, at: 4)
    }
    
    func setupNotificationCheckbox() {
        notificationTimeCheckbox.width(32)
        notificationTimeCheckbox.height(32)
        notificationTimeCheckbox.backgroundColor = .clear
        notificationTimeCheckbox.didChangeCkeckedState = { [unowned self] isChecked in
            self.habit.notificationDate = isChecked ? self.lastSelectedNotificationTime ?? Date.now : nil
            if self.habit.notificationDate != nil {
                self.lastSelectedNotificationTime = self.habit.notificationDate
            }
            self.updateNotificationTime()
            self.setNotificationTimePickerVisible(isChecked, animated: true)
        }
    }
    
    func setupValueCheckbox() {
        valueCheckbox.width(32)
        valueCheckbox.height(32)
        valueCheckbox.backgroundColor = .clear
        valueCheckbox.didChangeCkeckedState = { [unowned self] isChecked in
            self.habit.value = isChecked ? self.lastSelectedValue ?? Habit.Value(amount: 1, units: .times) : nil
            if self.habit.value != nil {
                self.lastSelectedValue = self.habit.value
            }
            self.updateValueLabel()
            self.setValuePickerVisible(isChecked, animated: true)
        }
    }
    
    func setNotificationTimePickerVisible(_ isVisible: Bool, animated: Bool) {
//        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.notificationContainer.contentContainer.isHidden = !isVisible
//            self.view.layoutIfNeeded()
//        }
    }
    
    func setValuePickerVisible(_ isVisible: Bool, animated: Bool) {
//        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.valueContainer.contentContainer.isHidden = !isVisible
//            self.view.layoutIfNeeded()
//        }
    }
    
}

private extension HabitCreationViewController {
    
    func setupTitleField() {
        titleField.textView.delegate = self
        titleField.textView.textContainerInset = UIEdgeInsets(top: 3, left: -2, bottom: -1, right: 0)
        titleField.maxNumberOfLines = 5
        titleField.showsVerticalScrollIndicator = false
        titleField.placeholderAttributedText
            = NSAttributedString(string: "habit_title_placeholder".localized,
                                 attributes: [.font: AppTheme.current.fonts.bold(28),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        setupTitleObserver()
    }
    
    func setupTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(habitTitleDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: titleField.textView)
    }
    
    @objc func habitTitleDidChange(notification: Notification) {
        updateHabitTitle()
        updateDoneButtonState()
    }
    
    func getHabitTitle() -> String {
        return titleField.textView.text.trimmed
    }
    
    func updateHabitTitle() {
        habit.title = getHabitTitle()
    }
    
}

private extension HabitCreationViewController {
    
    func setupLinkField() {
        linkField.delegate = self
        linkField.attributedPlaceholder
            = NSAttributedString(string: "habit_link_placeholder".localized,
                                 attributes: [.font: AppTheme.current.fonts.medium(17),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        setupLinkObserver()
    }
    
    func setupLinkObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(habitLinkDidChange),
                                               name: UITextField.textDidChangeNotification,
                                               object: linkField)
    }
    
    @objc func habitLinkDidChange(notification: Notification) {
        updateHabitLink()
        updateDoneButtonState()
        updateHabitLinkValidity()
    }
    
    func getHabitLink() -> String {
        return linkField.text?.trimmed ?? ""
    }
    
    func isHabitLinkValid(link: String) -> Bool {
        guard !link.isEmpty else { return true }
        guard let url = URL(string: link) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func updateHabitLink() {
        let text = getHabitLink()
        if isHabitLinkValid(link: text) {
            habit.link = text
        } else {
            habit.link = ""
        }
    }
    
}

private extension HabitCreationViewController {
    
    func updateDayButtons() {
        let days = habit.dueDays
        
        weekdaysView.updateDayButtons(days: days)
        
        weekdaysView.isUserInteractionEnabled = editingMode == .full
        weekdaysView.alpha = editingMode == .full ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
    }
    
    func updateHabitRepeatingDays() {
        habit.dueDays = weekdaysView.selectedDays
    }
    
}

private extension HabitCreationViewController {
    
    func updateHabitValue() {
        let amount = valuePicker.selectedAmount
        let units = valuePicker.selectedUnits
        habit.value = Habit.Value(amount: amount, units: units)
        lastSelectedValue = habit.value
    }
    
}

private extension HabitCreationViewController {
    
    func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                let offset = self.calculateTargetScrollViewYOffset(keyboardFrame: frame)
                self.contentScrollViewOffset = offset
                self.stackViewController.scrollView.contentOffset.y = offset
                self.stackViewController.scrollView.contentInset.bottom = offset
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                self.stackViewController.scrollView.contentOffset.y -= self.contentScrollViewOffset
                self.stackViewController.scrollView.contentInset.bottom = 0
                self.contentScrollViewOffset = 0
            }
        }
    }
    
    func calculateTargetScrollViewYOffset(keyboardFrame: CGRect) -> CGFloat {
        guard let focusedView = stackViewController.stackView.currentFirstResponder() as? UIView else { return 0 }
        let convertedFocusedViewFrame = focusedView.convert(focusedView.bounds, to: view)
        return max(0, convertedFocusedViewFrame.maxY - keyboardFrame.minY)
    }
    
}
