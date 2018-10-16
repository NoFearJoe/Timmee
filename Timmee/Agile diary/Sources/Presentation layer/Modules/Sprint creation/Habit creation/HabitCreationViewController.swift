//
//  HabitCreationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class HabitCreationViewController: BaseViewController, HintViewTrait {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var contentScrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var titleField: GrowingTextView!
    @IBOutlet private var dueDaysTitleLabel: UILabel!
    @IBOutlet private var dayButtons: [SelectableButton]!
    @IBOutlet private var notificationTimeCheckbox: Checkbox!
    @IBOutlet private var notificationTimeTitleLabel: UILabel!
    @IBOutlet private var notificationTimePickerContainer: UIView!
    @IBOutlet private var linkTitleLabel: UILabel!
    @IBOutlet private var linkField: UITextField!
    @IBOutlet private var linkHintButton: UIButton!
    
    var hintPopover: HintPopoverView? {
        didSet {
            hintPopover?.willCloseBlock = {
                self.linkHintButton.isSelected = false
                self.linkHintButton.isUserInteractionEnabled = false
            }
            hintPopover?.didCloseBlock = { self.linkHintButton.isUserInteractionEnabled = true }
        }
    }
    
    private var notificationTimePicker: NotificationTimePickerInput!
    
    private let interactor = HabitCreationInteractor()
    let habitsService = ServicesAssembly.shared.habitsService
    let schedulerService = HabitsSchedulerService()
    
    var habit: Habit!
    var sprintID: String!
    
    var editingMode: TargetAndHabitEditingMode = .full
    
    private var lastSelectedNotificationTime: Date?
    
    func setHabit(_ habit: Habit?, sprintID: String) {
        self.habit = habit?.copy ?? interactor.createHabit()
        self.sprintID = sprintID
        self.lastSelectedNotificationTime = self.habit.notificationDate ?? Date.now
    }
    
    func setEditingMode(_ mode: TargetAndHabitEditingMode) {
        self.editingMode = mode
    }
    
    override func prepare() {
        super.prepare()
        
        setupDoneButton()
        setupTitleField()
        setupDayButtons()
        setupLinkField()
        setupLabels()
        setupNotificationCheckbox()
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
        contentView.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleField.resignFirstResponder()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.updateHintPopover()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedNotificationTimePicker" {
            guard let picker = segue.destination as? NotificationTimePicker else { return }
            picker.output = self
            notificationTimePicker = picker
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @IBAction private func onClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onDone() {
        updateHabitTitle()
        updateHabitLink()
        habitsService.updateHabit(habit, sprintID: sprintID, completion: { [weak self] success in
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
        linkHintButton.isSelected = false
        hideHintPopover()
    }
    
    @IBAction private func onSelectDay(_ button: UIButton) {
        guard !button.isSelected || dayButtons.filter({ $0.isSelected }).count > 1 else { return }
        button.isSelected = !button.isSelected
        updateHabitRepeatingDays()
    }
    
    @IBAction private func onTapToHint(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            self.showFullWidthHintPopover("link_hint".localized, button: button)
        } else {
            self.hideHintPopover()
        }
    }
    
}

extension HabitCreationViewController: NotificationTimePickerOutput {
    
    func didChangeHours(to hours: Int) {
        habit.notificationDate => hours.asHours
        lastSelectedNotificationTime => hours.asHours
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
        return touch.view == contentScrollView || touch.view == contentView
    }
    
}

private extension HabitCreationViewController {
    
    func updateUI(habit: Habit) {
        titleField.textView.text = habit.title
        notificationTimeCheckbox.isChecked = habit.notificationDate != nil
        updateNotificationTime()
        updateDayButtons()
        linkField.text = habit.link
        updateDoneButtonState()
    }
    
    func updateNotificationTime() {
        notificationTimePicker.setHours(habit.notificationDate?.hours ?? lastSelectedNotificationTime?.hours ?? 0)
        notificationTimePicker.setMinutes(habit.notificationDate?.minutes ?? lastSelectedNotificationTime?.minutes ?? 0)
        notificationTimePickerContainer.alpha = habit.notificationDate == nil ? AppTheme.current.style.alpha.disabled : AppTheme.current.style.alpha.enabled
        notificationTimePickerContainer.isUserInteractionEnabled = habit.notificationDate != nil
    }
    
    func setupDoneButton() {
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
    
    func setupLabels() {
        dueDaysTitleLabel.text = "due_days".localized
        notificationTimeTitleLabel.text = "reminder".localized
        linkTitleLabel.text = "link".localized
        [dueDaysTitleLabel, notificationTimeTitleLabel, linkTitleLabel].forEach {
            $0?.textColor = AppTheme.current.colors.inactiveElementColor
        }
    }
    
    func setupNotificationCheckbox() {
        notificationTimeCheckbox.didChangeCkeckedState = { [unowned self] isChecked in
            self.habit.notificationDate = isChecked ? self.lastSelectedNotificationTime ?? Date.now : nil
            if self.habit.notificationDate != nil {
                self.lastSelectedNotificationTime = self.habit.notificationDate
            }
            self.updateNotificationTime()
        }
    }
    
}

private extension HabitCreationViewController {
    
    func setupTitleField() {
        titleField.textView.delegate = self
        titleField.textView.textContainerInset = UIEdgeInsets(top: 3, left: -2, bottom: -1, right: 0)
        titleField.textView.textColor = AppTheme.current.colors.activeElementColor
        titleField.textView.font = AppTheme.current.fonts.bold(28)
        titleField.maxNumberOfLines = 5
        titleField.showsVerticalScrollIndicator = false
        titleField.isUserInteractionEnabled = editingMode == .full
        titleField.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
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
        linkField.textColor = AppTheme.current.colors.activeElementColor
        linkField.font = AppTheme.current.fonts.medium(17)
        linkField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
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
    
    func setupDayButtons() {
        dayButtons.forEach {
            $0.selectedBackgroundColor = $0.tag < 5 ? AppTheme.current.colors.mainElementColor : AppTheme.current.colors.wrongElementColor
            $0.defaultBackgroundColor = AppTheme.current.colors.decorationElementColor
            $0.tintColor = .clear
            $0.setTitleColor(AppTheme.current.colors.activeElementColor, for: .normal)
            $0.setTitleColor(UIColor.white, for: .selected)
            $0.setTitleColor(UIColor.white, for: .highlighted)
        }
    }
    
    func updateDayButtons() {
        let units = habit.dueDays
        dayButtons.forEach {
            $0.isSelected = units.map { $0.number }.contains($0.tag)
            $0.isUserInteractionEnabled = editingMode == .full
            $0.alpha = editingMode == .full ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
        }
    }
    
    func updateHabitRepeatingDays() {
        habit.dueDays = dayButtons.filter { $0.isSelected }.map { DayUnit(number: $0.tag) }
    }
    
}
