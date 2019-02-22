//
//  AddMenuButton.swift
//  Agile diary
//
//  Created by Илья Харабет on 16/02/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

open class AddMenuButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    open func setupAppearance() {
        tintColor = .white
        setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .highlighted)
        setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .selected)
    }
    
}
