//
//  CalendarWeekdayView.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarWeekdayView: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func configure(title: String) {
        text = title
    }
    
    private func commonSetup() {
        textColor = CalendarDesign.shared.weekdaysColor
        font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textAlignment = .center
    }
    
}
