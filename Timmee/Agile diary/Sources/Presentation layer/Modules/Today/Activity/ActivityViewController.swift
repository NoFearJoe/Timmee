//
//  ActivityViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 18.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class ActivityViewController: BaseViewController {
    
    var sprint: Sprint! {
        didSet {
            waterControlWidget.sprint = sprint
        }
    }
    
    private let stackViewController = StackViewController()
    
    private lazy var waterControlWidget = ViewControllersFactory.waterControlActivityWidget
    private lazy var stepsWidget = ViewControllersFactory.stepsActivityWidget
    private lazy var moodWidget = ViewControllersFactory.moodActivityWidget
    
    override func prepare() {
        super.prepare()
        setupStackViewController()
        setupWidgets()
    }
    
    override func refresh() {
        super.refresh()
        waterControlWidget.refresh()
        stepsWidget.refresh()
        moodWidget.refresh()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
    }
    
}

private extension ActivityViewController {
    
    func setupStackViewController() {
        addChild(self.stackViewController)
        view.addSubview(stackViewController.view)
        [stackViewController.view.top(), stackViewController.view.bottom(),
         stackViewController.view.leading(), stackViewController.view.trailing()].toSuperview()
        stackViewController.didMove(toParent: self)
        stackViewController.view.clipsToBounds = false
    }
    
    func setupWidgets() {
        stackViewController.setChild(waterControlWidget, at: 0)
        stackViewController.setChild(moodWidget, at: 1)
        stackViewController.setChild(stepsWidget, at: 2)
    }
    
}
