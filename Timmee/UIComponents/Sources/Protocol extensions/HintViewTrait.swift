//
//  HintViewTrait.swift
//  UIComponents
//
//  Created by i.kharabet on 04.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public protocol HintViewTrait: class {
    var hintPopover: HintPopoverView? { get set }
    
    func showHintPopover(_ hint: String, button: UIButton)
    func showFullWidthHintPopover(_ hint: String, button: UIButton)
    func hideHintPopover()
    func updateHintPopover()
}

extension HintViewTrait where Self: UIViewController {
    public func showHintPopover(_ hint: String, button: UIButton) {
        self.hintPopover = HintPopoverView.showPopover(with: hint,
                                                       from: button,
                                                       holderView: self.view,
                                                       rightInset: self.view.bounds.width - button.center.x)
    }
    
    public func showFullWidthHintPopover(_ hint: String, button: UIButton) {
        self.hintPopover = HintPopoverView.showPopover(with: hint,
                                                       from: button,
                                                       holderView: self.view)
    }
    
    public func hideHintPopover() {
        self.hintPopover?.hide()
        self.hintPopover = nil
    }
    
    public func updateHintPopover() {
        self.hintPopover?.updateTrianglePosition()
    }
}
