//
//  PresentingAnimator.swift
//  MobileBank
//
//  Created by Popov Yuri on 06/12/16.
//  Copyright © 2016 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

final public class PresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    public enum Style {
        case blur
        case transparent
        
        public var alpha: CGFloat {
            switch self {
            case .blur: return 0.9
            case .transparent: return 0.7
            }
        }
        
        public var backgroundColor: UIColor {
            switch self {
            case .blur: return .black
            case .transparent: return .black
            }
        }
        
        public func createSnapshot() -> UIImage {
            switch self {
            case .blur:
                return UIApplication.sharedInExtension?.activeWindowSnapshot ?? UIImage()
            case .transparent:
                return UIApplication.sharedInExtension?.activeWindowSnapshot ?? UIImage()
            }
        }
    }
    
    @objc(BlurredAnimatorMode) public enum Mode: Int {
        case presentation
        case dismission
    }
    
    public var duration: TimeInterval = .animation300ms
    public var mode = Mode.presentation
    public var style: Style
    
    private var blurredImageView = UIImageView()
    private let tintView = UIView()
    
    /// MARK: - Initializers
    
    public init(style: Style) {
        self.style = style
    }
    
    /// MARK: - UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to),
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
            else { return }
        
        var destinationView: UIView
        var initialFrame: CGRect
        var finalFrame: CGRect
        
        var blurredImageViewAlphaFinal: CGFloat = 0
        var tintViewAlphaFinal: CGFloat = 0
        var timingFunction: CAMediaTimingFunction
        
        let containerView = transitionContext.containerView
        
        switch mode {
        case .presentation:
            setupTransitionViews(in: containerView)

            destinationView = toView
            blurredImageViewAlphaFinal = 1
            tintViewAlphaFinal = style.alpha

            // Исходное состояние анимируемуй вьюшки - внизу, за границей экрана. В ходе анимации сдвигается вверх на свое место.
            let startPoint = CGPoint(x: destinationView.frame.minX, y: destinationView.frame.maxY)
            initialFrame = CGRect(origin: startPoint, size: destinationView.frame.size)
            finalFrame = destinationView.frame

            timingFunction = .easeOutCubic()

        case .dismission:
            destinationView = fromView

            let startPoint = CGPoint(x: destinationView.frame.minX, y: destinationView.frame.maxY)
            finalFrame = CGRect(origin: startPoint, size: destinationView.frame.size)
            initialFrame = destinationView.frame

            duration = 0.2
            timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        }

        destinationView.frame = initialFrame
        destinationView.backgroundColor = .clear
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(blurredImageView)
        containerView.bringSubviewToFront(tintView)
        containerView.bringSubviewToFront(destinationView)

        UIView.animateWithDuration(duration: duration, timingFunction: timingFunction, animations: {
            destinationView.frame = finalFrame
            self.blurredImageView.alpha = blurredImageViewAlphaFinal
            self.tintView.alpha = tintViewAlphaFinal
        }, completion: { (_) in
            transitionContext.completeTransition(true)
        })
    }
    
    private func setupTransitionViews(in containerView: UIView) {
        
        // Blurred image
        blurredImageView = UIImageView(image: style.createSnapshot())
        blurredImageView.frame = containerView.bounds
        blurredImageView.alpha = 0
        containerView.addSubview(blurredImageView)
        
        // Tint
        tintView.frame = containerView.bounds
        tintView.backgroundColor = style.backgroundColor
        tintView.alpha = 0
        containerView.addSubview(tintView)
    }
}

extension TimeInterval {
    static let animation300ms: TimeInterval = 0.3
}

/// Параметры тайминг-функций: http://easings.net/ru
public extension CAMediaTimingFunction {
    
    @objc class func easeOutCubic() -> CAMediaTimingFunction {
        return CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1.0)
    }
    
    @objc class func easeInCubic() -> CAMediaTimingFunction {
        return CAMediaTimingFunction(controlPoints: 0.55, 0.055, 0.675, 0.19)
    }
}

public extension UIView {
    
    @objc class func animateWithDuration(duration: TimeInterval,
                                         timingFunction: CAMediaTimingFunction,
                                         animations: @escaping () -> Void,
                                         completion: ((Bool) -> Void)?) {
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: duration, animations: animations, completion: completion)
        CATransaction.commit()
    }
}
