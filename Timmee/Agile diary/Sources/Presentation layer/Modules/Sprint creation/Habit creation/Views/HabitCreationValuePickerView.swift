//
//  HabitCreationValuePickerView.swift
//  Agile diary
//
//  Created by Илья Харабет on 11/01/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class HabitCreationValuePickerView: UIView {
    
    var selectedAmount: Int {
        valuePicker.selectedRow(inComponent: 0) + 1
    }
    
    var selectedUnits: Habit.Value.Unit {
        Habit.Value.Unit.allCases.item(at: valuePicker.selectedRow(inComponent: 1)) ?? .times
    }
    
    var onChangeValue: (() -> Void)?
    
    private let valueLabel = UILabel()
    private let valuePicker = UIPickerView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HabitCreationValuePickerView {
    
    func update(habit: Habit) {
        valueLabel.text = habit.value?.localized
        
        if let value = habit.value {
            valuePicker.selectRow(value.amount - 1, inComponent: 0, animated: false)
            valuePicker.selectRow(Habit.Value.Unit.allCases.index(of: value.units) ?? 0, inComponent: 1, animated: false)
        }
    }
    
}

extension HabitCreationValuePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return 1000
        case 1: return Habit.Value.Unit.allCases.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch component {
        case 0: return NSAttributedString(string: "\(row + 1)", attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        case 1:
            guard let value = Habit.Value.Unit.allCases.item(at: row)?.localized else { return nil }
            return NSAttributedString(string: value, attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onChangeValue?()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 26
    }
    
}

private extension HabitCreationValuePickerView {
    
    func setupViews() {
        addSubview(valueLabel)
        addSubview(valuePicker)
        
        valueLabel.font = AppTheme.current.fonts.bold(20)
        valueLabel.textColor = AppTheme.current.colors.activeElementColor
        
        valuePicker.delegate = self
        valuePicker.dataSource = self
        valuePicker.setValue(AppTheme.current.colors.activeElementColor, forKey: "textColor")
    }
    
    func setupLayout() {
        [valueLabel.leading(8), valueLabel.top(8), valueLabel.trailing(8)].toSuperview()
        [valuePicker.leading(), valuePicker.bottom(), valuePicker.trailing()].toSuperview()
        
        valuePicker.topToBottom(8).to(valueLabel, addTo: self)
        valuePicker.height(128)
    }
    
}
