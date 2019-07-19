//
//  FloatingButton.swift
//  Timmee
//
//  Created by Илья Харабет on 07/01/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class FloatingButton: UIButton {
    
    public enum FloatingState {
        case `default`, active
    }
    
    public struct Colors {
        let tintColor: UIColor
        let backgroundColor: UIColor
        let secondaryBackgroundColor: UIColor
        
        public init(tintColor: UIColor,
                    backgroundColor: UIColor,
                    secondaryBackgroundColor: UIColor) {
            self.tintColor = tintColor
            self.backgroundColor = backgroundColor
            self.secondaryBackgroundColor = secondaryBackgroundColor
        }
    }
    
    public var colors: Colors = Colors(tintColor: .black,
                                       backgroundColor: .black,
                                       secondaryBackgroundColor: .black) {
        didSet {
            setupAppearance()
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    public func setState(_ state: FloatingState) {
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
        tintColor = colors.tintColor
        setBackgroundImage(UIImage.plain(color: colors.backgroundColor), for: .normal)
        setBackgroundImage(UIImage.plain(color: colors.secondaryBackgroundColor), for: .selected)
        setBackgroundImage(UIImage.plain(color: colors.secondaryBackgroundColor), for: .highlighted)
    }
    
}
