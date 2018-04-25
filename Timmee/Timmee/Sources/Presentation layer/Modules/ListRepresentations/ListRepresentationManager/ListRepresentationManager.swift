//
//  ListRepresentationManager.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class UIKit.UIView
import class UIKit.UIViewController

final class ListRepresentationManager {

    weak var containerViewController: UIViewController!
    weak var listsContainerView: UIView!
    
    weak var output: ListRepresentationManagerOutput?
    weak var listRepresentationOutput: ListRepresentationOutput!
    
    private var representation: ListRepresentation = .table
    
    var currentListRepresentationInput: ListRepresentationInput!

}

extension ListRepresentationManager: ListRepresentationManagerInput {

    func setRepresentation(_ representation: ListRepresentation, animated: Bool) {
        performRepresentationChange(to: representation, animated: animated)
        self.representation = representation
    }

}

private extension ListRepresentationManager {

    func performRepresentationChange(to: ListRepresentation, animated: Bool) {
        let newPresentation: ListRepresentationInput
        switch to {
        case .table:
            let view = ViewControllersFactory.tableListRepresentation
            
            containerViewController.addChildViewController(view)
            
            newPresentation = TableListRepresentationAssembly.assembly(with: view,
                                                                       output: listRepresentationOutput)
            
            view.loadViewIfNeeded()
        }
        
        output?.configureListRepresentation(newPresentation)
        
        let toView = newPresentation.viewController.view!

        guard let currentRepresentation = currentListRepresentationInput else {
            listsContainerView.addSubview(toView)
            newPresentation.viewController.didMove(toParentViewController: containerViewController)
            self.layoutRepresentationView(toView)
            currentListRepresentationInput = newPresentation
            return
        }
        
        let fromView = currentRepresentation.viewController.view
        
        let transition = {
            fromView?.removeFromSuperview()
            self.listsContainerView.addSubview(toView)
            self.layoutRepresentationView(toView)
        }
        
        let completion = { (finished: Bool) in
            if finished {
                self.currentListRepresentationInput = newPresentation
                newPresentation.viewController.didMove(toParentViewController: self.containerViewController)
            }
        }
        
        if animated {
            UIView.transition(with: listsContainerView,
                              duration: 0.35,
                              options: .transitionFlipFromBottom,
                              animations: transition,
                              completion: completion)
        } else {
            transition()
            newPresentation.viewController.didMove(toParentViewController: containerViewController)
            currentListRepresentationInput = newPresentation
        }
    }
    
    func layoutRepresentationView(_ view: UIView) {
        view.allEdges().toSuperview()
    }

}
