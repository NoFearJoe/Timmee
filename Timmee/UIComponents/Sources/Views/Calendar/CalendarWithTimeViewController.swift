//
//  CalendarWithTimeViewController.swift
//  UIComponents
//
//  Created by i.kharabet on 26/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset

public final class CalendarWithTimeViewController: UIViewController {
    
    public var onSelectDate: ((Date?) -> Void)?
    public var badgeValue: ((Date) -> String?)?
    
    public var maximumHeight: CGFloat {
        return calendar.maximumHeight + timePicker.requiredHeight
    }
    
    private lazy var calendar = CalendarViewController(design: calendarDesign)
    private lazy var timePicker = TimePicker(design: timePickerDesign)
    
    private var selectedDate: Date?
    private var hours: Int = 0
    private var minutes: Int = 0
//    private var minimumDate: Date = Date()
    
    private let calendarDesign: CalendarDesign
    private let timePickerDesign: TimePickerDesign
    
    public init(calendarDesign: CalendarDesign, timePickerDesign: TimePickerDesign) {
        self.calendarDesign = calendarDesign
        self.timePickerDesign = timePickerDesign
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        calendar.onSelectDate = { [unowned self] date in
            self.updateSelectedDate(with: date)
            self.onSelectDate?(self.selectedDate)
        }
        calendar.badgeValue = { [unowned self] date in
            return self.badgeValue?(date)
        }
        
        timePicker.output = self
    }
    
    private var isConfigured: Bool = false
    
    public func configure(selectedDate: Date?, minimumDate: Date?) {
        isConfigured = true
        
        self.selectedDate = selectedDate
//        self.minimumDate = minimumDate ?? Date(timeIntervalSince1970: 0)
        
        timePicker.setHours(selectedDate?.hours ?? Date().hours)
        timePicker.setMinutes(selectedDate?.minutes ?? Date().minutes)
        
        updateSelectedDate(with: selectedDate)
        
        calendar.configure(selectedDate: selectedDate, minimumDate: minimumDate)
    }
    
    private func setupLayout() {
        view.addSubview(calendar.view)
        view.addSubview(timePicker.view)
        
        [calendar.view.top(), calendar.view.leading(), calendar.view.trailing()].toSuperview()
        [timePicker.view.leading(), timePicker.view.trailing(), timePicker.view.bottom()].toSuperview()
        
        calendar.view.bottomToTop().to(timePicker.view, addTo: view)
        timePicker.view.height(timePicker.requiredHeight)
    }
    
}

extension CalendarWithTimeViewController: TimePickerOutput {
    
    public func didChangeHours(to hours: Int) {
        self.hours = hours
        selectedDate => hours.asHours
        self.onSelectDate?(selectedDate)
    }
    
    public func didChangeMinutes(to minutes: Int) {
        self.minutes = minutes
        selectedDate => minutes.asMinutes
        self.onSelectDate?(selectedDate)
    }
    
}

private extension CalendarWithTimeViewController {
    
    func updateSelectedDate(with date: Date?) {
        selectedDate = date
        selectedDate => hours.asHours
        selectedDate => minutes.asMinutes
    }
    
}
