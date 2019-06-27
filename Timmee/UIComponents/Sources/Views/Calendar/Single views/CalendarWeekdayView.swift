//
//  CalendarWeekdayView.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarWeekdayView: UILabel {
    
    private let design: CalendarDesign
    
    init(design: CalendarDesign) {
        self.design = design
        super.init(frame: .zero)
        commonSetup()
    }
        
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func configure(title: String) {
        text = title
    }
    
    private func commonSetup() {
        textColor = design.weekdaysColor
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textAlignment = .center
    }
    
}
