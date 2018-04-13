//
//  ListRepresentationAssembly.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

final class ListRepresentationAssembly {

    static func assembly(with view: ListRepresentationView,
                         output: ListRepresentationOutput) -> ListRepresentationInput {
        let presenter = ListRepresentationPresenter()
        
        view.output = presenter
        
        presenter.view = view
        presenter.output = output
                
        return presenter
    }

}
