//
//  TaskDueDatePicker.swift
//  Timmee
//
//  Created by i.kharabet on 22.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import CVCalendar

protocol TaskDueDatePickerInput: class {
    var minimumAvailableDate: Date { get set }
    func setDueDate(_ date: Date)
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
    
    @IBOutlet private var menuView: CVCalendarMenuView!
    @IBOutlet private var calendarView: CVCalendarView!
    
    var minimumAvailableDate: Date = Date() {
        didSet {
//            calendar.changeStartDate(to: minimumAvailableDate)
//            calendarView.calendar = (calendar, calendar.monthDataSource())
//            calendarView.calendarView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        calendarView.calendar = (calendar, calendar.monthDataSource())
//        calendarView.didSelectItemAtIndex = { [unowned self] index in
//            let date = self.calendar.date(by: index)
//            self.setDueDate(date)
//            self.output?.didChangeDueDate(to: date)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateClearButton()
        calendarView.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
}

extension TaskDueDatePicker: TaskDueDatePickerInput {
    
    func setDueDate(_ date: Date) {
        calendarView.presentedDate = CVDate(date: date)
//        calendarView.selectedDateIndex = calendar.index(of: date)
//        calendarView.calendarView.reloadData()
    }
    
}

extension TaskDueDatePicker: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return 275 + 30
    }
    
}

extension TaskDueDatePicker: CVCalendarMenuViewDelegate {
    
    func firstWeekday() -> Weekday {
        return .monday
    }
    
    func dayOfWeekTextColor(by weekday: Weekday) -> UIColor {
        if weekday == .saturday || weekday == .sunday {
            return AppTheme.current.redColor
        } else {
            return AppTheme.current.secondaryTintColor
        }
    }
    
}

extension TaskDueDatePicker: CVCalendarViewDelegate {
    
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func shouldAutoSelectDayOnWeekChange() -> Bool {
        return false
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
}

extension TaskDueDatePicker: CVCalendarViewAppearanceDelegate {
    
    func dayLabelColor(by weekday: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        if weekday == .saturday || weekday == .sunday {
            return AppTheme.current.redColor
        } else {
            return AppTheme.current.tintColor
        }
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return AppTheme.current.blueColor
    }
    
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return AppTheme.current.backgroundTintColor
    }
    
//    func spaceBetweenWeekViews() -> CGFloat {
//        return 20
//    }
    
}

fileprivate extension TaskDueDatePicker {
    
    func updateClearButton() {
        container?.closeButton.isHidden = !canClear
    }
    
}
