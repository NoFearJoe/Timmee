//
//  StackViewController.swift
//  UIComponents
//
//  Created by i.kharabet on 18.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public protocol StaticHeightStackChidController: AnyObject {
    var height: CGFloat { get }
}

public protocol DynamicHeightStackChildController: AnyObject {
    var onChangeHeight: ((CGFloat) -> Void)? { get set }
}

public protocol StackViewControllerDelegate: AnyObject {
    func stackViewController(_ stackViewController: StackViewController,
                             didChangeContentOffsetTo contentOffset: CGPoint)
}

public protocol StackViewControllerChild {
    var asViewController: UIViewController { get }
}

extension UIViewController: StackViewControllerChild {
    public var asViewController: UIViewController { self }
}

extension UIView: StackViewControllerChild {
    public var asViewController: UIViewController {
        if next as? UIViewController == nil {
            return WrapperViewController(view: self)
        } else {
            return next as! UIViewController
        }
    }
}

final class WrapperViewController: UIViewController {
    
    private let wrappedView: UIView
    
    init(view: UIView) {
        wrappedView = view

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = wrappedView
    }
    
}

open class StackViewController: UIViewController {
    
    public weak var delegate: StackViewControllerDelegate?
    
    public let scrollView = UIScrollView(frame: .zero)
    public let stackView = UIStackView(frame: .zero)
    
    private var arrangedViewControllers: [ArrangedViewController] = []
    
    public var viewControllers: [UIViewController] {
        return self.arrangedViewControllers.map { $0.viewController }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupScrollView()
        self.setupStackView()
        self.setupScrollViewConstraints()
        self.setupStackViewConstraints()
    }
    
    // MARK: - General methods
    
    public final func setChild(_ child: StackViewControllerChild, at index: Int) {
        self.removeChild(at: index)
        
        self.addChild(child.asViewController)
        
        let insertIndex = self.findInsertIndex(in: self.arrangedViewControllers, for: index)
        
        arrangedViewControllers.insert(ArrangedViewController(index: index,
                                                              viewController: child.asViewController),
                                       at: insertIndex)
        
        self.stackView.insertArrangedSubview(child.asViewController.view, at: insertIndex)
        self.addHeightConstraint(toChild: child.asViewController)
        child.asViewController.didMove(toParent: self)
    }
    
    public final func removeChild(at index: Int) {
        guard let existingArrangedViewController = arrangedViewControllers.first(where: { $0.index == index }) else { return }
        
        let existingViewController = existingArrangedViewController.viewController
        existingViewController.willMove(toParent: nil)
        self.stackView.removeArrangedSubview(existingViewController.view)
        existingViewController.view.removeFromSuperview()
        existingViewController.removeFromParent()
        
        guard let index = self.arrangedViewControllers.index(of: existingArrangedViewController) else { return }
        self.arrangedViewControllers.remove(at: index)
    }
    
}

// MARK: - UIScrollViewDelegate

extension StackViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.stackViewController(self, didChangeContentOffsetTo: scrollView.contentOffset)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
}

// MARK: - Utilities

private extension StackViewController {
    
    private func findInsertIndex(in viewControllers: [ArrangedViewController], for index: Int) -> Int {
        let indexes = viewControllers.map { $0.index }
        for (i, n) in indexes.enumerated() {
            guard i + 1 < indexes.count else {
                return n < index ? i + 1 : i
            }
            if n < index, index < indexes[i + 1] {
                return i + 1
            }
        }
        return 0
    }
    
}

// MARK: - Main view setup

private extension StackViewController {
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
}

// MARK: - Scroll view setup

private extension StackViewController {
    
    func setupScrollView() {
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = .clear
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.bounces = true
        self.scrollView.bouncesZoom = false
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 1
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .always
        }
        self.scrollView.delaysContentTouches = false
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.scrollView)
    }
    
    func setupScrollViewConstraints() {
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
    }
    
}

// MARK: - Stack view setup

private extension StackViewController {
    
    func setupStackView() {
        self.stackView.backgroundColor = .clear
        self.stackView.axis = .vertical
        self.stackView.alignment = .fill
        self.stackView.distribution = .equalSpacing
        self.stackView.spacing = 0
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(self.stackView)
    }
    
    func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.stackView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            self.stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            ])
    }
    
}

// MARK: - Child views managing

private extension StackViewController {
    
    func addHeightConstraint(toChild childController: UIViewController) {
        childController.view.translatesAutoresizingMaskIntoConstraints = false
        if let staticHeightController = childController as? StaticHeightStackChidController {
            childController.view.heightAnchor.constraint(equalToConstant: staticHeightController.height).isActive = true
        } else if let dynamicHeightController = childController as? DynamicHeightStackChildController {
            let constraint = childController.view.heightAnchor.constraint(equalToConstant: 0)
            constraint.isActive = true
            dynamicHeightController.onChangeHeight = { newHeight in
                constraint.constant = newHeight
            }
        } else {
            childController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        }
    }
    
}

// MARK: - Arranged view controller

private extension StackViewController {
    
    private struct ArrangedViewController: Hashable {
        let index: Int
        let viewController: UIViewController
        
        static func == (lhs: ArrangedViewController, rhs: ArrangedViewController) -> Bool {
            return lhs.index == rhs.index
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(index)
        }
    }
    
}
