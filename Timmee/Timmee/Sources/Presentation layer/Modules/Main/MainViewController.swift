//
//  MainViewController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 25.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Foundation
import class UIKit.UIView
import class UIKit.UIViewController
import enum UIKit.UIStatusBarStyle

final class MainViewController: UIViewController {

    @IBOutlet private var contentContainerView: UIView!
    @IBOutlet private var mainTopViewContainer: PassthrowView!
    
    private lazy var mainTopView: MainTopViewController = ViewControllersFactory.mainTop
    
    private let tasksService = ServicesAssembly.shared.tasksService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToApplicationEvents()
        
        setupMainTopView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = AppTheme.current.backgroundColor
        
        tasksService.updateTasksDueDates()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func subscribeToApplicationEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    @objc func didBecomeActive() {
        tasksService.updateTasksDueDates()
    }

}

private extension MainViewController {
    
    func setupMainTopView() {
//        mainTopView.output = representationManager
        addChildViewController(mainTopView)
        mainTopViewContainer.addSubview(mainTopView.view)
        mainTopView.view.allEdges().toSuperview()
        mainTopView.didMove(toParentViewController: self)
    }
    
}
