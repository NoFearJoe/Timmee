//
//  TaskEntity+Mapping.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSDate
import class Foundation.NSData
import class Foundation.NSArray
import class Foundation.NSKeyedArchiver
import struct CoreLocation.CLLocationCoordinate2D

extension TaskEntity {

    func map(from entity: Task) {
        id = entity.id
        title = entity.title
        isImportant = entity.isImportant
        notificationMask = entity.notification.rawValue
        note = entity.note
        repeatMask = entity.repeating.string
        dueDate = entity.dueDate
        repeatEndingDate = entity.repeatEndingDate
        
        if let location = entity.location {
            self.location = NSKeyedArchiver.archivedData(withRootObject: location)
        } else {
            self.location = nil
        }
        address = entity.address
        
        shouldNotifyAtLocation = entity.shouldNotifyAtLocation
        isDone = entity.isDone
        inProgress = entity.inProgress
        creationDate = entity.creationDate
        
        attachments = entity.attachments as NSArray
    }

}
