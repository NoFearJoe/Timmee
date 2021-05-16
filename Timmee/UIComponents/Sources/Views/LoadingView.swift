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
    
    public var message: String? {
        didSet {
            titleLabel.text = message
            titleLabel.isHidden = message.nilIfEmpty == nil
        }
    }
    
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
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.isHidden = true
        
        backgroundColor = UIColor(rgba: "272727")
        clipsToBounds = true
        layer.cornerRadius = 6
        
        let contentStackView = UIStackView(arrangedSubviews: [activityIndicator, titleLabel])
        contentStackView.alignment = .center
        contentStackView.axis = .vertical
        contentStackView.distribution = .equalSpacing
        contentStackView.spacing = 8
        addSubview(contentStackView)
        [contentStackView.leading(8), contentStackView.trailing(8), contentStackView.centerY()].toSuperview()
    }
    
    public override var isHidden: Bool {
        didSet {
            activityIndicator?.startAnimating()
        }
    }
    
}
