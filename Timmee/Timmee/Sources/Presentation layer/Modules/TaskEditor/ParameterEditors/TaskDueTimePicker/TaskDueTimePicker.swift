//
//  TaskDueTimePicker.swift
//  Timmee
//
//  Created by i.kharabet on 20.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskDueTimePickerInput: class {
    func setHours(_ hours: Int)
    func setMinutes(_ minutes: Int)
}

protocol TaskDueTimePickerOutput: class {
    func didChangeHours(to hours: Int)
    func didChangeMinutes(to minutes: Int)
}

final class TaskDueTimePicker: UIViewController {
    
    @IBOutlet fileprivate var hourPicker: NumberPicker!
    @IBOutlet fileprivate var minutePicker: NumberPicker!
    @IBOutlet fileprivate var hourHintLabel: UILabel!
    @IBOutlet fileprivate var minuteHintLabel: UILabel!
    
    @IBOutlet fileprivate var timeSeparators: [UIView]!
    
    weak var output: TaskDueTimePickerOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourPicker.shouldAddZero = false
        hourPicker.numbers = (0...23).map { $0 }
        hourPicker.didChangeNumber = { [unowned self] hours in
            self.output?.didChangeHours(to: hours)
        }
        
        minutePicker.numbers = (0...55).map { $0 }.filter { $0 % 5 == 0 }
        minutePicker.didChangeNumber = { [unowned self] minutes in
            self.output?.didChangeMinutes(to: TimeRounder.roundMinutes(minutes))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hourHintLabel.text = "hours".localized
        minuteHintLabel.text = "minutes".localized
        
        hourHintLabel.textColor = AppTheme.current.secondaryTintColor
        minuteHintLabel.textColor = AppTheme.current.secondaryTintColor
        
        timeSeparators.forEach { view in
            view.backgroundColor = AppTheme.current.tintColor
        }
    }
    
}

extension TaskDueTimePicker: TaskDueTimePickerInput {
    
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

extension TaskDueTimePicker: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return 112
    }
    
}
