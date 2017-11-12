//
//  CalendarDayCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class CalendarDayCell: UICollectionViewCell {
    
    @IBOutlet weak var dayNameLabel: DayNameLabel!
    @IBOutlet weak var dayNumberLabel: DayNumberLabel!
    
    var isWeekend: Bool = false {
        didSet {
            dayNameLabel.setupAppearance(isWeekend: isWeekend)
            dayNumberLabel.setupAppearance(isWeekend: isWeekend)
        }
    }
    
}


final class DayNameLabel: UILabel {
    
    dynamic var color = UIColor.black
    
    var state: UIControlState = .normal {
        didSet {
            changeTextColor()
        }
    }
    
    func setupAppearance(isWeekend: Bool) {
        if isWeekend {
            color = AppTheme.current.redColor
        } else {
            color = AppTheme.current.tintColor
        }
    }
    
    func changeTextColor() {
        switch state {
        case UIControlState.disabled:
            textColor = color.withAlphaComponent(0.5)
        default:
            textColor = color
        }
    }
    
}

final class DayNumberLabel: UILabel {
    
    dynamic var color = UIColor.black
    dynamic var selectedTextColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = AppTheme.current.panelColor
        selectedTextColor = AppTheme.current.backgroundColor
    }
    
    
    var state: UIControlState = .normal {
        didSet {
            changeTextColor()
            setNeedsDisplay()
        }
    }
    
    func setupAppearance(isWeekend: Bool) {
        if isWeekend {
            color = AppTheme.current.redColor
        } else {
            color = AppTheme.current.tintColor
        }
    }
    
    func changeTextColor() {
        switch state {
        case UIControlState.selected:
            textColor = selectedTextColor
        case UIControlState.disabled:
            textColor = color.withAlphaComponent(0.5)
        default:
            textColor = color
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            let color = (state == .selected ? tintColor : backgroundColor) ?? UIColor.clear
            
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: rect)
        }
        
        super.draw(rect)
    }
    
}


final class CalendarMonthCell: UICollectionViewCell {

    @IBOutlet fileprivate weak var monthLabel: UILabel!
    
    var month: String? {
        get { return monthLabel.text }
        set { monthLabel.text = newValue }
    }

}
