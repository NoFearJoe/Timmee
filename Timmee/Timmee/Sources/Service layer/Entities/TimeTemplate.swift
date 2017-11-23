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
    var time: (hours: Int, minutes: Int)?
    var notification: NotificationMask
    
    init(id: String,
         title: String,
         time: (hours: Int, minutes: Int)?,
         notification: NotificationMask) {
        self.id = id
        self.title = title
        self.time = time
        self.notification = notification
    }
    
    init(entity: TimeTemplateEntity) {
        id = entity.id ?? ""
        title = entity.title ?? ""
        time = (Int(entity.hours), Int(entity.minutes))
        notification = NotificationMask(mask: entity.notification)
    }
}

extension TimeTemplate: Equatable {
    static func ==(lhs: TimeTemplate, rhs: TimeTemplate) -> Bool {
        return lhs.id == rhs.id
    }
}
