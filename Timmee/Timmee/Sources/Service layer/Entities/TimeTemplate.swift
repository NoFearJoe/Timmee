//
//  TimeTemplate.swift
//  Timmee
//
//  Created by Ilya Kharabet on 12.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSDate

final class TimeTemplate {
    var id: String
    var title: String
    var dueDate: Date
    var notification: NotificationMask
    
    init(id: String,
         title: String,
         dueDate: Date,
         notification: NotificationMask) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.notification = notification
    }
    
    init(entity: TimeTemplateEntity) {
        id = entity.id ?? ""
        title = entity.title ?? ""
        dueDate = (entity.dueDate ?? NSDate()) as Date
        notification = NotificationMask(mask: entity.notification)
    }
}

extension TimeTemplate: Equatable {
    static func ==(lhs: TimeTemplate, rhs: TimeTemplate) -> Bool {
        return lhs.id == rhs.id
    }
}
