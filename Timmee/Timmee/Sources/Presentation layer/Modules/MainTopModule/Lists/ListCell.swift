//
//  ListCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class ListCell: SwipeTableViewCell {
    
    enum SeparatorStyle {
        case topAndBottom
        case top
        case bottom
        case none
    }

    @IBOutlet fileprivate weak var listIconView: UIImageView!
    @IBOutlet fileprivate weak var listTitleLabel: UILabel!
    @IBOutlet fileprivate weak var selectedListIndicator: UIView!
    
    fileprivate var separatorStyle: SeparatorStyle = .none {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var separatorColor: UIColor = AppTheme.current.scheme.panelColor
    
    func setList(_ list: List) {
        listIconView.image = list.icon.image
        listTitleLabel.text = list.title
    }
    
    func setSeparatorStyle(_ style: SeparatorStyle) {
        separatorStyle = style
    }
    
    func setListSelected(_ selected: Bool) {
        selectedListIndicator.isHidden = !selected
    }
    
    func applyAppearance() {
        backgroundColor = AppTheme.current.scheme.backgroundColor
        listTitleLabel.textColor = AppTheme.current.scheme.cellTintColor
        listIconView.tintColor = AppTheme.current.scheme.tintColor
        selectedListIndicator.backgroundColor = AppTheme.current.scheme.blueColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(separatorColor.cgColor)
        
        func drawSeparator(y: CGFloat) {
            let rect = CGRect(x: separatorInset.left,
                              y: y,
                              width: rect.width - (separatorInset.left + separatorInset.right),
                              height: 1)
            let path = UIBezierPath(roundedRect: rect,
                                    cornerRadius: 1)
            context.addPath(path.cgPath)
            context.fillPath()
        }
        
//        switch separatorStyle {
//        case .none: break
//        case .top: drawSeparator(y: -0.5)
        drawSeparator(y: rect.height - 1)
//        case .topAndBottom:
//            drawSeparator(y: -0.5)
//            drawSeparator(y: rect.height - 0.5)
//        }
    }

}
