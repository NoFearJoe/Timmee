//
//  MainContainerView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 25.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIView
import class UIKit.UIViewController
import enum UIKit.UIStatusBarStyle

final class MainViewController: UIViewController {

    @IBOutlet fileprivate var contentContainerView: UIView!
    @IBOutlet fileprivate var mainTopViewContainer: PassthrowView!
    
    fileprivate lazy var mainTopView: MainTopViewController = ViewControllersFactory.mainTop
    
    fileprivate let representationManager = ListRepresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRepresentationManager()
        setupMainTopView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = AppTheme.current.backgroundColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension MainViewController: ListRepresentationManagerOutput {
    
    func configureListRepresentation(_ representation: ListRepresentationInput) {
        representation.editingOutput = mainTopView
        mainTopView.editingInput = representation
    }
    
}

fileprivate extension MainViewController {
    
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
