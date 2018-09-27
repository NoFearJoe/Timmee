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

public final class PlaceholderView: UIView {
    
    @IBOutlet public var iconView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!
    
    public var icon: UIImage? {
        get { return iconView.image }
        set {
            iconView.image = newValue
            iconView.superview?.isHidden = newValue == nil
        }
    }
    
    public var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
   public  var subtitle: String? {
        get { return subtitleLabel.text }
        set { subtitleLabel.text = newValue }
    }
    
}

extension PlaceholderView {
 
    public func setup(into view: UIView) {
        view.addSubview(self)
        view.bringSubviewToFront(self)
        
        [centerX(), centerY(), leading(20), trailing(20)].toSuperview()
        
        (self as? Customizable)?.applyAppearance()
    }
    
}
