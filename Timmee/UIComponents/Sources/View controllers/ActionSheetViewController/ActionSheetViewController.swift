//
//  ActionSheetViewController.swift
//  UIComponents
//
//  Created by i.kharabet on 18/10/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset

public struct ActionSheetItem {
    public let icon: UIImage
    public let title: String
    public let action: () -> Void
    
    public init(icon: UIImage, title: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.action = action
    }
}

public final class ActionSheetViewController: UIViewController {
    
    public var backgroundColor: UIColor = .black {
        didSet {
            contentView.backgroundColor = backgroundColor
            closeButton.setBackgroundImage(UIImage.plain(color: backgroundColor), for: .normal)
        }
    }
    
    public var tintColor: UIColor = .white {
        didSet {
            itemViews.forEach {
                $0.tintColor = tintColor
            }
            closeButton.tintColor = tintColor
            closeButton.setTitleColor(tintColor, for: .normal)
        }
    }
    
    public var separatorColor: UIColor = .gray {
        didSet {
            separators.forEach {
                $0.backgroundColor = separatorColor
            }
        }
    }
    
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let itemViews: [ActionSheetItemView]
    private let separators: [UIView]
    
    private let closeButton = UIButton()
    
    public init(items: [ActionSheetItem]) {
        itemViews = Self.makeItemViews(items: items)
        separators = items.dropLast().map { _ in Self.makeSeparatorView() }
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .coverVertical
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapToBackground))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)

        for i in 0..<(itemViews.count + separators.count) {
            if i % 2 == 0 {
                stackView.addArrangedSubview(itemViews[i / 2])
            } else {
                stackView.addArrangedSubview(separators[i / 2])
            }
        }
    }
    
    @objc private func onTapToCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onTapToBackground() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ActionSheetViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        touch.view === view
    }
    
}

private extension ActionSheetViewController {
    
    func setupViews() {
        view.backgroundColor = .clear
        
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 12
        closeButton.setTitle("close".localized, for: .normal)
        closeButton.addTarget(self, action: #selector(onTapToCloseButton), for: .touchUpInside)
    }
    
    func setupLayout() {
        closeButton.height(52)
        [closeButton.leading(16), closeButton.trailing(16)].toSuperview()
        if #available(iOSApplicationExtension 11.0, *) {
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -16).isActive = true
        } else {
            closeButton.bottom(16).toSuperview()
        }
        
        [contentView.leading(16), contentView.trailing(16)].toSuperview()
        contentView.bottomToTop(-16).to(closeButton, addTo: view)
        if #available(iOSApplicationExtension 11.0, *) {
            contentView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: 16).isActive = true
        } else {
            contentView.topAnchor.constraint(greaterThanOrEqualTo: topLayoutGuide.topAnchor,
                                             constant: 16).isActive = true
        }
        
        stackView.allEdges().toSuperview()
        
        itemViews.forEach {
            $0.height(52)
        }
    }
    
    static func makeItemViews(items: [ActionSheetItem]) -> [ActionSheetItemView] {
        items.map {
            ActionSheetItemView(item: $0)
        }
    }
    
    static func makeSeparatorView() -> UIView {
        let view = UIView()
        view.height(0.5)
        return view
    }
    
}
