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
    private let notificationTimeAddButton = FloatingButton()
    private let notificationsListView = HabitCreationNotificationsListView()
    
    private let notificationTimePickerContainer = ViewControllersFactory.editorContainer
    private let notificationTimePicker = ViewControllersFactory.notificationTimePicker
    
    private let linkContainer = SectionContainer()
    private let linkField = UITextField()
        
    private let interactor = HabitCreationInteractor()
    let habitsService = ServicesAssembly.shared.habitsService
    let schedulerService = HabitsSchedulerService()
    
    private let keyboardManager = KeyboardManager()
    private var contentScrollViewOffset: CGFloat?
    
    var habit: Habit!
    var sprintID: String!
    var goalID: String!
    
    var editingMode: GoalAndHabitEditingMode = .full
    
    private var lastSelectedValue: Habit.Value?
    
    func setHabit(_ habit: Habit?, sprintID: String, goalID: String?) {
        self.habit = habit?.copy ?? interactor.createHabit()
        self.sprintID = sprintID
        self.goalID = goalID
        self.lastSelectedValue = self.habit.value
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
        notificationTimeAddButton.colors = FloatingButton.Colors(
            tintColor: .white,
            backgroundColor: AppTheme.current.colors.mainElementColor,
            secondaryBackgroundColor: AppTheme.current.colors.inactiveElementColor
        )
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

extension HabitCreationViewController: EditorContainerOutput {
    
    func editingCancelled(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func editingFinished(viewController: UIViewController) {
        habit.notificationsTime.append(notificationTimePicker.time)
        updateNotificationTime()
        
        viewController.dismiss(animated: true, completion: nil)
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
        (touch.view == stackViewController.view || touch.view == stackViewController.stackView) && touch.view != linkContainer
    }

}

private extension HabitCreationViewController {
    
    func updateUI(habit: Habit) {
        titleField.textView.text = habit.title
        valueCheckbox.isChecked = habit.value != nil
        updateValueLabel()
        updateNotificationTime()
        updateDayButtons()
        linkField.text = habit.link
        updateDoneButtonState()
        setNotificationTimePickerVisible(!habit.notificationsTime.isEmpty, animated: false)
        setValuePickerVisible(habit.value != nil, animated: false)
        dayTimePicker.setDayTime(habit.calculatedDayTime)
    }
    
    func updateValueLabel() {
        valuePicker.update(habit: habit)
    }
    
    func updateNotificationTime() {
        setNotificationTimePickerVisible(!habit.notificationsTime.isEmpty, animated: false)
        notificationsListView.reload(with: habit.notificationsTime.map { $0.string })
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
        notificationsListView.onTapDeleteButton = { [unowned self] index in
            self.habit.notificationsTime.remove(at: index)
            self.updateNotificationTime()
        }
        notificationContainer.configure(
            title: "reminders".localized,
            content: notificationsListView,
            actionView: notificationTimeAddButton
        )
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
        notificationTimeAddButton.setImage(UIImage(named: "plus"), for: .normal)
        notificationTimeAddButton.width(32)
        notificationTimeAddButton.height(32)
        notificationTimeAddButton.addTarget(self, action: #selector(onTapNotificationTimeButton), for: .touchUpInside)
    }
    
    @objc func onTapNotificationTimeButton() {
        showNotificationTimePicker(time: Time(Date.now.hours, Date.now.minutes))
    }
    
    func showNotificationTimePicker(time: Time) {
        notificationTimePickerContainer.output = self
        notificationTimePickerContainer.loadViewIfNeeded()
        notificationTimePicker.loadViewIfNeeded()
        notificationTimePickerContainer.setViewController(notificationTimePicker)
        notificationTimePicker.setHours(time.hours)
        notificationTimePicker.setMinutes(time.minutes)
        present(notificationTimePickerContainer, animated: true)
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
                if let offset = self.calculateTargetScrollViewYOffset(keyboardFrame: frame) {
                    self.contentScrollViewOffset = offset
                    self.stackViewController.scrollView.contentOffset.y += offset
                } else {
                    self.contentScrollViewOffset = nil
                }
                self.stackViewController.scrollView.contentInset.bottom = frame.height
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                if let contentScrollViewOffset = self.contentScrollViewOffset {
                    self.stackViewController.scrollView.contentOffset.y -= contentScrollViewOffset
                    self.contentScrollViewOffset = nil
                }
                self.stackViewController.scrollView.contentInset.bottom = 0
            }
        }
    }
    
    func calculateTargetScrollViewYOffset(keyboardFrame: CGRect) -> CGFloat? {
        guard var focusedView = stackViewController.stackView.currentFirstResponder() as? UIView else { return nil }
        
        if focusedView === linkField {
            focusedView = linkContainer
        }
        
        let convertedFocusedViewFrame = focusedView.convert(focusedView.bounds, to: view)
        
        let visibleContentHeight = view.bounds.height - headerView.bounds.height - keyboardFrame.height
        
        let focusedViewMaxY = convertedFocusedViewFrame.maxY - headerView.bounds.height
        
        if visibleContentHeight > focusedViewMaxY {
            return nil
        } else {
            return max(0, focusedViewMaxY - visibleContentHeight)
        }
    }
    
}
