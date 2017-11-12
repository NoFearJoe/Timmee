//
//  LoadingView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class LoadingView: UIView {
    
    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        addSubview(activityIndicator)
        backgroundColor = AppTheme.white.scheme.panelColor
        clipsToBounds = true
        layer.cornerRadius = 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override var isHidden: Bool {
        didSet {
            activityIndicator?.startAnimating()
        }
    }
    
}
