//
//  TableListRepresentationAssembly.swift
//  Timmee
//
//  Created by i.kharabet on 12.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

final class TableListRepresentationAssembly {
    
    static func assembly(with view: TableListRepresentationView,
                         output: ListRepresentationOutput) -> ListRepresentationInput {
        let presenter = TableListRepresentationPresenter()
        let interactor = TableListRepresentationInteractor()
        let adapter = TableListRepresentationAdapter()
        
        view.output = presenter
        view.adapter = adapter
        
        adapter.output = presenter
        adapter.dataSource = interactor
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.output = output
        
        interactor.output = presenter
        
        return presenter
    }
    
}
