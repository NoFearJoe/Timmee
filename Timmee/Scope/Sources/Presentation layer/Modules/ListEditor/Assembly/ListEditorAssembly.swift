//
//  ListEditorAssembly.swift
//  Timmee
//
//  Created by Ilya Kharabet on 10.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

final class ListEditorAssembly {

    static func assembly(with view: ListEditorView) -> ListEditorInput {
        let presenter = ListEditorPresenter()
        let interactor = ListEditorInteractor()
        let router = ListEditorRouter()
        
        view.output = presenter
        
        presenter.interactor = interactor
        presenter.router = router
        presenter.view = view
        
        interactor.output = presenter
        
        router.transitionHandler = view
        router.output = presenter
        
        return presenter
    }

}
