//
//  HabitCreationScreen+DueTime.swift
//  Agile diary
//
//  Created by Илья Харабет on 29.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

extension HabitCreationViewController {
    
    func updateDueTime() {
        dueTimeLabel.text = habit.dueTime?.string
    }
    
    func setupDueTimeSection(index: Int) {
        dueTimeContainer.setupAppearance()
        dueTimeContainer.configure(
            title: "due_time".localized,
            content: dueTimeLabel,
            actionView: dueTimeToggle
        )
        dueTimeContainer.contentContainer.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        dueTimeContainer.contentContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTime)))
        
        dueTimeLabel.font = AppTheme.current.fonts.bold(20)
        dueTimeLabel.textColor = AppTheme.current.colors.mainElementColor
        dueTimeLabel.height(28)
        dueTimeLabel.isUserInteractionEnabled = false
        
        dueTimeToggle.setImage(UIImage(named: "plus"), for: .normal)
        dueTimeToggle.width(32)
        dueTimeToggle.height(32)
        dueTimeToggle.backgroundColor = .clear
        dueTimeToggle.addTarget(self, action: #selector(didTapDueTimeToggle), for: .touchUpInside)
        dueTimeToggle.colors = FloatingButton.Colors(
            tintColor: .white,
            backgroundColor: AppTheme.current.colors.mainElementColor,
            secondaryBackgroundColor: AppTheme.current.colors.inactiveElementColor
        )
        
        stackViewController.setChild(dueTimeContainer, at: index)
    }
    
    func setDueTimeVisible(_ isVisible: Bool, animated: Bool) {
        dueTimeContainer.contentContainer.isHidden = !isVisible
        
        UIView.animate(withDuration: animated ? 0.15 : 0) {
            self.dueTimeToggle.setState(isVisible ? .active : .default)
        }
    }
    
    @objc private func didTapDueTimeToggle() {
        let isOn = !(dueTimeToggle.floatingState == .active)
        
        if isOn {
            showDueTimePicker(time: lastSelectedDueTime)
        } else {
            habit.dueTime = nil
            habit.notification = .none
            setDueTimeVisible(false, animated: true)
            setNotificationTimePickerVisible(false, animated: true)
        }
        
        updateDueTime()
    }
    
    @objc private func didTapTime() {
        showDueTimePicker(time: habit.dueTime ?? lastSelectedDueTime)
    }
    
    func showDueTimePicker(time: Time?) {
        let time = time ?? Time(Date.now.hours, Date.now.minutes)
        showTimePicker(time: time, handler: dueTimeEditorHandler)
    }
    
}
