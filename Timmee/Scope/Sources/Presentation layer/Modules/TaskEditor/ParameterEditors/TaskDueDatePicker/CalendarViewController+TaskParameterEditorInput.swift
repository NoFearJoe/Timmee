//
//  CalendarViewController+TaskParameterEditorInput.swift
//  Scope
//
//  Created by i.kharabet on 28/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIComponents

extension CalendarViewController: TaskParameterEditorInput {
    
    var container: TaskParameterEditorOutput? {
        get { return nil }
        set {}
    }
    
    var requiredHeight: CGFloat {
        return 0
    }
    
    func completeEditing(completion: @escaping (Bool) -> Void) {
        
    }
    
}
