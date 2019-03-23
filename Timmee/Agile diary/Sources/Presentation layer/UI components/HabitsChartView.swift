//
//  HabitsChartView.swift
//  Agile diary
//
//  Created by Илья Харабет on 12/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

struct HabitsChartEntry {
    let index: Int
    let doneHabitsCount: Int
    let totalHabitsCount: Int
    let title: String
    let color: UIColor
}

final class HabitsChartView: UIView {
    
    var barWidth: CGFloat = 24
    var barSpace: CGFloat = 8
    var horizontalPadding: CGFloat = 12
    var topPadding: CGFloat = 20
    var underlyingBarColor: UIColor = .lightGray
    
    var entries: [HabitsChartEntry] = [] {
        didSet {
            calculateContentSize()
            setNeedsDisplay()
        }
    }
    
    // Отступы для осей
    private let bottomPadding: CGFloat = 20
    private let leftPadding: CGFloat = 24
    
    private var contentSize: CGSize = .zero
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    private func calculateContentSize() {
        let width = CGFloat(entries.count) * barWidth + CGFloat(entries.count - 1) * barSpace + horizontalPadding * 2 + leftPadding
        contentSize = CGSize(width: max(width, superview?.bounds.width ?? 0), height: bounds.height)
        invalidateIntrinsicContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateContentSize()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let maxTotalHabitsCount = entries.max(by: { $0.totalHabitsCount < $1.totalHabitsCount })?.totalHabitsCount ?? 0
        let pointsForOneHabit = (bounds.height - topPadding - bottomPadding) / CGFloat(maxTotalHabitsCount)
        
        for i in 0...maxTotalHabitsCount {
            let y = (bounds.height - bottomPadding) - CGFloat(i) * pointsForOneHabit
            drawYLabel(text: "\(i)", y: y)
        }
        
        entries.forEach { entry in
            let x = leftPadding + horizontalPadding + (CGFloat(entry.index) * barWidth + CGFloat(entry.index) * barSpace)
            let height = pointsForOneHabit * CGFloat(entry.totalHabitsCount)
            let y = (bounds.height - bottomPadding) - height
            context.setFillColor(underlyingBarColor.cgColor)
            UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: height),
                         byRoundingCorners: [.topLeft, .topRight],
                         cornerRadii: CGSize(width: 6, height: 6))
                .fill()
            
            let height1 = pointsForOneHabit * CGFloat(entry.doneHabitsCount)
            let y1 = (bounds.height - bottomPadding) - height1
            context.setFillColor(entry.color.cgColor)
            UIBezierPath(roundedRect: CGRect(x: x, y: y1, width: barWidth, height: height1),
                         byRoundingCorners: [.topLeft, .topRight],
                         cornerRadii: CGSize(width: 6, height: 6))
                .fill()
            
            drawXLabel(text: entry.title, x: x, width: barWidth)
        }
        
        context.setStrokeColor(underlyingBarColor.cgColor)
        context.setLineWidth(1)
        
        context.move(to: CGPoint(x: leftPadding, y: bounds.height - bottomPadding))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - bottomPadding))
        context.strokePath()
        
        context.move(to: CGPoint(x: leftPadding, y: topPadding))
        context.addLine(to: CGPoint(x: leftPadding, y: bounds.height - bottomPadding))
        context.strokePath()
    }
    
    private func drawYLabel(text: String, y: CGFloat) {
        let font = AppTheme.current.fonts.regular(11)
        let rect = CGRect(x: 2, y: y - font.lineHeight / 2, width: leftPadding - 4, height: font.lineHeight)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        (text as NSString).draw(in: rect, withAttributes: [
            .foregroundColor: UIColor.gray,
            .font: font,
            .paragraphStyle: paragraphStyle
        ])
    }
    
    private func drawXLabel(text: String, x: CGFloat, width: CGFloat) {
        let font = AppTheme.current.fonts.regular(11)
        let rect = CGRect(x: x, y: bounds.height - bottomPadding + 4, width: width, height: font.lineHeight)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        (text as NSString).draw(in: rect, withAttributes: [
            .foregroundColor: UIColor.gray,
            .font: font,
            .paragraphStyle: paragraphStyle
        ])
    }
    
}
