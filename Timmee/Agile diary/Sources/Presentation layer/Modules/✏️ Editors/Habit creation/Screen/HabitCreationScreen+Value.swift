//
//  HabitCreationScreen+Value.swift
//  Agile diary
//
//  Created by Илья Харабет on 29.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

extension HabitCreationViewController {
    
    func updateValueLabel() {
        valuePicker.update(habit: habit)
    }
    
    func updateHabitValue() {
        let amount = valuePicker.selectedAmount
        let units = valuePicker.selectedUnits
        habit.value = Habit.Value(amount: amount, units: units)
        lastSelectedValue = habit.value
    }
    
    func setValuePickerVisible(_ isVisible: Bool, animated: Bool) {
        valueContainer.contentContainer.isHidden = !isVisible
    }
    
    func setupValueSection(index: Int) {
        valueContainer.setupAppearance()
        valueContainer.configure(
            title: "amount".localized,
            content: valuePicker,
            actionView: valueToggle
        )
        
        valuePicker.onChangeValue = { [unowned self] in
            self.updateHabitValue()
            self.updateValueLabel()
        }
        
        valueToggle.setImage(UIImage(named: "plus"), for: .normal)
        valueToggle.width(32)
        valueToggle.height(32)
        valueToggle.backgroundColor = .clear
        valueToggle.addTarget(self, action: #selector(didTapValueToggle), for: .touchUpInside)
        valueToggle.colors = FloatingButton.Colors(
            tintColor: .white,
            backgroundColor: AppTheme.current.colors.mainElementColor,
            secondaryBackgroundColor: AppTheme.current.colors.inactiveElementColor
        )
        
        stackViewController.setChild(valueContainer, at: index)
    }
    
    @objc private func didTapValueToggle() {
        let isOn = !(valueToggle.floatingState == .active)

        UIView.animate(withDuration: 0.15) {
            self.valueToggle.setState(isOn ? .active : .default)
        }
        
        self.habit.value = isOn ? self.lastSelectedValue ?? Habit.Value(amount: 1, units: .times) : nil
        if self.habit.value != nil {
            self.lastSelectedValue = self.habit.value
        }
        self.updateValueLabel()
        self.setValuePickerVisible(isOn, animated: true)
    }
    
}
