//
//  WaterLevelView.swift
//  Agile diary
//
//  Created by i.kharabet on 26.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class WaterLevelView: UIView {
    
    var animationHasStoped: Bool = true
    
    var waterLevel: CGFloat = 0
    private var currentWaterLevel: CGFloat = 0
    
    private var currentWaveHeight: CGFloat = 0
    private let maxWaveHeight: CGFloat = 24
    private var currentWaveStep: CGFloat = waveStep
    
    private static let waveStep: CGFloat = 1
    private static let waterLevelStep: CGFloat = 0.005
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animateWave()
    }
    
    private func animateWave() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            guard let `self` = self else { return }
            guard !self.animationHasStoped else { return }
            if self.currentWaveHeight >= self.maxWaveHeight {
                self.currentWaveStep = -WaterLevelView.waveStep
            } else if self.currentWaveHeight <= -self.maxWaveHeight {
                self.currentWaveStep = WaterLevelView.waveStep
            }
            self.currentWaveHeight += self.currentWaveStep
            if self.currentWaterLevel > self.waterLevel {
                let waveLevelsDifference = abs(self.currentWaterLevel - self.waterLevel)
                if waveLevelsDifference < WaterLevelView.waterLevelStep {
                    self.currentWaterLevel -= waveLevelsDifference
                } else {
                    self.currentWaterLevel -= WaterLevelView.waterLevelStep
                }
            } else if self.currentWaterLevel < self.waterLevel {
                let waveLevelsDifference = abs(self.currentWaterLevel - self.waterLevel)
                if waveLevelsDifference < WaterLevelView.waterLevelStep {
                    self.currentWaterLevel += waveLevelsDifference
                } else {
                    self.currentWaterLevel += WaterLevelView.waterLevelStep
                }
            }
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard waterLevel > 0 else { return }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(AppTheme.current.colors.mainElementColor.withAlphaComponent(0.35).cgColor)
        
        let waterRect = CGRect(x: 0, y: bounds.height - currentWaterLevel * bounds.height, width: bounds.width, height: currentWaterLevel * bounds.height)
        
        let path = UIBezierPath(rect: waterRect)
        path.move(to: CGPoint(x: 0, y: waterRect.minY))
        path.addCurve(to: CGPoint(x: bounds.width, y: waterRect.minY),
                      controlPoint1: CGPoint(x: waterRect.width * 0.15, y: waterRect.minY + currentWaveHeight),
                      controlPoint2: CGPoint(x: waterRect.maxX - waterRect.width * 0.25, y: waterRect.minY - currentWaveHeight))
        path.fill()
    }
    
}
