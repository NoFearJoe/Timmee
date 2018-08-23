//
//  HabitCreationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class HabitCreationViewController: UIViewController {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var titleField: GrowingTextView!
    @IBOutlet private var dueDaysTitleLabel: UILabel!
    @IBOutlet private var dayButtons: [SelectableButton]!
    @IBOutlet private var notificationTimeCheckbox: Checkbox!
    @IBOutlet private var notificationTimeTitleLabel: UILabel!
    @IBOutlet private var notificationTimePickerContainer: UIView!
    @IBOutlet private var linkTitleLabel: UILabel!
    @IBOutlet private var linkField: UITextField!
    @IBOutlet private var linkSubtitleLabel: UILabel!
    
    private var notificationTimePicker: NotificationTimePickerInput!
    
    private let interactor = HabitCreationInteractor()
    
    var habit: Task!
    var listID: String!
    
    private var lastSelectedNotificationTime: Date?
    
    func setHabit(_ habit: Task?, listID: String) {
        self.habit = habit?.copy ?? interactor.createHabit()
        self.listID = listID
        self.lastSelectedNotificationTime = self.habit.notificationDate ?? Date()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleField()
        setupDayButtons()
        setupLinkField()
        setupLabels()
        setupNotificationCheckbox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI(habit: habit)
        if titleField.textView.text.isEmpty {
            titleField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleField.resignFirstResponder()
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
        interactor.saveTask(habit, listID: listID, completion: { [weak self] success in
            guard success else { return }
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction private func endEditing() {
        view.endEditing(true)
    }
    
    @IBAction private func onSelectDay(_ button: UIButton) {
        guard !button.isSelected || dayButtons.filter({ $0.isSelected }).count > 1 else { return }
        button.isSelected = !button.isSelected
        updateHabitRepeatingDays()
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
        notificationTimePickerContainer.alpha = habit.notificationDate != nil ? 1 : 0.5
        notificationTimePickerContainer.isUserInteractionEnabled = habit.notificationDate != nil
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
        linkSubtitleLabel.text = "link_hint".localized
        [dueDaysTitleLabel, notificationTimeTitleLabel, linkTitleLabel, linkSubtitleLabel].forEach {
            $0?.textColor = AppTheme.current.colors.inactiveElementColor
        }
    }
    
    func setupNotificationCheckbox() {
        notificationTimeCheckbox.didChangeCkeckedState = { [unowned self] isChecked in
            self.habit.notificationDate = isChecked ? self.lastSelectedNotificationTime ?? Date() : nil
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
        titleField.placeholderAttributedText
            = NSAttributedString(string: "habit_title_placeholder".localized,
                                 attributes: [.font: AppTheme.current.fonts.bold(28),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        setupTitleObserver()
    }
    
    func setupTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(habitTitleDidChange),
                                               name: .UITextViewTextDidChange,
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
        linkField.font = AppTheme.current.fonts.medium(20)
        linkField.attributedPlaceholder
            = NSAttributedString(string: "habit_link_placeholder".localized,
                                 attributes: [.font: AppTheme.current.fonts.medium(20),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        setupLinkObserver()
    }
    
    func setupLinkObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(habitLinkDidChange),
                                               name: .UITextFieldTextDidChange,
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
        guard case .on(let units) = self.habit.repeating.type else { return }
        dayButtons.forEach {
            $0.isSelected = units.dayNumbers.contains($0.tag)
        }
    }
    
    func updateHabitRepeatingDays() {
        habit.repeating = RepeatMask(type: .on(WeekRepeatUnit(string: dayButtons.filter { $0.isSelected }.map { DayUnit(number: $0.tag).string }.joined(separator: ","))))
    }
    
}
