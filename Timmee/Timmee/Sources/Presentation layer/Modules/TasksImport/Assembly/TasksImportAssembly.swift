//
//  TasksImportAssembly.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

final class TasksImportAssembly {

    static func assembly(with view: TasksImportView) -> TasksImportInput {
        let presenter = TasksImportPresenter()
        let interactor = TasksImportInteractor()
        let router = TasksImportRouter()
        
        view.output = presenter
        view.dataSource = presenter
        
        presenter.interactor = interactor
        presenter.router = router
        presenter.view = view
        
        interactor.output = presenter
        
        router.transitionHandler = view
        
        return presenter
    }

}
