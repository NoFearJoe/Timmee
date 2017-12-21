//
//  TaskAttachmentsPicker.swift
//  Timmee
//
//  Created by i.kharabet on 15.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class TaskAttachmentsPicker: UIViewController {
    
    weak var container: TaskParameterEditorOutput?
    
}

extension TaskAttachmentsPicker: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return UIScreen.main.bounds.height - 64
    }
}
