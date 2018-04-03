//
//  ListRepresentationInput.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIViewController

protocol ListRepresentationInput: ListRepresentationEditingInput {
    var viewController: UIViewController { get }
    
    var editingOutput: ListRepresentationEditingOutput? { get set }
    
    func setList(list: List)
    func clearInput()
    
    func forceTaskCreation()
    func finishShortTaskEditing()
}

protocol ListRepresentationEditingInput: class {
    func toggleGroupEditing()
}
