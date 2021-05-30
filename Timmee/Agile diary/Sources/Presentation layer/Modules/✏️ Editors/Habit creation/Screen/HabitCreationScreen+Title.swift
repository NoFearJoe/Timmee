//
//  HabitCreationScreen+Title.swift
//  Agile diary
//
//  Created by Илья Харабет on 29.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

extension HabitCreationViewController {
    
    func setupTitleField() {
        titleField.textView.delegate = self
        titleField.textView.textContainerInset = UIEdgeInsets(top: 3, left: -2, bottom: -1, right: 0)
        titleField.textView.textColor = AppTheme.current.colors.activeElementColor
        titleField.textView.font = AppTheme.current.fonts.bold(28)
        titleField.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme   
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
        titleField.textView.text.trimmed
    }
    
    func updateHabitTitle() {
        habit.title = getHabitTitle()
    }
    
}
