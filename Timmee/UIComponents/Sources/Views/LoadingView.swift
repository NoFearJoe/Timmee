//
//  LoadingView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import Workset

public final class LoadingView: UIView {
    
    private(set) public var activityIndicator: UIActivityIndicatorView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        activityIndicator = UIActivityIndicatorView(style: .white)
        addSubview(activityIndicator)
        backgroundColor = UIColor(rgba: "272727")
        clipsToBounds = true
        layer.cornerRadius = 6
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    public override var isHidden: Bool {
        didSet {
            activityIndicator?.startAnimating()
        }
    }
    
}
