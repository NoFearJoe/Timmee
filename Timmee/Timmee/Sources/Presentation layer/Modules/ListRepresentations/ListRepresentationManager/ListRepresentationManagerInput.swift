//
//  ListRepresentationManagerInput.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

protocol ListRepresentationManagerInput: class {
    func setRepresentation(_ representation: ListRepresentation, animated: Bool)
    func setList(_ list: List)
    func forceTaskCreation()
}
