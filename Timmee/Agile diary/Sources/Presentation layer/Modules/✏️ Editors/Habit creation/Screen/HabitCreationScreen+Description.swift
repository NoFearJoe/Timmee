//
//  HabitCreationScreen+Description.swift
//  Agile diary
//
//  Created by Илья Харабет on 29.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

extension HabitCreationViewController {
    
    func getHabitDescription() -> String {
        descriptionField.textView.text?.trimmed ?? ""
    }
    
    func updateHabitDescription() {
        let text = getHabitDescription()
        habit.description = text
    }
    
    func setupDescriptionSection(index: Int) {
        descriptionContainer.configure(
            title: "description".localized,
            content: descriptionField
        )
        descriptionContainer.contentContainer.layoutMargins = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
        descriptionContainer.setupAppearance()

        descriptionField.delegate = self
        descriptionField.textView.showsVerticalScrollIndicator = false
        descriptionField.showsVerticalScrollIndicator = false
        descriptionField.textView.textColor = AppTheme.current.colors.activeElementColor
        descriptionField.textView.font = AppTheme.current.fonts.medium(17)
        descriptionField.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        descriptionField.placeholderAttributedText
            = NSAttributedString(string: "...",
                                 attributes: [.font: AppTheme.current.fonts.medium(17),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        setupDescriptionObserver()
        
        stackViewController.setChild(descriptionContainer, at: index)
    }
    
    private func setupDescriptionObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(habitDescriptionDidChange),
                                               name: UITextField.textDidChangeNotification,
                                               object: descriptionField)
    }
    
    @objc private func habitDescriptionDidChange(notification: Notification) {
        updateHabitDescription()
    }
    
}
