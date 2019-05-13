//
//  ListRepresentationManagerInput.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

protocol ListRepresentationManagerInput {
    var currentListRepresentationInput: ListRepresentationInput! { get }
    
    func setRepresentation(_ representation: ListRepresentation, animated: Bool)
}

protocol ListRepresentationManagerOutput: class {
    func configureListRepresentation(_ representation: ListRepresentationInput)
}
