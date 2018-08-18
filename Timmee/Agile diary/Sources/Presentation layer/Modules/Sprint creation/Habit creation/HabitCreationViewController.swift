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
    @IBOutlet private var notificationLabel: UILabel!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI(habit: habit)
    }
    
    @IBAction private func onClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onDone() {
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
        notificationLabel.text = habit.notificationDate?.asTimeString
        updateDayButtons()
    }
    
}

private extension HabitCreationViewController {
    
    func setupTitleField() {
        titleField.textView.delegate = self
        titleField.textView.textContainerInset = .zero
        titleField.textView.font = UIFont.avenirNextMedium(24)
        titleField.maxNumberOfLines = 5
        titleField.showsVerticalScrollIndicator = false
        titleField.placeholderAttributedText
            = NSAttributedString(string: "habit_title_placeholder".localized,
                                 attributes: [.font: UIFont.avenirNextMedium(24),
                                              .foregroundColor: UIColor(rgba: "dddddd")])
        
        setupTitleObserver()
    }
    
    func setupTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(habitTitleDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: titleField.textView)
    }
    
    @objc func habitTitleDidChange(notification: Notification) {
        let text = getHabitTitle()
        habit.title = text
    }
    
    func getHabitTitle() -> String {
        return titleField.textView.text.trimmed
    }
    
}

private extension HabitCreationViewController {
    
    func setupDayButtons() {
        dayButtons.forEach {
            $0.selectedBackgroundColor = $0.tag < 5 ? UIColor(rgba: "2222ee") : UIColor(rgba: "ee2222")
            $0.defaultBackgroundColor = UIColor(rgba: "f7f7f7")
            $0.tintColor = .clear
            $0.setTitleColor(UIColor(rgba: "444444"), for: .normal)
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
