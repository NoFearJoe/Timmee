//
//  MainContainerView.swift
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
    
    private let representationManager = ListRepresentationManager()
    
    private let interactor = MainContainerInteractor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToApplicationEvents()
        
        setupRepresentationManager()
        setupMainTopView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = AppTheme.current.backgroundColor
        
        interactor.updateTaskDueDates()
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
        interactor.updateTaskDueDates()
    }

}

extension MainViewController: ListRepresentationManagerOutput {
    
    func configureListRepresentation(_ representation: ListRepresentationInput) {
        representation.editingOutput = mainTopView
        mainTopView.editingInput = representation
    }
    
}

private extension MainViewController {
    
    func setupMainTopView() {
        mainTopView.output = representationManager
        addChildViewController(mainTopView)
        mainTopViewContainer.addSubview(mainTopView.view)
        mainTopView.view.allEdges().toSuperview()
        mainTopView.didMove(toParentViewController: self)
    }
    
    func setupRepresentationManager() {
        representationManager.output = self
        representationManager.containerViewController = self
        representationManager.listsContainerView = contentContainerView
        representationManager.setRepresentation(.table, animated: false)
    }
    
}
