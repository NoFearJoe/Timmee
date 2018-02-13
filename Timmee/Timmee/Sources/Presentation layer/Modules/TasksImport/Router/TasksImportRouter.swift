//
//  TasksImportRouter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIViewController

protocol TasksImportRouterInput: class {
    func close()
}

final class TasksImportRouter {

    weak var transitionHandler: UIViewController!

}

extension TasksImportRouter: TasksImportRouterInput {

    func close() {
        if let presentedViewController = transitionHandler.presentedViewController {
            presentedViewController.dismiss(animated: false, completion: nil)
        }
        transitionHandler.dismiss(animated: true, completion: nil)
    }

}
