//
//  SynchronizationProgressView.swift
//  UIComponents
//
//  Created by i.kharabet on 25.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class SynchronizationProgressView: UIView {
    
    public override var isHidden: Bool {
        didSet {
            isHidden ? stopAnimation() : startAnimation()
        }
    }
    
    @IBInspectable public var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }
    
    public override var tintColor: UIColor! {
        didSet {
            iconView.tintColor = tintColor
        }
    }
    
    private(set) public var iconView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        iconView = UIImageView(frame: .zero)
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
        iconView.allEdges().toSuperview()
    }
    
    private func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi
        animation.duration = 2
        animation.repeatCount = Float.infinity
        iconView?.layer.add(animation, forKey: "rotation")
    }
    
    private func stopAnimation() {
        iconView?.layer.removeAnimation(forKey: "rotation")
    }
    
}

public class ModalWindow: UIWindow {
    private var _windowFrame: CGRect?
    public var windowFrame: CGRect {
        get {
            return self._windowFrame ?? self.frame
        }
        set {
            self._windowFrame = newValue
            self.frame = newValue
        }
    }
    
    override public var frame: CGRect {
        didSet {
            if self.frame != self.windowFrame {
                self.frame = self.windowFrame
            }
        }
    }
}

public class SynchronizationStatusBar: ModalWindow {
    
    public var statusBarFrame: (() -> CGRect)?
    public var icon: UIImage? {
        didSet {
            controller.loadingView.icon = icon
        }
    }
    
    private var statusBarFrameChangesObserver: Any?
    private var isShown: Bool = false
    
    private let controller = SynchronizationViewController()
    
    public override var tintColor: UIColor! {
        didSet {
            controller.statusLabel.textColor = tintColor
            controller.loadingView.tintColor = tintColor
        }
    }
    
    @available(iOSApplicationExtension 13.0, *)
    public override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        
        self.backgroundColor = .clear
        self.windowLevel = UIWindow.Level.statusBar + 1
        self.rootViewController = controller
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.windowLevel = UIWindow.Level.statusBar + 1
        self.rootViewController = controller
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        self.stopStatusBarChangesObserving()
    }
    
    private func startStatusBarFrameChangesObserving() {
        guard self.statusBarFrameChangesObserver == nil else { return }
        
        self.statusBarFrameChangesObserver = NotificationCenter.default.addObserver(forName: UIApplication.willChangeStatusBarFrameNotification, object: nil, queue: nil, using: { [weak self] notification in
            guard
                let self = self,
                let frame = (notification.userInfo?[UIApplication.statusBarFrameUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
            
            self.windowFrame = frame
        })
    }
    
    private func stopStatusBarChangesObserving() {
        guard let observer = self.statusBarFrameChangesObserver else { return }
        
        self.statusBarFrameChangesObserver = nil
        
        NotificationCenter.default.removeObserver(observer)
    }
    
    public func show() {
        guard !isShown else { return }
        
        let size: CGSize = statusBarFrame?().size ?? .zero
        let height: CGFloat
        if #available(iOS 13, *) {
            height = (size.height > 20 ? size.height : size.height) + 20
        } else {
            height = size.height > 20 ? size.height + 6 : size.height
        }
        windowFrame = CGRect(x: 0, y: -height, width: size.width, height: height)
        isHidden = false
        isShown = true
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, animations: {
            self.windowFrame = CGRect(origin: .zero, size: CGSize(width: size.width, height: height))
        })
        startStatusBarFrameChangesObserving()
        
        controller.startAnimation()
    }
    
    public func hide() {
        guard isShown else { return }
        stopStatusBarChangesObserving()
        isShown = false
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, animations: {
            let height = self.frame.height
            self.windowFrame = CGRect(x: 0, y: -height,
                                      width: self.statusBarFrame?().width ?? 0, height: height)
        }) { finished in
            if finished {
                self.isHidden = true
                self.controller.stopAnimation()
            }
        }
    }
    
}

public class SynchronizationViewController: UIViewController {
    
    public var statusLabel = UILabel()
    public var loadingView = SynchronizationProgressView()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.text = "synchronization".localized
        
        view.addSubview(statusLabel)
        [statusLabel.centerX(), statusLabel.bottom(3)].toSuperview()
        
        view.addSubview(loadingView)
        [loadingView.leadingToTrailing(4), loadingView.centerY()].to(statusLabel, addTo: view)
        loadingView.width(14)
        loadingView.height(14)
    }
    
    func startAnimation() {
        loadingView.isHidden = false
    }
    
    func stopAnimation() {
        loadingView.isHidden = true
    }
    
}
