//
//  CardView.swift
//  Agile diary
//
//  Created by Илья Харабет on 21/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupAppearance()
    }
    
    func setupAppearance() {
        backgroundColor = AppTheme.current.colors.foregroundColor
        configureShadow(radius: 4, opacity: 0.1)
        clipsToBounds = false
        layer.cornerRadius = 12
    }
    
}
