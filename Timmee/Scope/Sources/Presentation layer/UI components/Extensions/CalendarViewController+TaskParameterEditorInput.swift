//
//  CalendarViewController+TaskParameterEditorInput.swift
//  Scope
//
//  Created by i.kharabet on 28/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIComponents

extension CalendarViewController: TaskParameterEditorInput {
    
    private static var containerKey: String = "container"
    var container: TaskParameterEditorOutput? {
        get { return objc_getAssociatedObject(self, &CalendarViewController.containerKey) as? TaskParameterEditorOutput }
        set { objc_setAssociatedObject(self, &CalendarViewController.containerKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    var requiredHeight: CGFloat {
        return maximumHeight
    }
    
    func completeEditing(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func setClearButtonVisible(_ isVisible: Bool) {
        container?.closeButton.isHidden = !isVisible
    }
    
}

extension CalendarWithTimeViewController: TaskParameterEditorInput {
    
    private static var containerKey: String = "container"
    var container: TaskParameterEditorOutput? {
        get { return objc_getAssociatedObject(self, &CalendarWithTimeViewController.containerKey) as? TaskParameterEditorOutput }
        set { objc_setAssociatedObject(self, &CalendarWithTimeViewController.containerKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    var requiredHeight: CGFloat {
        return maximumHeight
    }
    
    func completeEditing(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func setClearButtonVisible(_ isVisible: Bool) {
        container?.closeButton.isHidden = !isVisible
    }
    
}
