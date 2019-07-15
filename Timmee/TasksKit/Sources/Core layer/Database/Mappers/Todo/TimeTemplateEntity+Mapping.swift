//
//  TimeTemplateEntity+Mapping.swift
//  Timmee
//
//  Created by Ilya Kharabet on 12.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSDate

public extension TimeTemplateEntity {
    
    func map(from timeTemplate: TimeTemplate) {
        id = timeTemplate.id
        title = timeTemplate.title
        hours = timeTemplate.time.flatMap { NSNumber(value: $0.hours) }
        minutes = timeTemplate.time.flatMap { NSNumber(value: $0.minutes) }
        notification = timeTemplate.notification.flatMap { NSNumber(value: $0.rawValue) }
        notificationTime = timeTemplate.notificationTime.flatMap { "\($0.0):\($0.1)" }
    }
    
}
