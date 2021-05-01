//
//  ScreenPlaceholderView.swift
//  UIComponents
//
//  Created by Илья Харабет on 29/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ScreenPlaceholderView: UIView {
    
    public static var titleFont: UIFont?
    public static var titleColor: UIColor?
    public static var messageFont: UIFont?
    public static var messageColor: UIColor?
    public static var buttonFont: UIFont?
    public static var buttonTextColor: UIColor?
    
    var onTapButton: (() -> Void)?
    
    private let contentView = UIStackView()
    public let titleLabel = UILabel()
    public let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public func setup(into view: UIView) {
        view.addSubview(self)
        view.bringSubviewToFront(self)
        
        allEdges().to(view.safeAreaLayoutGuide)
        
        (self as? Customizable)?.applyAppearance()
    }
    
    public func configure(title: String,
                          message: String?,
                          action: String?,
                          onTapButton: (() -> Void)?) {
        self.onTapButton = onTapButton
        
        titleLabel.text = title
        
        messageLabel.text = message
        messageLabel.isHidden = message == nil
        
        actionButton.setTitle(action, for: .normal)
        actionButton.isHidden = action == nil
    }
    
    public func setVisible(_ isVisible: Bool, animated: Bool) {
        superview?.bringSubviewToFront(self)
        
        alpha = isVisible ? 0 : 1
        
        if animated {
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.alpha = isVisible ? 1 : 0
                },
                completion: nil
            )
        } else {
            alpha = isVisible ? 1 : 0
        }
    }
    
    private func setup() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupViews() {
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            contentView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 20)
        ])
        
        contentView.axis = .vertical
        contentView.distribution = .fill
        contentView.alignment = .center
        contentView.spacing = 12
        
        contentView.addArrangedSubview(titleLabel)
        contentView.addArrangedSubview(messageLabel)
        contentView.addArrangedSubview(actionButton)
        
        if #available(iOSApplicationExtension 11.0, *) {
            contentView.setCustomSpacing(40, after: messageLabel)
            contentView.setCustomSpacing(12, after: titleLabel)
        }
        
        titleLabel.font = Self.titleFont
        titleLabel.textColor = Self.titleColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        messageLabel.font = Self.messageFont
        messageLabel.textColor = Self.messageColor
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        actionButton.titleLabel?.font = Self.buttonFont
        actionButton.setTitleColor(Self.buttonTextColor, for: .normal)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        actionButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc private func didTapButton() {
        onTapButton?()
    }
    
}
