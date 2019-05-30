//
//  BadgeView.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

open class BadgeView: UIView {
    
    open var title: String? {
        get { return self.badgeLabel.text }
        set { self.badgeLabel.text = newValue }
    }
    
    open var font: UIFont = UIFont.systemFont(ofSize: 11, weight: .medium) {
        didSet {
            self.badgeLabel.font = self.font
        }
    }
    open var titleColor: UIColor = UIColor.white {
        didSet {
            self.badgeLabel.textColor = self.titleColor
        }
    }
    
    private let badgeLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.setupBadgeLabel()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
        self.setupBadgeLabel()
    }
    
    private func setupView() {
        self.clipsToBounds = false
        self.backgroundColor = .red
        self.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        configureShadow(radius: 4, opacity: 0.25, color: .black, offset: CGSize(width: 0, height: 2))
    }
    
    private func setupBadgeLabel() {
        self.badgeLabel.frame = self.bounds
        self.badgeLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.badgeLabel.clipsToBounds = true
        self.badgeLabel.textAlignment = .center
        self.badgeLabel.font = self.font
        self.badgeLabel.textColor = self.titleColor
        self.addSubview(self.badgeLabel)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
}
