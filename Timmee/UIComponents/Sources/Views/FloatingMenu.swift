//
//  FloatingMenu.swift
//  Timmee
//
//  Created by Илья Харабет on 06/01/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class FloatingMenu: UIView {
    
    public struct Item {
        public let title: String
        public let action: () -> Void
        
        public init(title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }
    }
    
    public struct Colors {
        let tintColor: UIColor
        let backgroundColor: UIColor
        let secondaryBackgroundColor: UIColor
        
        public init(tintColor: UIColor,
                    backgroundColor: UIColor,
                    secondaryBackgroundColor: UIColor) {
            self.tintColor = tintColor
            self.backgroundColor = backgroundColor
            self.secondaryBackgroundColor = secondaryBackgroundColor
        }
    }
    
    private let items: [Item]
    private var buttons: [FloatingMenuButton] = []
    
    private let colors: Colors
    
    private weak var containerView: UIView!
    private weak var anchorView: UIView!
    
    public private(set) var isShown: Bool = false
    
    public init(items: [Item], colors: Colors) {
        self.items = items
        self.colors = colors
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupButtons()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func add(to containerView: UIView) {
        self.containerView = containerView
        containerView.addSubview(self)
        containerView.bringSubviewToFront(self)
        [trailing(15), leading(15)].to(containerView)
    }
    
    public func pin(to anchorView: UIView, offset: CGFloat) {
        self.anchorView = anchorView
        bottomToTop(-offset).to(anchorView, addTo: self.containerView)
    }
    
    public func show(animated: Bool, animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        buttons.enumerated().forEach { index, button in
            let x = button.bounds.width + 15
            button.transform = CGAffineTransform(translationX: x, y: 0)
            button.isHidden = false
        }
        
        if animated {
            let animationDuration: TimeInterval = 0.3
            self.buttons.reversed().enumerated().forEach { index, button in
                let duration: TimeInterval = animationDuration / (0.5 * Double(self.buttons.count + 1))
                UIView.animate(withDuration: duration,
                               delay: (duration / 2) * Double(index),
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0,
                               options: .curveEaseOut,
                               animations: { button.transform = .identity },
                               completion: nil)
            }
            UIView.animate(withDuration: animationDuration,
                           animations: { animations?() },
                           completion: { _ in completion?() })
        } else {
            self.buttons.forEach { button in
                button.transform = .identity
            }
            animations?()
            completion?()
        }
        
        isShown = true
    }
    
    public func hide(animated: Bool, animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        if animated {
            let animationDuration: TimeInterval = 0.2
            self.buttons.enumerated().forEach { index, button in
                let duration: TimeInterval = animationDuration / (0.5 * Double(self.buttons.count + 1))
                UIView.animate(withDuration: duration,
                               delay: (duration / 2) * Double(index),
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: 0,
                               options: .curveEaseIn,
                               animations: {
                                   let x = button.bounds.width + 15
                                   button.transform = CGAffineTransform(translationX: x, y: 0)
                               },
                               completion: nil)
            }
            UIView.animate(withDuration: animationDuration,
                           animations: { animations?() },
                           completion: { _ in
                               self.buttons.forEach { $0.isHidden = true }
                               completion?()
            })
        } else {
            self.buttons.reversed().enumerated().forEach { index, button in
                let x = button.bounds.width + 15
                button.transform = CGAffineTransform(translationX: x, y: 0)
                button.isHidden = true
            }
            animations?()
            completion?()
        }
        
        isShown = false
    }
    
    private func setupButtons() {
        var buttons: [FloatingMenuButton] = []
        items.reversed().enumerated().forEach { index, item in
            let button = FloatingMenuButton(colors: colors)
            button.isHidden = true
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(item.title, for: .normal)
            button.action = item.action
            button.addTarget(self, action: #selector(onTapToMenuButton(_:)), for: .touchUpInside)
            addSubview(button)
            button.height(36)
            button.trailing().toSuperview()
            if index == 0 {
                button.bottom().toSuperview()
            } else if let previousButton = buttons.item(at: index - 1) {
                button.bottomToTop(-12).to(previousButton, addTo: self)
            }
            if index == items.count - 1 {
                button.top().toSuperview()
            }
            buttons.append(button)
        }
        self.buttons = buttons.reversed()
    }
    
    @objc private func onTapToMenuButton(_ button: FloatingMenuButton) {
        button.action?()
    }
    
}

final class FloatingMenuButton: UIButton {
    
    var action: (() -> Void)?
    
    private let colors: FloatingMenu.Colors
    
    init(colors: FloatingMenu.Colors) {
        self.colors = colors
        super.init(frame: .zero)
        setupAppearance()
    }
    
    private override init(frame: CGRect) {
        fatalError()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    private func setupAppearance() {
        clipsToBounds = true
        adjustsImageWhenHighlighted = false
        tintColor = colors.tintColor
        setTitleColor(colors.tintColor, for: .normal)
        setBackgroundImage(UIImage.plain(color: colors.backgroundColor), for: .normal)
        setBackgroundImage(UIImage.plain(color: colors.secondaryBackgroundColor), for: .selected)
        setBackgroundImage(UIImage.plain(color: colors.secondaryBackgroundColor), for: .highlighted)
    }
    
}
