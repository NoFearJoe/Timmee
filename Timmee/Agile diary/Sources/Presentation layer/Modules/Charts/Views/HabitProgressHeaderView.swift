//
//  HabitProgressHeaderView.swift
//  Agile diary
//
//  Created by Илья Харабет on 26.04.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

final class HabitProgressHeaderView: UIView {
    
    private let titleLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        frame.size.height = 18
        
        addSubview(titleLabel)
        titleLabel.text = "Progress_till_today".localized
        titleLabel.font = AppTheme.current.fonts.regular(15)
        titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        [titleLabel.leading(15), titleLabel.trailing(15), titleLabel.top(), titleLabel.bottom()].toSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
