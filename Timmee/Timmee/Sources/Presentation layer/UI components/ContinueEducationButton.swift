//
//  ContinueEducationButton.swift
//  Timmee
//
//  Created by Илья Харабет on 14.01.2018.
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
        layer.cornerRadius = AppTheme.current.cornerRadius
        clipsToBounds = true
        
        setTitleColor(AppTheme.current.backgroundTintColor, for: .normal)
    }
    
}
