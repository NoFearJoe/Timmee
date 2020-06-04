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
        setupView()
        setupBadgeLabel()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        setupBadgeLabel()
    }
    
    private func setupView() {
        clipsToBounds = false
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        configureShadow(radius: 4, opacity: 0.25, color: .black, offset: CGSize(width: 0, height: 2))
    }
    
    private func setupBadgeLabel() {
        badgeLabel.frame = bounds
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.font = font
        badgeLabel.textColor = titleColor
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeLabel)
        [badgeLabel.top(), badgeLabel.bottom(), badgeLabel.leading(4), badgeLabel.trailing(4)].toSuperview()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
}
