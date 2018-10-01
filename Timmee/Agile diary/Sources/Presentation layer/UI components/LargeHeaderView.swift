//
//  LargeHeaderView.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

class LargeHeaderView: UIView {
    
    @IBOutlet private(set) var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = AppTheme.current.colors.activeElementColor
            titleLabel.font = AppTheme.current.fonts.bold(34)
        }
    }
    @IBOutlet private(set) var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.textColor = AppTheme.current.colors.activeElementColor
            subtitleLabel.font = AppTheme.current.fonts.regular(14)
        }
    }
    @IBOutlet private(set) var leftButton: UIButton? {
        didSet {
            leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        }
    }
    @IBOutlet private(set) var rightButton: UIButton? {
        didSet {
            rightButton?.tintColor = AppTheme.current.colors.activeElementColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    private func setupAppearance() {
        backgroundColor = AppTheme.current.colors.foregroundColor
    }
    
}
