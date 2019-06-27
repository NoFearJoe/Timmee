//
//  CalendarDateComponentView.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class CalendarDateComponentView: UIControl {
    
    private let titleLabel: UILabel = UILabel(frame: .zero)
    private static let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
    
    private let design: CalendarDesign
    
    init(design: CalendarDesign) {
        self.design = design
        super.init(frame: .zero)
        commonSetup()
        setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    private func commonSetup() {
        backgroundColor = .clear
        clipsToBounds = true
        layer.cornerRadius = 4
    }
    
    private func setupTitleLabel() {
        titleLabel.textColor = design.defaultTintColor
        titleLabel.font = CalendarDateComponentView.titleFont
        
        addSubview(titleLabel)
        
        [titleLabel.top(), titleLabel.bottom()].toSuperview()
        [titleLabel.leading(8), titleLabel.trailing(8)].toSuperview()
    }
    
}
