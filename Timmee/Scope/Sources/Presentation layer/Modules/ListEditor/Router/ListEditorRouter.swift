//
//  ListEditorRouter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 10.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIViewController

protocol ListEditorRouterInput: class {
    func close()
    func showTasksImport()
}

protocol ListEditorRouterOutput: class {
    func willShowTasksImport(_ input: TasksImportInput)
}

final class ListEditorRouter {

    weak var output: ListEditorRouterOutput!
    weak var transitionHandler: UIViewController!

}

extension ListEditorRouter: ListEditorRouterInput {

    func close() {
        transitionHandler.dismiss(animated: true, completion: nil)
    }
    
    func showTasksImport() {
        let viewController = ViewControllersFactory.tasksImportView
        
        let moduleInput = TasksImportAssembly.assembly(with: viewController)
        output.willShowTasksImport(moduleInput)
        
        transitionHandler.present(viewController, animated: true, completion: nil)
    }

}
