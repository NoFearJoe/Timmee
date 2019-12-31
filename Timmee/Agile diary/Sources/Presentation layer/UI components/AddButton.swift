//
//  AddButton.swift
//  Agile diary
//
//  Created by Илья Харабет on 16/02/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

open class AddButton: UIButton {
    
    open override var isSelected: Bool {
        didSet {
            transform = isSelected ? makeSelectedStateTransform() : .identity
        }
    }
    
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
        adjustsImageWhenHighlighted = false
        backgroundColor = nil
        setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .highlighted)
        setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .selected)
    }
    
    private func makeSelectedStateTransform() -> CGAffineTransform {
        return CGAffineTransform(rotationAngle: 45 * .pi / 180)
    }
    
}
