//
//  FloatingButton.swift
//  Timmee
//
//  Created by Илья Харабет on 07/01/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class FloatingButton: UIButton {
    
    enum FloatingState {
        case `default`, active
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    func setState(_ state: FloatingState) {
        switch state {
        case .default:
            isSelected = false
            transform = .identity
        case .active:
            isSelected = true
            transform = makeRotationTransform()
        }
    }
    
    private func makeRotationTransform() -> CGAffineTransform {
        return CGAffineTransform(rotationAngle: 45 * .pi / 180)
    }
    
    private func setupAppearance() {
        clipsToBounds = true
        adjustsImageWhenHighlighted = false
        tintColor = AppTheme.current.backgroundTintColor
        setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
        setBackgroundImage(UIImage.plain(color: AppTheme.current.secondaryTintColor), for: .selected)
        setBackgroundImage(UIImage.plain(color: AppTheme.current.secondaryTintColor), for: .highlighted)
    }
    
}
