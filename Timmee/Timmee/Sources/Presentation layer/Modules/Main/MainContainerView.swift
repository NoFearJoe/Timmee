//
//  MainContainerView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 25.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import PureLayout

final class MainContainerView: UIViewController {

    @IBOutlet fileprivate weak var contentContainerView: BarView!
    @IBOutlet fileprivate weak var mainTopViewContainer: PassthrowView!
    
    fileprivate lazy var mainTopView: MainTopViewController = {
        let mainTopView = ViewControllersFactory.mainTop
        mainTopView.output = self
        return mainTopView
    }()
    
    fileprivate let representationManager = ListRepresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        representationManager.containerViewController = self
        representationManager.listsContainerView = contentContainerView
        representationManager.setRepresentation(.table, animated: false)
        
        setupMainTopView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.scheme.tintColor
//        contentContainerView.barColor = AppTheme.current.scheme.backgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setupMainTopView() {
        addChildViewController(mainTopView)
        mainTopViewContainer.addSubview(mainTopView.view)
        mainTopView.view.autoPinEdgesToSuperviewEdges()
        mainTopView.didMove(toParentViewController: self)
    }

}

extension MainContainerView: MainTopViewControllerOutput {

    func currentListChanged(to list: List) {
        representationManager.setList(list)
    }
    
    func listCreated() {
        representationManager.forceTaskCreation()
    }

}
