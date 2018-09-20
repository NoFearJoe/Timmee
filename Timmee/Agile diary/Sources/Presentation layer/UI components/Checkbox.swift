//
//  Checkbox.swift
//  Agile diary
//
//  Created by i.kharabet on 21.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

class Checkbox: UIView {
    
    var didChangeCkeckedState: ((Bool) -> Void)?
    
    var isChecked: Bool = false {
        didSet {
            setNeedsDisplay()
            if !isUserInteractionEnabled {
                didChangeCkeckedState?(isChecked)
            }
        }
    }
    
    var checkedColor: UIColor { return AppTheme.current.colors.selectedElementColor }
    var uncheckedColor: UIColor { return AppTheme.current.colors.selectedElementColor }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTapGestureRecognizer()
    }
    
    fileprivate func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(recognizer)
    }
    
    @objc fileprivate func onTap() {
        isChecked = !isChecked
        didChangeCkeckedState?(isChecked)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if isChecked {
            context.setFillColor(checkedColor.cgColor)
            
            context.fillEllipse(in: rect.insetBy(dx: 1, dy: 1))
            
            context.setFillColor(UIColor.white.cgColor)
            
            let image = UIImage(named: "checkmark")!
            let imageInset = rect.width * 0.25
            image.draw(in: rect.insetBy(dx: imageInset, dy: imageInset),
                       blendMode: CGBlendMode.normal,
                       alpha: 1)
        } else {
            context.setStrokeColor(uncheckedColor.cgColor)
            
            context.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))
            
            context.setFillColor(uncheckedColor.cgColor)
            
//            let image = UIImage(named: "checkmark")!
//            let imageInset = rect.width * 0.25
//            image.draw(in: rect.insetBy(dx: imageInset, dy: imageInset),
//                       blendMode: CGBlendMode.normal,
//                       alpha: 1)
        }
    }
    
}

final class InversedCheckBox: Checkbox {
    
    override var checkedColor: UIColor { return AppTheme.current.colors.inactiveElementColor }
    override var uncheckedColor: UIColor { return AppTheme.current.colors.selectedElementColor }
    
}
