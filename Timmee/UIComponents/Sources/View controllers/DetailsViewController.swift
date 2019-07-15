//
//  DetailsViewController.swift
//  UIComponents
//
//  Created by Илья Харабет on 24/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class DetailsViewController: UIViewController {
    
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    private let shadowContentView: UIView = UIView()
    private let bottomStretchableView: UIView = UIView()
    
    private weak var contentController: UIViewController?
    
    private var contentViewHeightConstraint: NSLayoutConstraint!
    
    private var isShown: Bool = false
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        
        setupScrollView()
        setupContentView()
        setupBottomStretchableView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapToScrollView))
        tapGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.show()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentInset()
    }
    
    public func setContentViewController(_ viewController: UIViewController) {
        contentController = viewController
        addChild(viewController)
        viewController.didMove(toParent: self)
        contentView.addSubview(viewController.view)
        viewController.view.allEdges().toSuperview()
        view.layoutIfNeeded()
        updateContentInset()
    }
    
    @objc private func onTapToScrollView() {
        hide()
    }
    
    private func prepareForShow() {
        guard !isShown else { return }
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height)
        shadowContentView.transform = contentView.transform
    }
    
    private func show() {
        guard !isShown else { return }
        isShown = true
        
        UIView.animate(withDuration: 0.25) {
            self.contentView.transform = .identity
            self.shadowContentView.transform = .identity
        }
    }
    
    private func hide() {
        guard isShown else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = .clear
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.height)
            self.shadowContentView.transform = self.contentView.transform
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = false
        
        if #available(iOSApplicationExtension 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        [scrollView.top(), scrollView.leading(), scrollView.trailing(), scrollView.bottom()].toSuperview()
    }
    
    private func setupContentView() {
        scrollView.addSubview(shadowContentView)
        scrollView.addSubview(contentView)
        
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 20
        
        shadowContentView.backgroundColor = .white
        shadowContentView.layer.cornerRadius = 20
        shadowContentView.configureShadow(radius: 16, opacity: 0.2, color: .black, offset: CGSize(width: 0, height: -4))
        shadowContentView.isUserInteractionEnabled = false
        
        [contentView.top(), contentView.leading(), contentView.trailing(), contentView.centerX(), contentView.bottom()].toSuperview()
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        contentViewHeightConstraint.isActive = true
        
        shadowContentView.allEdges().to(contentView, addTo: scrollView)
    }
    
    private func setupBottomStretchableView() {
        view.addSubview(bottomStretchableView)
        
        bottomStretchableView.backgroundColor = contentView.backgroundColor
        
        bottomStretchableView.topToBottom().to(contentView, addTo: view)
        [bottomStretchableView.leading(), bottomStretchableView.trailing(), bottomStretchableView.bottom()].toSuperview()
    }
    
    private func updateContentInset() {
        guard let contentController = contentController else { return }
        
        let height = contentController.view.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 99999),
                                                                    withHorizontalFittingPriority: .required,
                                                                    verticalFittingPriority: .defaultLow).height
        
        contentViewHeightConstraint?.constant = height
        
        guard height > 0 else { return }
        
        prepareForShow()
        
        scrollView.contentInset.top = max(0, scrollView.bounds.height - height)
    }
    
}

extension DetailsViewController: UIScrollViewDelegate {
    
    
    
}

extension DetailsViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === scrollView
    }
    
}
