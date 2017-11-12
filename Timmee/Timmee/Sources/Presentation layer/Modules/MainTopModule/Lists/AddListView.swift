//
//  AddListView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class AddListView: BarView {
    
    var onTap: (() -> Void)?
    
    @IBOutlet fileprivate var iconView: UIImageView! {
        didSet {
            iconView.tintColor = AppTheme.current.specialColor
        }
    }
    @IBOutlet fileprivate var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "new_list".localized
            titleLabel.textColor = AppTheme.current.secondaryTintColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTapGestureRecognizer()
    }
    
    fileprivate func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(recognizer)
    }
    
    @objc fileprivate func tap() {
        onTap?()
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
