//
//  ContinueEducationButton.swift
//  Agile diary
//
//  Created by i.kharabet on 17.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

@IBDesignable final class ContinueEducationButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    private func setupAppearance() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        setTitleColor(AppTheme.current.colors.activeElementColor, for: .normal)
    }
    
}
