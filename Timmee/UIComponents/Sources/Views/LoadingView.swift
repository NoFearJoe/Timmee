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
    private(set) public var titleLabel: UILabel!
    
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
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textAlignment = .center
        
        backgroundColor = UIColor(rgba: "272727")
        clipsToBounds = true
        layer.cornerRadius = 6
        
        let contentStackView = UIStackView(arrangedSubviews: [activityIndicator, titleLabel])
        contentStackView.alignment = .center
        contentStackView.axis = .vertical
        contentStackView.distribution = .equalSpacing
        contentStackView.spacing = 8
        addSubview(contentStackView)
        [contentStackView.leading(4), contentStackView.trailing(4), contentStackView.centerY()].toSuperview()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
//        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    public override var isHidden: Bool {
        didSet {
            activityIndicator?.startAnimating()
        }
    }
    
}
