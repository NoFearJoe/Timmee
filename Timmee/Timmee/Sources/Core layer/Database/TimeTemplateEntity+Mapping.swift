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
        dueDate = timeTemplate.dueDate as NSDate
        notification = timeTemplate.notification.rawValue
    }
    
}
