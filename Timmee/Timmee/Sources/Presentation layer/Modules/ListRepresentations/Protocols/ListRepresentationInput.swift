//
//  ListRepresentationInput.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIViewController

protocol ListRepresentationInput: class {
    var viewController: UIViewController { get }
    
    func setList(list: List)
    func clearInput()
    
    func forceTaskCreation()
}
