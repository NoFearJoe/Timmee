//
//  BarView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 07.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

class BarView: UIView {

    @IBInspectable var barColor: UIColor = UIColor(rgba: "FEFEFE")
    @IBInspectable var separatorColor: UIColor = UIColor(rgba: "DDDDDD")
    @IBInspectable var cornerRadius: CGFloat = 8
    
    var shadowRadius: CGFloat = 4 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    var showShadow: Bool = false {
        didSet {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: -1)
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = 0.4
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard showShadow else { return }
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        byRoundingCorners: [.topRight, .topLeft],
                                        cornerRadii: CGSize(width: 8, height: 8)).cgPath
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let clip = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius,
                                                    height: cornerRadius))
        context.addPath(clip.cgPath)
        context.clip()
        
        context.setFillColor(barColor.cgColor)
        context.fill(rect)
        
        context.setFillColor(separatorColor.cgColor)
        context.fill(CGRect(x: 0,
                            y: rect.height - 0.5,
                            width: rect.width,
                            height: 0.5))
    }

}
