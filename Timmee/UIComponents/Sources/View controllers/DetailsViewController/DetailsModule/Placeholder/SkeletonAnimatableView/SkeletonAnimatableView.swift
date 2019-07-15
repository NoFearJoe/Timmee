//
//  SkeletonAnimatableView.swift
//  DetailsUIKit
//
//  Created by g.novik on 02.04.2018.
//

import UIKit

public final class SkeletonAnimatableView: UIView, AnimatableView, CAAnimationDelegate {
    
    // Dependency
    private let pulseAnimation = CAAnimation() // TODO
    
    // Private
    private var animationShouldStop = false
    private let animationKey: String
    private let contentView: UIView
    
    // MARK: - Initialization
    
    public init(skeletView: UIView, animationKey: String) {
        self.animationKey = animationKey
        self.contentView = skeletView
        
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.clear
        self.addSubview(skeletView)
        
        skeletView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        skeletView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        skeletView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        skeletView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        skeletView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable, message: "init with coder is unavailable.")
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - IPlaceholderAnimatingView
    
    public func startAnimating() {
        animationShouldStop = false
        
        pulseAnimation.delegate = self
        contentView.layer.add(pulseAnimation,
                              forKey: animationKey)
    }
    
    public func stopAnimating() {
        animationShouldStop = true
    }
    
    ///  Необходимо вызывать для очистки объекта
    public func clearAnimations() {
        pulseAnimation.delegate = nil
    }
    
    // MARK: - CAAnimationDelegate
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !animationShouldStop {
            contentView.layer.add(pulseAnimation,
                                  forKey: animationKey)
        }
    }
}
