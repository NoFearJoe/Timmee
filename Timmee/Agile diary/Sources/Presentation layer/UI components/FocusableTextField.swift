//
//  FocusableTextField.swift
//  Agile diary
//
//  Created by i.kharabet on 15.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

open class FocusableTextField: UITextField {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        layer.masksToBounds = false
        configureShadow(radius: 4, opacity: 0.1)
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification,
                                               object: self,
                                               queue: .main) { [unowned self] _ in self.setFocused(true) }
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification,
                                               object: self,
                                               queue: .main) { [unowned self] _ in self.setFocused(false) }
    }
    
    func setFocused(_ isFocused: Bool) {
        layer.borderWidth = isFocused ? 2 : 0
        layer.borderColor = AppTheme.current.colors.mainElementColor.cgColor
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 0)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 0)
    }
    
}
