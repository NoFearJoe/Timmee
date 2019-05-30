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
    
    private let monthView = CalendarDateComponentView(frame: .zero)
    private let yearView = CalendarDateComponentView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMonthView()
        setupYearView()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configure(date: Date) {
        configure(month: date.asString(format: "MMM"), year: date.asString(format: "YYYY"))
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
