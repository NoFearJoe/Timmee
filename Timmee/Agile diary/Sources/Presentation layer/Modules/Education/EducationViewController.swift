//
//  EducationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class EducationPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    private let pagesCount: Int = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (view.subviews.first as? UIScrollView)?.bounces = false
        dataSource = self
        setViewControllers([getViewController(at: 0)!], direction: .forward, animated: false, completion: nil)
    }
    
    private func getViewController(at index: Int) -> EducationViewController? {
        guard index >= 0, index < pagesCount else { return nil }
        let viewController = ViewControllersFactory.education
        viewController.view.tag = index
        viewController.setup(title: "education_title_\(index)".localized,
                             subtitle: "education_subtitle_\(index)".localized,
                             continueTitle: "education_continue_\(index)".localized)
        viewController.onContinue = { [unowned self] in
            guard let viewController = self.getViewController(at: index + 1) else { return }
            self.view.isUserInteractionEnabled = false
            self.setViewControllers([viewController], direction: .forward, animated: true) { _ in
                self.view.isUserInteractionEnabled = true
            }
        }
        return viewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getViewController(at: viewController.view.tag + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getViewController(at: viewController.view.tag - 1)
    }
    
}

final class EducationViewController: UIViewController {
    
    var onContinue: (() -> Void)?
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var continueButton: UIButton!
    
    @IBAction private func `continue`() {
        onContinue?()
    }
    
    func setup(title: String, subtitle: String, continueTitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        UIView.performWithoutAnimation {
            continueButton.setTitle(continueTitle, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
