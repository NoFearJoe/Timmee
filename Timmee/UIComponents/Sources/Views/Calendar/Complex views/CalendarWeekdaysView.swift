//
//  CalendarWeekdaysView.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarWeekdaysView: UIStackView {
    
    private let design: CalendarDesign
    
    init(design: CalendarDesign) {
        self.design = design
        super.init(frame: .zero)
        distribution = .fillEqually
        alignment = .center
        axis = .horizontal
    }
    
    required init(coder: NSCoder) { fatalError() }
    
    func configure(weekdays: [String]) {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        weekdays.forEach { weekday in
            let view = CalendarWeekdayView(design: design)
            addArrangedSubview(view)
            view.configure(title: weekday)
        }
    }
    
}
