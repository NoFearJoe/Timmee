//
//  TaskEditorRouter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIImage
import class UIKit.UIViewController

protocol TaskEditorRouterInput: class {
    func close()
    func showPhotos(_ photos: [UIImage], startPosition: Int)
}

final class TaskEditorRouter {
    weak var transitionHandler: UIViewController!
}

extension TaskEditorRouter: TaskEditorRouterInput {
    
    func close() {
        transitionHandler.dismiss(animated: true, completion: nil)
    }
    
    func showPhotos(_ photos: [UIImage], startPosition: Int) {
        let viewController = ViewControllersFactory.photoPreview
        viewController.loadViewIfNeeded()
        viewController.photos = photos
        viewController.startPosition = startPosition
        transitionHandler.present(viewController, animated: true, completion: nil)
    }
    
}
