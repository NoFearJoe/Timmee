//
//  TimePicker+TaskParameterEditorInput.swift
//  Scope
//
//  Created by i.kharabet on 27/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIComponents

extension TimePicker: TaskParameterEditorInput {
    
    var container: TaskParameterEditorOutput? {
        get { return nil }
        set {}
    }
    
    var onChangeHeight: ((CGFloat) -> Void)? {
        get { return nil }
        set {}
    }
    
    func completeEditing(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
}
