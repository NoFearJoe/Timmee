//
//  CalendarWeekdaysView.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarWeekdaysView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        distribution = .fillEqually
        alignment = .center
        axis = .horizontal
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    func configure(weekdays: [String]) {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        weekdays.forEach { weekday in
            let view = CalendarWeekdayView(frame: .zero)
            addArrangedSubview(view)
            view.configure(title: weekday)
        }
    }
    
}
