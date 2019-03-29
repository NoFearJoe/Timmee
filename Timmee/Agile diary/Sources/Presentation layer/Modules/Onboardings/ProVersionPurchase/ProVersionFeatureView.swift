//
//  ProVersionFeatureView.swift
//  Agile diary
//
//  Created by Илья Харабет on 29/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class ProVersionFeatureView: UIView {
    
    @IBOutlet private var iconView: UIImageView! {
        didSet {
            iconView.tintColor = AppTheme.current.colors.mainElementColor
        }
    }
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.font = AppTheme.current.fonts.medium(18)
            titleLabel.textColor = AppTheme.current.colors.activeElementColor
        }
    }
    
    func configure(icon: UIImage, title: String) {
        iconView.image = icon
        titleLabel.text = title
    }
    
}
