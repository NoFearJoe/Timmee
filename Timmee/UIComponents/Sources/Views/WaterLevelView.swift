//
//  WaterLevelView.swift
//  Agile diary
//
//  Created by i.kharabet on 26.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public final class WaterLevelView: UIView {
    
    public var waterColor: UIColor = .blue
    
    public var animationHasStoped: Bool = true
    
    public var waterLevel: CGFloat = 0
    private var currentWaterLevel: CGFloat = 0
    
    private var currentWaveHeight: CGFloat = 0
    private let maxWaveHeight: CGFloat = 24
    private var currentWaveStep: CGFloat = waveStep
    
    private static let waveStep: CGFloat = 1
    private static let waterLevelStep: CGFloat = 0.01
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOSApplicationExtension 10.0, *) {
            animateWave()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    @available(iOSApplicationExtension 10.0, *)
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
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard waterLevel > 0 else { return }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(waterColor.cgColor)
        
        let waterRect = CGRect(x: 0, y: bounds.height - currentWaterLevel * bounds.height, width: bounds.width, height: currentWaterLevel * bounds.height)
        
        let path = UIBezierPath(rect: waterRect)
        path.move(to: CGPoint(x: 0, y: waterRect.minY))
        path.addCurve(to: CGPoint(x: bounds.width, y: waterRect.minY),
                      controlPoint1: CGPoint(x: waterRect.width * 0.15, y: waterRect.minY + currentWaveHeight),
                      controlPoint2: CGPoint(x: waterRect.maxX - waterRect.width * 0.25, y: waterRect.minY - currentWaveHeight))
        path.fill()
    }
    
}
