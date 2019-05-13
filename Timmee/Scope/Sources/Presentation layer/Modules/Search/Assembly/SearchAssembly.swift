//
//  SearchAssembly.swift
//  Timmee
//
//  Created by Ilya Kharabet on 07.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

final class SearchAssembly {
    
    static func assembly(with view: SearchViewController) {
        let presenter = SearchPresenter()
        let interactor = SearchInteractor()
        
        view.output = presenter
        view.dataSource = interactor
        
        presenter.interactor = interactor
        presenter.view = view
        
        interactor.output = presenter        
    }
    
}
