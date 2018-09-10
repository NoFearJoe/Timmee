//
//  ProgressBar.swift
//  UIComponents
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

@IBDesignable open class ProgressBar: UIView {
    
    @IBInspectable open dynamic var fillColor: UIColor = .black {
        didSet {
            progressLayer.fillColor = fillColor.cgColor
        }
    }
    
    private(set) open var progress: CGFloat = 0.5
    
    private let progressLayer = CAShapeLayer()
    
    open func setProgress(_ progress: CGFloat, animated: Bool = false) {
        self.progress = progress
        updateProgress(animated: animated)
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateProgressLayer()
    }
    
    private func updateProgress(animated: Bool) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        updateProgressLayer()
        CATransaction.commit()
    }
    
    private func updateProgressLayer() {
        progressLayer.frame = CGRect(x: 0, y: 0, width: progress * layer.frame.width, height: layer.frame.height)
//        progressLayer.cornerRadius = layer.frame.height * 0.5
    }
    
}
