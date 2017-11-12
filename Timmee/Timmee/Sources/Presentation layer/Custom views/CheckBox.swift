//
//  CheckBox.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

class CheckBox: UIView {

    var didChangeCkeckedState: ((Bool) -> Void)?
    
    var isChecked: Bool = false {
        didSet {
            setNeedsDisplay()
            if !isUserInteractionEnabled {
                didChangeCkeckedState?(isChecked)
            }
        }
    }
    
    var checkedColor: UIColor { return AppTheme.current.blueColor }
    var uncheckedColor: UIColor { return AppTheme.current.secondaryTintColor}
    
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
            
            context.setFillColor(AppTheme.current.backgroundTintColor.cgColor)
            
            let image = UIImage(named: "checkmark")!
            let imageInset = rect.width * 0.25
            image.draw(in: rect.insetBy(dx: imageInset, dy: imageInset),
                       blendMode: CGBlendMode.normal,
                       alpha: 1)
        } else {
            context.setStrokeColor(uncheckedColor.cgColor)
            
            context.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))
        }
    }

}

final class InversedCheckBox: CheckBox {

    override var checkedColor: UIColor { return AppTheme.current.secondaryTintColor }
    override var uncheckedColor: UIColor { return AppTheme.current.blueColor }

}
