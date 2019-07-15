//
//  FloatingMenu.swift
//  Timmee
//
//  Created by Илья Харабет on 06/01/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class FloatingMenu: UIView {
    
    struct Item {
        let title: String
        let action: () -> Void
    }
    
    private let items: [Item]
    private var buttons: [FloatingMenuButton] = []
    
    private weak var containerView: UIView!
    private weak var anchorView: UIView!
    
    private(set) var isShown: Bool = false
    
    init(items: [Item]) {
        self.items = items
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(to containerView: UIView) {
        self.containerView = containerView
        containerView.addSubview(self)
        containerView.bringSubviewToFront(self)
        [trailing(15), leading(15)].to(containerView)
    }
    
    func pin(to anchorView: UIView, offset: CGFloat) {
        self.anchorView = anchorView
        bottomToTop(-offset).to(anchorView, addTo: self.containerView)
    }
    
    func show(animated: Bool, animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
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
    
    func hide(animated: Bool, animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
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
            let button = FloatingMenuButton(frame: .zero)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    private func setupAppearance() {
        clipsToBounds = true
        adjustsImageWhenHighlighted = false
        tintColor = AppTheme.current.backgroundTintColor
        setTitleColor(AppTheme.current.backgroundTintColor, for: .normal)
        setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
        setBackgroundImage(UIImage.plain(color: AppTheme.current.thirdlyTintColor), for: .selected)
        setBackgroundImage(UIImage.plain(color: AppTheme.current.thirdlyTintColor), for: .highlighted)
    }
    
}
