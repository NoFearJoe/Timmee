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
    @IBOutlet private var dayButtons: [SelectableButton]!
    @IBOutlet private var linkField: GrowingTextView!
    
    private var notificationTimePicker: NotificationTimePickerInput!
    
    private let interactor = HabitCreationInteractor()
    
    var habit: Task!
    var listID: String!
    
    func setHabit(_ habit: Task?, listID: String) {
        self.habit = habit?.copy ?? interactor.createHabit()
        self.listID = listID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleField()
        setupDayButtons()
        setupLinkField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI(habit: habit)
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
        guard interactor.isValidHabit(habit) else { return }
        interactor.saveHabit(habit, listID: listID, success: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
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
        habit.notificationDate! => hours.asHours
    }
    
    func didChangeMinutes(to minutes: Int) {
        habit.notificationDate! => minutes.asMinutes
    }
    
}

extension HabitCreationViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === titleField.textView {
            titleField.setContentOffset(.zero, animated: true)
        } else if textView === linkField.textView {
            linkField.setContentOffset(.zero, animated: true)
        }
    }
    
}

private extension HabitCreationViewController {
    
    func updateUI(habit: Habit) {
        titleField.textView.text = habit.title
        notificationTimePicker.setHours(habit.notificationDate?.hours ?? 0)
        notificationTimePicker.setMinutes(habit.notificationDate?.minutes ?? 0)
        updateDayButtons()
        linkField.textView.text = habit.link
        updateDoneButtonState()
    }
    
    func updateDoneButtonState() {
        headerView.rightButton?.isEnabled = !habit.title.isEmpty && isHabitLinkValid(link: getHabitLink())
    }
    
    func updateHabitLinkValidity() {
        linkField.textView.textColor = isHabitLinkValid(link: getHabitLink()) ? AppTheme.current.colors.activeElementColor : AppTheme.current.colors.wrongElementColor
    }
    
}

private extension HabitCreationViewController {
    
    func setupTitleField() {
        titleField.textView.delegate = self
        titleField.textView.textContainerInset = UIEdgeInsets(top: 0, left: -2, bottom: -3, right: 0)
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
        linkField.textView.delegate = self
        linkField.textView.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        linkField.textView.font = AppTheme.current.fonts.medium(20)
        linkField.maxNumberOfLines = 5
        linkField.showsVerticalScrollIndicator = false
        linkField.placeholderAttributedText
            = NSAttributedString(string: "habit_link_placeholder".localized,
                                 attributes: [.font: AppTheme.current.fonts.medium(20),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        setupLinkObserver()
    }
    
    func setupLinkObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(habitLinkDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: linkField.textView)
    }
    
    @objc func habitLinkDidChange(notification: Notification) {
        updateHabitLink()
        updateDoneButtonState()
        updateHabitLinkValidity()
    }
    
    func getHabitLink() -> String {
        return linkField.textView.text.trimmed
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
