//
//  DiaryViewController+State.swift
//  Agile diary
//
//  Created by i.kharabet on 26/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit

extension DiaryViewController {
    
    struct AttachmentState {
        var attachment: DiaryEntry.Attachment = .none
        var attachedEntity: Any?
        
        mutating func clear() {
            attachment = .none
            attachedEntity = nil
        }
    }
    
}
