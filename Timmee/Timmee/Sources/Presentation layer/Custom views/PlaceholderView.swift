//
//  PlaceholderView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 21.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import PureLayout

final class PlaceholderView: UIView {
    
    @IBOutlet fileprivate var iconView: UIImageView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var subtitleLabel: UILabel!
    
    var icon: UIImage? {
        get { return iconView.image }
        set { iconView.image = newValue }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var subtitle: String? {
        get { return subtitleLabel.text }
        set { subtitleLabel.text = newValue }
    }
    
}

extension PlaceholderView {
 
    func setup(into view: UIView) {
        view.addSubview(self)
        view.bringSubview(toFront: self)
        self.autoCenterInSuperview()
        self.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        self.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
    }
    
}

fileprivate extension PlaceholderView {
    
    func setupAppearance() {
        titleLabel.textColor = AppTheme.current.scheme.tintColor
        subtitleLabel.textColor = AppTheme.current.scheme.secondaryTintColor
    }
    
}
