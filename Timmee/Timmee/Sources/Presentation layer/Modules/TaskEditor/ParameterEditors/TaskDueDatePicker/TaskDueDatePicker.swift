//
//  TaskDueDatePicker.swift
//  Timmee
//
//  Created by i.kharabet on 22.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskDueDatePickerInput: class {
    var minimumAvailableDate: Date { get set }
    func setDueDate(_ date: Date)
    func setBackgroundColor(_ color: UIColor)
}

protocol TaskDueDatePickerOutput: class {
    func didChangeDueDate(to date: Date)
}

final class TaskDueDatePicker: UIViewController {
    
    weak var output: TaskDueDatePickerOutput?
    weak var container: TaskParameterEditorOutput?
    
    var canClear: Bool = false {
        didSet { updateClearButton() }
    }
    
    @IBOutlet private var calendarView: CalendarView!
    
    private let calendar = Calendar(start: Date(), shift: -1, daysCount: 357)
    
    var minimumAvailableDate: Date = Date() {
        didSet {
            calendar.changeStartDate(to: minimumAvailableDate)
            calendarView.calendar = (calendar, calendar.monthDataSource())
            calendarView.calendarView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.calendar = (calendar, calendar.monthDataSource())
        calendarView.didSelectItemAtIndex = { [unowned self] index in
            let date = self.calendar.date(by: index)
            self.setDueDate(date)
            self.output?.didChangeDueDate(to: date)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateClearButton()
    }
    
}

extension TaskDueDatePicker: TaskDueDatePickerInput {
    
    func setDueDate(_ date: Date) {
        calendarView.selectedDateIndex = calendar.index(of: date)
        calendarView.calendarView.reloadData()
    }
    
    func setBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
    }
    
}

extension TaskDueDatePicker: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return 82
    }
    
}

private extension TaskDueDatePicker {
    
    func updateClearButton() {
        container?.closeButton.isHidden = !canClear
    }
    
}
