//
//  CalendarPage.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarPage: UIViewController {
    
    var onSelectDate: ((Date?) -> Void)?
    var badgeValue: ((Date) -> String?)?
    
    var maximumHeight: CGFloat {
        return calendarView.maximumHeight
    }
    
    private var calendarView: CalendarDaysView {
        return view as! CalendarDaysView
    }
    
    let state: CalendarState
    private let design: CalendarDesign
    
    init(state: CalendarState, design: CalendarDesign) {
        self.state = state
        self.design = design
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func loadView() {
        view = CalendarDaysView(state: state, design: design)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.onSelectDate = { [unowned self] date in
            self.onSelectDate?(date)
        }
        calendarView.badgeValue = { [unowned self] date in
            return self.badgeValue?(date)
        }
    }
    
    func reload() {
        calendarView.reload()
    }
    
}
