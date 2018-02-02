//
//  BaseRoundedCollectionViewCell.swift
//  Timmee
//
//  Created by i.kharabet on 30.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

class BaseRoundedCollectionViewCell: UICollectionViewCell {
    
    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var fillColor: UIColor = AppTheme.current.foregroundColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(fillColor.cgColor)
        
        let clipPath = UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: roundedCorners,
                                    cornerRadii: CGSize(width: 8, height: 8))
        
        context.addPath(clipPath.cgPath)
        context.fillPath()
        
        context.setLineWidth(1)
        context.setStrokeColor(AppTheme.current.panelColor.cgColor)
        
        if (roundedCorners.contains(.topLeft) && !roundedCorners.contains(.bottomLeft)) || (roundedCorners.contains(.topRight) && !roundedCorners.contains(.bottomRight)) {
            // draw bottom line
            context.move(to: CGPoint(x: 0, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            context.strokePath()
        } else if (roundedCorners.contains(.bottomLeft) && !roundedCorners.contains(.topLeft)) || (roundedCorners.contains(.bottomRight) && !roundedCorners.contains(.topRight)) {
            // draw top line
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x: rect.maxX, y: 0))
            context.strokePath()
        } else {
            context.move(to: CGPoint(x: 0, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            context.strokePath()
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x: rect.maxX, y: 0))
            context.strokePath()
        }
        
        if (roundedCorners.contains(.topLeft) && !roundedCorners.contains(.topRight)) || (roundedCorners.contains(.bottomLeft) && !roundedCorners.contains(.bottomRight)) {
            // draw right line
            context.move(to: CGPoint(x: rect.maxX, y: 0))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        } else if (roundedCorners.contains(.topRight) && !roundedCorners.contains(.topLeft)) || (roundedCorners.contains(.bottomRight) && !roundedCorners.contains(.bottomLeft)) {
            // draw left line
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x: 0, y: rect.maxY))
        }
        context.strokePath()
    }
    
}
