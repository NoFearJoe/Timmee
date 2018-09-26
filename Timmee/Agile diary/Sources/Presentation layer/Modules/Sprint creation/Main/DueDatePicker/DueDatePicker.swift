//
//  TaskDueDatePicker.swift
//  Timmee
//
//  Created by i.kharabet on 22.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol DueDatePickerInput: class {
    var minimumAvailableDate: Date { get set }
    func setDueDate(_ date: Date)
    func setBackgroundColor(_ color: UIColor)
}

protocol DueDatePickerOutput: class {
    func didChangeDueDate(to date: Date)
}

final class DueDatePicker: UIViewController {
    
    weak var output: DueDatePickerOutput?
    
    @IBOutlet private var calendarView: CalendarView!
    
    private let calendar = Calendar(start: Date.now, shift: -1, daysCount: 357)
    
    var minimumAvailableDate: Date = Date.now {
        didSet {
            calendar.changeStartDate(to: minimumAvailableDate)
            calendarView.calendar = (calendar, calendar.monthDataSource())
            calendarView.calendarView.reloadData()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "sprint_start_date".localized
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "sprint_start_date".localized
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
    
}

extension DueDatePicker: DueDatePickerInput {
    
    func setDueDate(_ date: Date) {
        calendarView.selectedDateIndex = calendar.index(of: date)
        calendarView.calendarView.reloadData()
    }
    
    func setBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
    }
    
}

extension DueDatePicker: EditorInput {
    
    var requiredHeight: CGFloat {
        return 82
    }
    
}
