//
//  CalendarMonthsDateComponentsView.swift
//  UIComponents
//
//  Created by i.kharabet on 29/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarMonthsDateComponentsView: UIView {
    
    var onTapToBack: (() -> Void)?
    var onTapToYear: (() -> Void)?
    
    private let backButton = UIButton(type: .custom)
    private let yearView = CalendarDateComponentView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackButton()
        setupYearView()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configure(date: Date) {
        configure(year: date.asString(format: "YYYY"))
    }
    
    func configure(year: String) {
        yearView.configure(title: year)
    }
    
    private func setupBackButton() {
        addSubview(backButton)
        
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.backgroundColor = .clear
        
        backButton.addTarget(self, action: #selector(onTapToBackButton), for: .touchUpInside)
    }
    
    private func setupYearView() {
        addSubview(yearView)
        
        yearView.addTarget(self, action: #selector(onTapToYearView), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        backButton.height(32)
        [backButton.leading(10), backButton.centerY()].toSuperview()
        
        yearView.height(32)
        [yearView.trailing(10), yearView.centerY()].toSuperview()
    }
    
    @objc private func onTapToBackButton() {
        onTapToBack?()
    }
    
    @objc private func onTapToYearView() {
        onTapToYear?()
    }
    
}
