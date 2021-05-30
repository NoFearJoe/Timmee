//
//  HabitCreationScreen+Notification.swift
//  Agile diary
//
//  Created by Илья Харабет on 29.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

extension HabitCreationViewController {
    
    func setNotificationTimePickerVisible(_ isVisible: Bool, animated: Bool) {
        notificationContainer.contentContainer.isHidden = !isVisible
        
        UIView.animate(withDuration: animated ? 0.15 : 0) {
            self.notificationTimeAddButton.setState(isVisible ? .active : .default)
        }
    }
    
    func updateNotificationTime() {
        setNotificationTimePickerVisible(habit.notification != .none, animated: false)
        notificationLabel.text = habit.notification.readableString
    }
    
    func setupNotificationSection(index: Int) {
        notificationLabel.font = AppTheme.current.fonts.regular(18)
        notificationLabel.textColor = AppTheme.current.colors.activeElementColor
        notificationLabel.height(28)
        
        notificationContainer.setupAppearance()
        notificationContainer.contentContainer.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        notificationContainer.configure(
            title: "reminder".localized,
            content: notificationLabel,
            actionView: notificationTimeAddButton
        )
        
        notificationContainer.contentContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNotification)))
        
        notificationTimeAddButton.setImage(UIImage(named: "plus"), for: .normal)
        notificationTimeAddButton.width(32)
        notificationTimeAddButton.height(32)
        notificationTimeAddButton.addTarget(self, action: #selector(onTapNotificationTimeButton), for: .touchUpInside)
        notificationTimeAddButton.colors = FloatingButton.Colors(
            tintColor: .white,
            backgroundColor: AppTheme.current.colors.mainElementColor,
            secondaryBackgroundColor: AppTheme.current.colors.inactiveElementColor
        )
        
        stackViewController.setChild(notificationContainer, at: index)
    }
    
    @objc private func onTapNotificationTimeButton() {
        let isOn = !(notificationTimeAddButton.floatingState == .active)
        
        if isOn {
            showNotificationPicker(notification: habit.notification, handler: notificationsEditorHandler)
        } else {
            habit.notification = .none
            setNotificationTimePickerVisible(false, animated: true)
        }
        
        updateNotificationTime()
    }
    
    @objc private func didTapNotification() {
        showNotificationPicker(notification: habit.notification, handler: notificationsEditorHandler)
    }
    
}
