//
//  MoodChartView.swift
//  Agile diary
//
//  Created by i.kharabet on 21/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

struct MoodChartEntry {
    let index: Int
    let mood: Mood
}

final class MoodChartView: UIView {
    
    /// Диаметр отметки о настроении
    var entryDiameter: CGFloat = 8
    /// Расстояние между двумя отметками
    var spaceBetweenEntries: CGFloat = 36
    // Отступы для осей
    private let bottomPadding: CGFloat = 20
    private let leftPadding: CGFloat = 24
    private let rightPadding: CGFloat = 24
    var topPadding: CGFloat = 20
    /// Цвет осей
    var axisColor: UIColor = AppTheme.current.colors.activeElementColor
    /// Цвет линий, соединяющих отметки
    var lineColor: UIColor = AppTheme.current.colors.inactiveElementColor
    
    var entries: [MoodChartEntry] = [] {
        didSet {
            calculateContentSize()
            setNeedsDisplay()
        }
    }
    
    private var contentSize: CGSize = .zero
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    private func calculateContentSize() {
        let width = leftPadding + CGFloat(entries.count) * spaceBetweenEntries + entryDiameter / 2 + rightPadding
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
        
        drawAxes(context: context)
        
        let entryRadius = entryDiameter / 2
        
        let chartRect: CGRect = rect.inset(by: UIEdgeInsets(top: topPadding + entryRadius,
                                                            left: leftPadding,
                                                            bottom: bottomPadding + entryRadius,
                                                            right: rightPadding))
        let yAxisBaseline: CGFloat = chartRect.height / 2
        let yAxisLineHeight: CGFloat = chartRect.height / 4
        
        drawYAxisIcons(chartRect: chartRect, lineHeight: yAxisLineHeight)
        
        // Draw lines
        context.setStrokeColor(lineColor.cgColor)
        let linePath = UIBezierPath()
        linePath.lineWidth = 1
        entries.forEach { entry in
            let value = CGFloat(entry.mood.kind.value) * -1
            if entry.index == 0 {
                linePath.move(to: CGPoint(x: chartRect.minX + entryRadius + CGFloat(entry.index) * spaceBetweenEntries,
                                          y: chartRect.minY + yAxisBaseline + value * yAxisLineHeight))
            } else {
                linePath.addLine(to: CGPoint(x: chartRect.minX + entryRadius + CGFloat(entry.index) * spaceBetweenEntries,
                                             y: chartRect.minY + yAxisBaseline + value * yAxisLineHeight))
            }
        }
        linePath.stroke()
        
        // Draw entries
        entries.forEach { entry in
            let value = CGFloat(entry.mood.kind.value) * -1
            context.setFillColor(entry.mood.kind.color.cgColor)
            let x = chartRect.minX + entryRadius + CGFloat(entry.index) * spaceBetweenEntries - entryRadius
            context.fillEllipse(in: CGRect(x: x,
                                           y: chartRect.minY + yAxisBaseline + value * yAxisLineHeight - entryRadius,
                                           width: entryDiameter,
                                           height: entryDiameter))
            
            drawXLabel(text: entry.mood.date.asShortDayMonth, x: x, width: spaceBetweenEntries)
        }
    }
    
    private func drawAxes(context: CGContext) {
        context.setStrokeColor(axisColor.cgColor)
        context.setLineWidth(1)
        
        // Horizontal
        context.move(to: CGPoint(x: leftPadding, y: bounds.height - bottomPadding))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - bottomPadding))
        context.strokePath()
        
        // Vertical
        context.move(to: CGPoint(x: leftPadding, y: topPadding))
        context.addLine(to: CGPoint(x: leftPadding, y: bounds.height - bottomPadding))
        context.strokePath()
    }
    
    private func drawYAxisIcons(chartRect: CGRect, lineHeight: CGFloat) {
        func drawAxisMoodIcon(icon: UIImage, y: CGFloat, size: CGFloat) {
            let rect = CGRect(x: 2, y: y - size / 2, width: size, height: size)
            icon.draw(in: rect)
        }
        Mood.Kind.allCases.reversed().enumerated().forEach { index, mood in
            guard let icon = UIImage(named: mood.icon) else { return }
            let size = leftPadding - 4
            let y = chartRect.minY + CGFloat(index) * lineHeight
            drawAxisMoodIcon(icon: icon, y: y, size: size)
        }
    }
    
    private func drawXLabel(text: String, x: CGFloat, width: CGFloat) {
        let font = AppTheme.current.fonts.regular(11)
        let rect = CGRect(x: x, y: bounds.height - bottomPadding + 4, width: width, height: font.lineHeight)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        (text as NSString).draw(in: rect, withAttributes: [
            .foregroundColor: UIColor.gray,
            .font: font,
            .paragraphStyle: paragraphStyle
        ])
    }
    
}
