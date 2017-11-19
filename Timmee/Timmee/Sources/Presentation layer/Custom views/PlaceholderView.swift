//
//  PlaceholderView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 21.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIView
import class UIKit.UILabel
import class UIKit.UIImage
import class UIKit.UIImageView

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
        
        [centerX(), centerY(), leading(20), trailing(20)].toSuperview()
        
        setupAppearance()
    }
    
}

fileprivate extension PlaceholderView {
    
    func setupAppearance() {
        iconView.tintColor = AppTheme.current.secondaryTintColor
        titleLabel.textColor = AppTheme.current.tintColor
        subtitleLabel.textColor = AppTheme.current.secondaryTintColor
    }
    
}
