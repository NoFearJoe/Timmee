//
//  ListRepresentationInput.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIViewController

protocol ListRepresentationInput: TableListRepresentationEditingInput {
    var viewController: UIViewController { get }
    
    var editingOutput: ListRepresentationEditingOutput? { get set }
        
    func setList(list: List)
    func performGroupEditingAction(_ action: TargetGroupEditingAction)
}

protocol TableListRepresentationEditingInput: class {
    func setEditingMode(_ mode: ListRepresentationEditingMode, completion: @escaping () -> Void)
}
