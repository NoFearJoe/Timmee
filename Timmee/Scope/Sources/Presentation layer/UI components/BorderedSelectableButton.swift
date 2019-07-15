//
//  BorderedSelectableButton.swift
//  Timmee
//
//  Created by i.kharabet on 24.12.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

open class BorderedSelectableButton: UIButton {
    
    override open var isSelected: Bool {
        didSet {
            updateSelectedState(isSelected: isSelected)
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    func setupAppearance() {
        layer.borderWidth = 1
        layer.borderColor = AppTheme.current.middlegroundColor.cgColor
        setTitleColor(AppTheme.current.secondaryTintColor, for: .normal)
        setTitleColor(AppTheme.current.blueColor, for: .selected)
        updateSelectedState(isSelected: false)
    }
    
    private func updateSelectedState(isSelected: Bool) {
        backgroundColor = isSelected ? AppTheme.current.middlegroundColor : nil
    }
    
}
