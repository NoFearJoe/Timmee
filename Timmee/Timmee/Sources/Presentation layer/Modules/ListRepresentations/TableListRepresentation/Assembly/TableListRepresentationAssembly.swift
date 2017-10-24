//
//  TableListRepresentationAssembly.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

final class TableListRepresentationAssembly {

    static func assembly(with view: TableListRepresentationView,
                         output: ListRepresentationOutput) -> ListRepresentationInput {
        let presenter = TableListRepresentationPresenter()
        let interactor = TableListRepresentationInteractor()
        
        view.output = presenter
        view.dataSource = interactor
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.output = output
        
        interactor.output = presenter
        
        return presenter
    }

}
