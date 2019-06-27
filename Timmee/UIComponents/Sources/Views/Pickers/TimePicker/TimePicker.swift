//
//  TimePicker.swift
//  UIComponents
//
//  Created by i.kharabet on 26/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset

protocol TimePickerInput: class {
    func setHours(_ hours: Int)
    func setMinutes(_ minutes: Int)
}

protocol TimePickerOutput: class {
    func didChangeHours(to hours: Int)
    func didChangeMinutes(to minutes: Int)
}

final class TimePicker: UIViewController {
    
    private lazy var hourPicker: NumberPickerView = {
        let picker = NumberPickerView(design: design)
        picker.alignment = .right
        picker.shouldAddZero = false
        picker.numbers = (0...23).map { $0 }
        return picker
    }()
    
    private lazy var minutePicker: NumberPickerView = {
        let picker = NumberPickerView(design: design)
        picker.alignment = .left
        picker.numbers = (0...55).map { $0 }.filter { $0 % 5 == 0 }
        return picker
    }()
    
    private lazy var hourHintLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = design.hintsFont
        label.textColor = design.secondaryTintColor
        return label
    }()
    
    private lazy var minuteHintLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = design.hintsFont
        label.textColor = design.secondaryTintColor
        return label
    }()
    
    private lazy var timeSeparators: [UIView] = {
        return []
    }()
    
    weak var output: TimePickerOutput?
    
    private let design: TimePickerDesign
    
    init(design: TimePickerDesign) {
        self.design = design
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        hourPicker.onChangeNumber = { [unowned self] hours in
            self.output?.didChangeHours(to: hours)
        }
        
        minutePicker.onChangeNumber = { [unowned self] minutes in
            self.output?.didChangeMinutes(to: TimeRounder.roundMinutes(minutes))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hourHintLabel.text = "hours".localized
        minuteHintLabel.text = "minutes".localized
        
        hourHintLabel.textColor = design.secondaryTintColor
        minuteHintLabel.textColor = design.secondaryTintColor
        
        timeSeparators.forEach { view in
            view.backgroundColor = design.tintColor
        }
    }
    
    private func setupLayout() {
        let pickersContainer = UIView()
        
        view.addSubview(pickersContainer)
        view.addSubview(hourHintLabel)
        view.addSubview(minuteHintLabel)
        
        pickersContainer.addSubview(hourPicker)
        pickersContainer.addSubview(minutePicker)
        
        [pickersContainer.centerX(), pickersContainer.top(8), pickersContainer.bottom(8)].toSuperview()
        
        hourHintLabel.centerY().toSuperview()
        hourHintLabel.trailingToLeading(-10).to(pickersContainer, addTo: view)
        minuteHintLabel.centerY().toSuperview()
        minuteHintLabel.leadingToTrailing(10).to(pickersContainer, addTo: view)
        
        hourPicker.width(48)
        minutePicker.width(48)
        [hourPicker.top(), hourPicker.bottom(), hourPicker.leading()].toSuperview()
        [minutePicker.top(), minutePicker.bottom(), minutePicker.trailing()].toSuperview()
        hourPicker.trailingToLeading(-8).to(minutePicker, addTo: view)
    }
    
}

extension TimePicker: TimePickerInput {
    
    func setHours(_ hours: Int) {
        hourPicker.scrollToNumber(hours)
        output?.didChangeHours(to: hours)
    }
    
    func setMinutes(_ minutes: Int) {
        let roundedMinutes = TimeRounder.roundMinutes(minutes)
        minutePicker.scrollToNumber(roundedMinutes)
        output?.didChangeMinutes(to: roundedMinutes)
    }
    
}

// TODO: ?
extension TimePicker { //}: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return 112
    }
    
}
