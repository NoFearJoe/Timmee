//
//  CalendarViewController.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset

public final class CalendarViewController: UIViewController {
    
    public var onChangeHeight: ((CGFloat) -> Void)?
    
    public var calendarView: CalendarView {
        return view as! CalendarView
    }
    
    public override func loadView() {
        view = CalendarView(frame: .zero)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.onChangeHeight = { [unowned self] height in
            self.onChangeHeight?(height)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendarView.configure(selectedDate: Date() + 2.asDays, currentDate: Date(), minimumDate: Date() - 5.asDays)
        calendarView.reload()
    }
    
}
