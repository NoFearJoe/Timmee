//
//  SectionContainer.swift
//  UIComponents
//
//  Created by Илья Харабет on 31/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class SectionContainer: UIView {
    
    private let stackView = UIStackView()
    
    private let titleStackView = UIStackView()
    
    public let titleLabel = UILabel()
    public let contentContainer = UIView()
    public let disclaimerLabel = LabelWithInsets()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func configure(title: String?, content: UIView, actionView: UIView? = nil, disclaimer: String? = nil) {
        titleLabel.text = title
        disclaimerLabel.text = disclaimer
        
        contentContainer.addSubview(content)
        content.allEdges().to(contentContainer.layoutMarginsGuide)
        
        if let actionView = actionView {
            titleStackView.addArrangedSubview(actionView)
        }
    }
    
}

private extension SectionContainer {
    
    func setupViews() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(titleStackView)
        stackView.addArrangedSubview(contentContainer)
        stackView.addArrangedSubview(disclaimerLabel)
                
        stackView.axis = .vertical
        stackView.spacing = 4
        
        titleStackView.addArrangedSubview(titleLabel)
        
        titleStackView.axis = .horizontal
        titleStackView.spacing = 8
        titleStackView.isLayoutMarginsRelativeArrangement = true
        titleStackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        let titleGap = UIView()
        titleGap.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleGap.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        titleStackView.addArrangedSubview(titleGap)
        
        contentContainer.configureShadow(radius: 8, opacity: 0.1)
        contentContainer.layer.cornerRadius = 12
        contentContainer.layoutMargins.left = 0
        contentContainer.layoutMargins.right = 0
        
        titleLabel.numberOfLines = 1
        
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.insets.left = 8
        disclaimerLabel.insets.right = 8
    }
    
    func setupLayout() {
        stackView.allEdges().toSuperview()
    }
    
}
