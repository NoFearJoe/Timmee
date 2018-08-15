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
    @IBOutlet private var dayButtons: [UIButton]!
    @IBOutlet private var notificationLabel: UILabel!
    
    var habit: Task!
    
    func setHabit(_ habit: Task?) {
//        self.habit = habit?.copy ?? interactor.createHabit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func onClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onDone() {
        // Save
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func endEditing() {
        view.endEditing(true)
    }
    
    @IBAction private func onSelectDay(_ button: UIButton) {
        
    }
    
}

extension HabitCreationViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        titleField.setContentOffset(.zero, animated: true)
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
                                               selector: #selector(targetTitleDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: titleField.textView)
    }
    
    @objc func targetTitleDidChange(notification: Notification) {
        let text = getTargetTitle()
        habit.title = text
    }
    
    func getTargetTitle() -> String {
        return titleField.textView.text.trimmed
    }
    
}
