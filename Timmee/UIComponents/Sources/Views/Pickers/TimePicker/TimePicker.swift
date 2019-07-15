//
//  TimePicker.swift
//  UIComponents
//
//  Created by i.kharabet on 26/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset

public protocol TimePickerInput: class {
    func setHours(_ hours: Int)
    func setMinutes(_ minutes: Int)
}

public protocol TimePickerOutput: class {
    func didChangeHours(to hours: Int)
    func didChangeMinutes(to minutes: Int)
}

public final class TimePicker: UIViewController {
    
    private lazy var hourPicker: NumberPickerView = {
        let picker = NumberPickerView(design: design)
        picker.frame = CGRect(x: 0, y: 0, width: 48, height: 112)
        picker.alignment = .right
        picker.shouldAddZero = false
        picker.numbers = (0...23).map { $0 }
        return picker
    }()
    
    private lazy var minutePicker: NumberPickerView = {
        let picker = NumberPickerView(design: design)
        picker.frame = CGRect(x: 0, y: 0, width: 48, height: 112)
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
        let topSeparator = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: 2))
        topSeparator.backgroundColor = design.secondaryTintColor
        topSeparator.layer.cornerRadius = 2
        topSeparator.clipsToBounds = true
        
        let bottomSeparator = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: 2))
        bottomSeparator.backgroundColor = design.secondaryTintColor
        bottomSeparator.layer.cornerRadius = 2
        bottomSeparator.clipsToBounds = true
        
        return [topSeparator, bottomSeparator]
    }()
    
    public weak var output: TimePickerOutput?
    
    private let design: TimePickerDesign
    
    public init(design: TimePickerDesign) {
        self.design = design
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        hourPicker.onChangeNumber = { [unowned self] hours in
            self.output?.didChangeHours(to: hours)
        }
        
        minutePicker.onChangeNumber = { [unowned self] minutes in
            self.output?.didChangeMinutes(to: TimeRounder.roundMinutes(minutes))
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hourHintLabel.text = "hours".localized
        minuteHintLabel.text = "minutes".localized
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
        
        let topSeparator = timeSeparators[0]
        pickersContainer.addSubview(topSeparator)
        topSeparator.width(4)
        topSeparator.height(4)
        topSeparator.centerX().toSuperview()
        topSeparator.centerYAnchor.constraint(equalTo: pickersContainer.centerYAnchor, constant: -4).isActive = true
        
        let bottomSeparator = timeSeparators[1]
        pickersContainer.addSubview(bottomSeparator)
        bottomSeparator.width(4)
        bottomSeparator.height(4)
        bottomSeparator.centerX().toSuperview()
        bottomSeparator.centerYAnchor.constraint(equalTo: pickersContainer.centerYAnchor, constant: 4).isActive = true
    }
    
}

extension TimePicker: TimePickerInput {
    
    public func setHours(_ hours: Int) {
        hourPicker.scrollToNumber(hours)
        output?.didChangeHours(to: hours)
    }
    
    public func setMinutes(_ minutes: Int) {
        let roundedMinutes = TimeRounder.roundMinutes(minutes)
        minutePicker.scrollToNumber(roundedMinutes)
        output?.didChangeMinutes(to: roundedMinutes)
    }
    
}

public extension TimePicker {
    
    var requiredHeight: CGFloat {
        return 112
    }
    
}
