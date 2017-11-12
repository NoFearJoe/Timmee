//
//  InAppPurchasesViewController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class InAppPurchasesViewController: UIPageViewController {
    
    fileprivate var inAppItems: [InAppPurchaseItem] {
        return InAppPurchaseItem.allNotPurchased
    }
    
    var autoscrollTimer: Timer?
    
    fileprivate var currentPageIndex: Int {
        return (viewControllers?.first as? InAppPurchaseViewController)?.index ?? 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        if let viewController = self.viewController(at: currentPageIndex) {
            setViewControllers([viewController],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startAutoscrollTimer()
    }
    
}

extension InAppPurchasesViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! InAppPurchaseViewController).index
        return self.viewController(at: index + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! InAppPurchaseViewController).index
        return self.viewController(at: index - 1)
    }
    
}

extension InAppPurchasesViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        autoscrollTimer?.invalidate()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        startAutoscrollTimer()
    }
    
}

fileprivate extension InAppPurchasesViewController {
    
    func viewController(at index: Int) -> InAppPurchaseViewController? {
        guard !inAppItems.isEmpty else { return nil }
        
        var i = index
        if index < 0 {
            i = inAppItems.count - 1
        } else if index >= inAppItems.count {
            i = 0
        }
        
        let viewController = ViewControllersFactory.inApp
        viewController.index = i
        if let item = inAppItems.item(at: i) {
            viewController.setInAppItem(item)
        }
        viewController.onPurchaseComplete = { [weak self] purchase in
            guard let `self` = self else { return }
            guard let firstViewController = self.viewController(at: 0) else { return }
            self.setViewControllers([firstViewController],
                                     direction: .forward,
                                     animated: true,
                                     completion: nil)
        }
        return viewController
    }
    
}

fileprivate extension InAppPurchasesViewController {

    func startAutoscrollTimer() {
        autoscrollTimer = Timer.scheduledTimer(timeInterval: 5,
                                               target: self,
                                               selector: #selector(performAutoscroll),
                                               userInfo: nil,
                                               repeats: false)
    }
    
    @objc func performAutoscroll() {
        let completion = { [unowned self] (isFinished: Bool) in
            self.view.isUserInteractionEnabled = true
            guard isFinished else { return }
            self.startAutoscrollTimer()
        }
        
        guard let viewController = viewController(at: currentPageIndex + 1) else { return }
        
        view.isUserInteractionEnabled = false
        
        setViewControllers([viewController],
                           direction: .forward,
                           animated: true,
                           completion: completion)
    }

}
