//
//  TaskEditorRouter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIViewController

protocol TaskEditorRouterInput: class {
    func close()
}

final class TaskEditorRouter {
    weak var transitionHandler: UIViewController!
}

extension TaskEditorRouter: TaskEditorRouterInput {
    
    func close() {
        transitionHandler.dismiss(animated: true, completion: nil)
    }
    
}
