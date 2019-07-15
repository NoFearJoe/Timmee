//
//  DetailsContentPlaceholderDefault.swift
//  MobileBank
//
//  Created by g.novik on 04.10.17.
//  Copyright © 2017 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

public final class DetailsContentPlaceholderDefault: UIView {
    
    // Outlet
    @IBOutlet weak var contentView: UIView!
    
    // Dependency
    private let pulseAnimation = CAAnimation() // TODO
    
    // Private
    private var animationShouldStop = false
    
    public func startAnimating() {
        animationShouldStop = false
        
        pulseAnimation.delegate = self
        contentView.layer.add(pulseAnimation,
                              forKey: Constants.pulseAnimationKey)
    }
    
    public func stopAnimating() {
        animationShouldStop = true
    }
    
    ///  Необходимо вызывать для очистки объекта
    public func clearAnimations() {
        pulseAnimation.delegate = nil
    }
    
    // MARK: - Constants
    
    enum Constants {
        static let pulseAnimationKey = "DetailsContentPlaceholderDefault.Constants.pulseAnimationKey"
    }
}

// MARK: - CAAnimationDelegate

extension DetailsContentPlaceholderDefault: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !animationShouldStop {
            contentView.layer.add(pulseAnimation,
                                  forKey: Constants.pulseAnimationKey)
        }
    }
}
