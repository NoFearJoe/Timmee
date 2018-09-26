//
//  WaterLevelView.swift
//  Agile diary
//
//  Created by i.kharabet on 26.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class WaterLevelView: UIView {
    
    var waterLevel: CGFloat = 0.5 {
        didSet {
            // Redraw animated
        }
    }
    
    private var currentWavePositionX: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animateWave()
    }
    
    private func animateWave() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let `self` = self else { return }
            if self.currentWavePositionX >= self.bounds.width {
                self.currentWavePositionX = 0
            } else {
                self.currentWavePositionX += 1
            }
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard waterLevel > 0 else { return }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(AppTheme.current.colors.mainElementColor.withAlphaComponent(0.5).cgColor)
        
        let waterRect = CGRect(x: 0, y: bounds.height - waterLevel * bounds.height, width: bounds.width, height: waterLevel * bounds.height)
        
        let path = UIBezierPath(rect: waterRect)
        path.addCurve(to: CGPoint(x: currentWavePositionX, y: waterRect.minY),
                      controlPoint1: CGPoint(x: currentWavePositionX - 50, y: waterRect.minY + 50),
                      controlPoint2: CGPoint(x: currentWavePositionX + 50, y: waterRect.minY - 50))
        path.fill()
    }
    
}
