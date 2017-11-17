//
//  TaskTimeTemplateEditor.swift
//  Timmee
//
//  Created by i.kharabet on 16.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class TaskTimeTemplateEditor: UIViewController {
    
    @IBOutlet fileprivate var titleTextField: UITextField!
    @IBOutlet fileprivate var dueDateView: TaskParameterView!
    @IBOutlet fileprivate var notificationView: TaskParameterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitleTextField()
        setupDueDateView()
        setupNotificationView()
    }
    
}

extension TaskTimeTemplateEditor: TaskParameterEditorInput {
    var requiredHeight: CGFloat {
        return 156
    }
}

fileprivate extension TaskTimeTemplateEditor {
    
    func setupTitleTextField() {
        
    }
    
    func setupDueDateView() {
        
    }
    
    func setupNotificationView() {
        
    }
    
}
