//
//  TimeTemplateEntity+Mapping.swift
//  Timmee
//
//  Created by Ilya Kharabet on 12.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSDate

extension TimeTemplateEntity {
    
    func map(from timeTemplate: TimeTemplate) {
        id = timeTemplate.id
        title = timeTemplate.title
        hours = Int16(timeTemplate.time?.hours ?? 0)
        minutes = Int16(timeTemplate.time?.minutes ?? 0)
        notification = timeTemplate.notification.rawValue
    }
    
}
