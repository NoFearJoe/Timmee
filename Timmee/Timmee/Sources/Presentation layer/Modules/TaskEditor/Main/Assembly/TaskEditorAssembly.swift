//
//  TaskEditorAssembly.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

final class TaskEditorAssembly {
    
    static func assembly(with view: TaskEditorView) -> TaskEditorInput {
        let presenter = TaskEditorPresenter()
        let interactor = TaskEditorInteractor()
        let router = TaskEditorRouter()
        
        view.output = presenter
        
        presenter.interactor = interactor
        presenter.router = router
        presenter.view = view
        
        interactor.output = presenter
        
        router.transitionHandler = view
        
        return presenter
    }
    
}
