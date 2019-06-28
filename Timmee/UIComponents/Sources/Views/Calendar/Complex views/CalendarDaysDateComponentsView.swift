//
//  CalendarDaysDateComponentsView.swift
//  UIComponents
//
//  Created by i.kharabet on 29/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarDaysDateComponentsView: UIView {
    
    var onTapToMonth: (() -> Void)?
    var onTapToYear: (() -> Void)?
    
    private lazy var monthView = CalendarDateComponentView(design: design)
    private lazy var yearView = CalendarDateComponentView(design: design)
    
    private let design: CalendarDesign
    
    init(design: CalendarDesign) {
        self.design = design
        super.init(frame: .zero)
        setupMonthView()
        setupYearView()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func configure(date: Date) {
        configure(month: date.asString(format: "LLLL"), year: date.asString(format: "YYYY"))
    }
    
    func configure(month: String, year: String) {
        monthView.configure(title: month)
        yearView.configure(title: year)
    }
    
    private func setupMonthView() {
        addSubview(monthView)
        
        monthView.addTarget(self, action: #selector(onTapToMonthView), for: .touchUpInside)
    }
    
    private func setupYearView() {
        addSubview(yearView)
        
        yearView.addTarget(self, action: #selector(onTapToYearView), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        monthView.height(32)
        [monthView.leading(10), monthView.centerY()].toSuperview()
        
        yearView.height(32)
        [yearView.trailing(10), yearView.centerY()].toSuperview()
    }
    
    @objc private func onTapToMonthView() {
        onTapToMonth?()
    }
    
    @objc private func onTapToYearView() {
        onTapToYear?()
    }
    
}
