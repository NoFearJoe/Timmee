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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
        setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
        setupTitleLabel()
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    private func commonSetup() {
        backgroundColor = CalendarDesign.shared.selectedBackgroundColor
        clipsToBounds = true
        layer.cornerRadius = 4
    }
    
    private func setupTitleLabel() {
        titleLabel.textColor = CalendarDesign.shared.selectedTintColor
        titleLabel.font = CalendarDateComponentView.titleFont
        
        addSubview(titleLabel)
        
        [titleLabel.top(), titleLabel.bottom()].toSuperview()
        [titleLabel.leading(8), titleLabel.trailing(8)].toSuperview()
    }
    
}
