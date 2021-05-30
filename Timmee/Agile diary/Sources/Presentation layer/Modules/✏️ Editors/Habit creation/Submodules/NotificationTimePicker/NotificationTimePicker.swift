//
//  NotificationTimePicker.swift
//  Agile diary
//
//  Created by i.kharabet on 20.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol NotificationTimePickerInput: AnyObject {
    func setHours(_ hours: Int)
    func setMinutes(_ minutes: Int)
}

protocol NotificationTimePickerOutput: AnyObject {
    func didChangeHours(to hours: Int)
    func didChangeMinutes(to minutes: Int)
}

final class NotificationTimePicker: UIViewController {
    
    public var time: Time {
        Time(hourPicker.currentNumber, minutePicker.currentNumber)
    }
    
    @IBOutlet fileprivate var hourPicker: NumberPicker!
    @IBOutlet fileprivate var minutePicker: NumberPicker!
    
    @IBOutlet fileprivate var timeSeparators: [UIView]!
    
    weak var output: NotificationTimePickerOutput?
    
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
        
        timeSeparators.forEach { view in
            view.backgroundColor = UIColor(rgba: "888888")
        }
    }
    
}

extension NotificationTimePicker: NotificationTimePickerInput {
    
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

extension NotificationTimePicker: EditorInput {
    
    var requiredHeight: CGFloat {
        96
    }
    
}
