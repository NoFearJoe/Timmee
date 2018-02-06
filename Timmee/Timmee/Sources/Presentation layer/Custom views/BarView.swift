//
//  BarView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 07.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

class BarView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 8
    
    var shadowRadius: CGFloat = 4 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    var showShadow: Bool = false {
        didSet {
            layer.shadowColor = showShadow ? UIColor.black.cgColor : UIColor.clear.cgColor
            layer.shadowOffset = CGSize(width: 0, height: -1)
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = 0.4
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentMode = .redraw
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if showShadow {
            layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                            byRoundingCorners: [.topRight, .topLeft],
                                            cornerRadii: CGSize(width: 8, height: 8)).cgPath
        } else {
            layer.shadowPath = nil
        }
        
        applyRoundCornersMask()
    }
    
    private func applyRoundCornersMask() {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        
        self.layer.mask = maskLayer
    }

}
