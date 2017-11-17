//
//  AddTimeTemplateView.swift
//  Timmee
//
//  Created by i.kharabet on 16.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class AddTimeTemplateView: UIView {
    
    @IBOutlet fileprivate var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "add_time_template".localized
            titleLabel.textColor = AppTheme.current.secondaryTintColor
        }
    }
    @IBOutlet fileprivate var iconView: UIImageView! {
        didSet {
            iconView.tintColor = AppTheme.current.specialColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(AppTheme.current.panelColor.cgColor)
        context.setLineWidth(1)
        context.setLineDash(phase: 2, lengths: [4, 4])
        
        context.move(to: CGPoint(x: 0, y: rect.height - 0.5))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height - 0.5))
        context.strokePath()
    }

}
